"""Utility functions and error handling for FHIR to OMOP exporter."""

import os
import sys
import time
import functools
import logging
from pathlib import Path
from typing import Any, Callable, Dict, List, Optional, Type, TypeVar, Union
from datetime import datetime, timezone
import json
import traceback

import structlog
from tenacity import (
    retry, stop_after_attempt, wait_exponential, 
    retry_if_exception_type, before_sleep_log
)
# Custom circuit breaker implementation below
from rich.console import Console
from rich.progress import Progress, SpinnerColumn, TextColumn
from rich.logging import RichHandler

# Type variable for decorated functions
F = TypeVar('F', bound=Callable[..., Any])

# Console for rich output
console = Console()

# Global flag to coordinate progress displays
_main_progress_active = False

def set_main_progress_active(active: bool) -> None:
    """Set the main progress display state."""
    global _main_progress_active
    _main_progress_active = active

def is_main_progress_active() -> bool:
    """Check if main progress display is active."""
    return _main_progress_active

# Configure structured logging
structlog.configure(
    processors=[
        structlog.processors.TimeStamper(fmt="ISO"),
        structlog.processors.add_log_level,
        structlog.processors.StackInfoRenderer(),
        structlog.dev.ConsoleRenderer(colors=True)
    ],
    wrapper_class=structlog.make_filtering_bound_logger(30),  # INFO level
    logger_factory=structlog.PrintLoggerFactory(),
    cache_logger_on_first_use=True,
)

logger = structlog.get_logger(__name__)


class FHIRExportError(Exception):
    """Base exception for FHIR export operations."""
    
    def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
        super().__init__(message)
        self.message = message
        self.details = details or {}
        self.timestamp = datetime.now(timezone.utc)
    
    def __str__(self) -> str:
        base_msg = self.message
        if self.details:
            details_str = ", ".join(f"{k}={v}" for k, v in self.details.items())
            return f"{base_msg} (Details: {details_str})"
        return base_msg


class DataSourceError(FHIRExportError):
    """Exception for data source related errors."""
    pass


class TransformationError(FHIRExportError):
    """Exception for data transformation errors."""
    pass


class ValidationError(FHIRExportError):
    """Exception for data validation errors."""
    pass


class OutputError(FHIRExportError):
    """Exception for output writing errors."""
    pass


def setup_logging(
    log_level: str = "INFO",
    log_file: Optional[Path] = None,
    structured: bool = True
) -> None:
    """Set up application logging.
    
    Args:
        log_level: Logging level (DEBUG, INFO, WARNING, ERROR)
        log_file: Optional file path for log output
        structured: Whether to use structured logging
    """
    level_mapping = {
        'DEBUG': logging.DEBUG,
        'INFO': logging.INFO, 
        'WARNING': logging.WARNING,
        'ERROR': logging.ERROR
    }
    level = level_mapping.get(log_level.upper(), logging.INFO)
    
    processors = [
        structlog.processors.TimeStamper(fmt="ISO"),
        structlog.processors.add_log_level,
        structlog.processors.StackInfoRenderer(),
    ]
    
    if structured:
        processors.append(structlog.dev.ConsoleRenderer(colors=True))
    else:
        processors.append(structlog.processors.JSONRenderer())
    
    if log_file:
        # Ensure log directory exists
        log_file.parent.mkdir(parents=True, exist_ok=True)
        
        # Configure file handler
        file_handler = logging.FileHandler(log_file)
        file_handler.setLevel(level)
        
        root_logger = logging.getLogger()
        root_logger.addHandler(file_handler)
    
    structlog.configure(
        processors=processors,
        wrapper_class=structlog.make_filtering_bound_logger(level),
        logger_factory=structlog.PrintLoggerFactory(),
        cache_logger_on_first_use=True,
    )


def retry_with_backoff(
    max_retries: int = 3,
    backoff_factor: float = 2.0,
    max_wait: float = 60.0,
    retry_on: Optional[List[Type[Exception]]] = None
) -> Callable[[F], F]:
    """Decorator for retrying operations with exponential backoff.
    
    Args:
        max_retries: Maximum number of retry attempts
        backoff_factor: Exponential backoff multiplier
        max_wait: Maximum wait time between retries
        retry_on: List of exception types to retry on
        
    Returns:
        Decorated function with retry logic
    """
    if retry_on is None:
        retry_on = [FHIRExportError, ConnectionError, TimeoutError]
    
    def decorator(func: F) -> F:
        @retry(
            stop=stop_after_attempt(max_retries + 1),
            wait=wait_exponential(multiplier=1, min=1, max=max_wait),
            retry=retry_if_exception_type(tuple(retry_on)),
            before_sleep=before_sleep_log(logger, 20)  # INFO level
        )
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            return func(*args, **kwargs)
        return wrapper
    return decorator


class CircuitBreaker:
    """Simple circuit breaker implementation."""
    
    def __init__(self, failure_threshold: int = 5, timeout_duration: int = 60, recovery_timeout: int = 30):
        self.failure_threshold = failure_threshold
        self.timeout_duration = timeout_duration
        self.recovery_timeout = recovery_timeout
        self.failure_count = 0
        self.last_failure_time = None
        self.state = "CLOSED"  # CLOSED, OPEN, HALF_OPEN
        
    def call(self, func, *args, **kwargs):
        """Call function with circuit breaker protection."""
        if self.state == "OPEN":
            if time.time() - self.last_failure_time > self.recovery_timeout:
                self.state = "HALF_OPEN"
            else:
                raise CircuitBreakerOpenError("Circuit breaker is open")
        
        try:
            result = func(*args, **kwargs)
            if self.state == "HALF_OPEN":
                self.state = "CLOSED"
                self.failure_count = 0
            return result
        except Exception as e:
            self.failure_count += 1
            self.last_failure_time = time.time()
            
            if self.failure_count >= self.failure_threshold:
                self.state = "OPEN"
                
            raise e


class CircuitBreakerOpenError(FHIRExportError):
    """Exception raised when circuit breaker is open."""
    pass


class CircuitBreakerRegistry:
    """Registry for managing circuit breakers across the application."""
    
    def __init__(self):
        self._breakers: Dict[str, CircuitBreaker] = {}
    
    def get_breaker(
        self,
        name: str,
        failure_threshold: int = 5,
        timeout_duration: int = 60,
        recovery_timeout: int = 30
    ) -> CircuitBreaker:
        """Get or create a circuit breaker.
        
        Args:
            name: Unique name for the circuit breaker
            failure_threshold: Number of failures before opening circuit
            timeout_duration: Time to keep circuit open
            recovery_timeout: Time to wait before retrying
            
        Returns:
            CircuitBreaker instance
        """
        if name not in self._breakers:
            self._breakers[name] = CircuitBreaker(
                failure_threshold=failure_threshold,
                timeout_duration=timeout_duration,
                recovery_timeout=recovery_timeout,
                name=name
            )
        return self._breakers[name]
    
    def reset_all(self) -> None:
        """Reset all circuit breakers."""
        for breaker in self._breakers.values():
            breaker.reset()


# Global circuit breaker registry
circuit_registry = CircuitBreakerRegistry()


def with_circuit_breaker(
    name: str,
    failure_threshold: int = 5,
    timeout_duration: int = 60
) -> Callable[[F], F]:
    """Decorator to wrap function with circuit breaker pattern.
    
    Args:
        name: Circuit breaker name
        failure_threshold: Failures before opening circuit
        timeout_duration: Timeout duration in seconds
        
    Returns:
        Decorated function with circuit breaker protection
    """
    def decorator(func: F) -> F:
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            breaker = circuit_registry.get_breaker(
                name, failure_threshold, timeout_duration
            )
            return breaker.call(func, *args, **kwargs)
        return wrapper
    return decorator


class ProgressReporter:
    """Progress reporting utility with rich console output."""
    
    def __init__(self, description: str = "Processing"):
        self.description = description
        self.progress: Optional[Progress] = None
        self.task_id: Optional[Any] = None
        self.fallback_mode = False
    
    def __enter__(self):
        # Use fallback mode if main progress is active
        if is_main_progress_active():
            logger.info(f"Progress: {self.description}")
            self.fallback_mode = True
            return self
            
        try:
            self.progress = Progress(
                SpinnerColumn(),
                TextColumn("[progress.description]{task.description}"),
                console=console,
                transient=True
            )
            self.progress.__enter__()
            self.task_id = self.progress.add_task(self.description, total=None)
            return self
        except Exception as e:
            # Fallback to simple logging if Rich progress conflicts
            if "Only one live display may be active at once" in str(e):
                logger.info(f"Progress: {self.description}")
                self.fallback_mode = True
                return self
            raise
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.progress and not self.fallback_mode:
            self.progress.__exit__(exc_type, exc_val, exc_tb)
    
    def update(self, description: str):
        """Update progress description."""
        if self.fallback_mode:
            logger.info(f"Progress: {description}")
        elif self.progress and self.task_id is not None:
            self.progress.update(self.task_id, description=description)


def ensure_directory(path: Union[str, Path]) -> Path:
    """Ensure directory exists, create if necessary.
    
    Args:
        path: Directory path
        
    Returns:
        Path object for the directory
        
    Raises:
        OSError: If directory cannot be created
    """
    path = Path(path)
    try:
        path.mkdir(parents=True, exist_ok=True)
        return path
    except OSError as e:
        logger.error("Failed to create directory", path=str(path), error=str(e))
        raise


def safe_json_load(file_path: Union[str, Path]) -> Dict[str, Any]:
    """Safely load JSON file with error handling.
    
    Args:
        file_path: Path to JSON file
        
    Returns:
        Parsed JSON data
        
    Raises:
        FHIRExportError: If file cannot be loaded or parsed
    """
    file_path = Path(file_path)
    
    try:
        if not file_path.exists():
            raise FileNotFoundError(f"File not found: {file_path}")
        
        with open(file_path, "r", encoding="utf-8") as f:
            return json.load(f)
            
    except json.JSONDecodeError as e:
        raise FHIRExportError(
            f"Invalid JSON in file: {file_path}",
            details={"json_error": str(e), "line": e.lineno}
        ) from e
    except Exception as e:
        raise FHIRExportError(
            f"Failed to load file: {file_path}",
            details={"error_type": type(e).__name__, "error": str(e)}
        ) from e


def safe_json_dump(
    data: Dict[str, Any],
    file_path: Union[str, Path],
    indent: int = 2
) -> None:
    """Safely write JSON data to file.
    
    Args:
        data: Data to write
        file_path: Output file path
        indent: JSON indentation level
        
    Raises:
        FHIRExportError: If file cannot be written
    """
    file_path = Path(file_path)
    
    try:
        # Ensure parent directory exists
        file_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=indent, ensure_ascii=False)
            
    except Exception as e:
        raise FHIRExportError(
            f"Failed to write JSON file: {file_path}",
            details={"error_type": type(e).__name__, "error": str(e)}
        ) from e


def validate_fhir_resource_type(resource_type: str) -> bool:
    """Validate FHIR resource type name.
    
    Args:
        resource_type: Resource type to validate
        
    Returns:
        True if valid FHIR resource type
    """
    # Common FHIR resource types
    valid_types = {
        "Patient", "Practitioner", "Organization", "Location",
        "Observation", "Condition", "Procedure", "MedicationRequest",
        "Encounter", "DiagnosticReport", "Specimen", "Device",
        "AllergyIntolerance", "Immunization", "CarePlan", "Goal"
    }
    
    return resource_type in valid_types


def format_file_size(size_bytes: int) -> str:
    """Format file size in human-readable format.
    
    Args:
        size_bytes: Size in bytes
        
    Returns:
        Formatted size string
    """
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if size_bytes < 1024.0:
            return f"{size_bytes:.1f} {unit}"
        size_bytes /= 1024.0
    return f"{size_bytes:.1f} PB"


def get_memory_usage() -> Dict[str, Any]:
    """Get current memory usage statistics.
    
    Returns:
        Dictionary with memory usage info
    """
    try:
        import psutil
        process = psutil.Process()
        memory_info = process.memory_info()
        
        return {
            "rss_mb": memory_info.rss / 1024 / 1024,  # Resident Set Size
            "vms_mb": memory_info.vms / 1024 / 1024,  # Virtual Memory Size
            "percent": process.memory_percent(),
            "available_mb": psutil.virtual_memory().available / 1024 / 1024
        }
    except ImportError:
        # Fallback if psutil is not available
        return {"error": "psutil not available"}


def log_execution_time(func_name: str = None) -> Callable[[F], F]:
    """Decorator to log function execution time.
    
    Args:
        func_name: Optional custom function name for logging
        
    Returns:
        Decorated function with timing
    """
    def decorator(func: F) -> F:
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            name = func_name or func.__name__
            start_time = time.time()
            
            try:
                result = func(*args, **kwargs)
                execution_time = time.time() - start_time
                
                logger.info(
                    "Function completed",
                    function=name,
                    execution_time_seconds=round(execution_time, 2)
                )
                
                return result
                
            except Exception as e:
                execution_time = time.time() - start_time
                
                logger.error(
                    "Function failed",
                    function=name,
                    execution_time_seconds=round(execution_time, 2),
                    error=str(e)
                )
                raise
                
        return wrapper
    return decorator


class HealthCheck:
    """Health check utility for system resources and dependencies."""
    
    @staticmethod
    def check_disk_space(path: Union[str, Path], min_gb: float = 1.0) -> bool:
        """Check available disk space.
        
        Args:
            path: Path to check
            min_gb: Minimum required space in GB
            
        Returns:
            True if sufficient space available
        """
        try:
            import shutil
            total, used, free = shutil.disk_usage(path)
            free_gb = free / (1024 ** 3)
            
            logger.info(
                "Disk space check",
                path=str(path),
                free_gb=round(free_gb, 2),
                required_gb=min_gb
            )
            
            return free_gb >= min_gb
            
        except Exception as e:
            logger.warning("Failed to check disk space", error=str(e))
            return True  # Assume OK if can't check
    
    @staticmethod
    def check_memory(min_mb: float = 512.0) -> bool:
        """Check available memory.
        
        Args:
            min_mb: Minimum required memory in MB
            
        Returns:
            True if sufficient memory available
        """
        try:
            memory_info = get_memory_usage()
            available_mb = memory_info.get("available_mb", min_mb)
            
            logger.info(
                "Memory check",
                available_mb=round(available_mb, 2),
                required_mb=min_mb
            )
            
            return available_mb >= min_mb
            
        except Exception as e:
            logger.warning("Failed to check memory", error=str(e))
            return True  # Assume OK if can't check
    
    @staticmethod
    def check_pathling_context(pc) -> bool:
        """Check if Pathling context is properly initialized.
        
        Args:
            pc: Pathling context to check
            
        Returns:
            True if context is ready
        """
        try:
            if pc is None:
                return False
            
            # Try to access Spark context
            if hasattr(pc, '_spark') and pc._spark:
                spark_context = pc._spark.sparkContext
                # Check if context is stopped (could be method or property)
                is_stopped = getattr(spark_context, 'isStopped', lambda: False)
                if callable(is_stopped):
                    if is_stopped():
                        return False
                elif is_stopped:
                    return False
            
            logger.info("Pathling context check passed")
            return True
            
        except Exception as e:
            logger.warning("Pathling context check failed", error=str(e))
            return False


def create_error_report(
    error: Exception,
    context: Optional[Dict[str, Any]] = None
) -> Dict[str, Any]:
    """Create detailed error report for debugging.
    
    Args:
        error: Exception that occurred
        context: Additional context information
        
    Returns:
        Error report dictionary
    """
    report = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "error_type": type(error).__name__,
        "error_message": str(error),
        "traceback": traceback.format_exc(),
        "python_version": sys.version,
        "platform": sys.platform,
    }
    
    if context:
        report["context"] = context
    
    if isinstance(error, FHIRExportError):
        report["details"] = error.details
    
    # Add memory usage if available
    try:
        report["memory_usage"] = get_memory_usage()
    except Exception:
        pass
    
    return report