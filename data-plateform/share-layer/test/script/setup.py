"""Setup script for FHIR Bulk Loader."""

from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

with open("requirements.txt", "r", encoding="utf-8") as fh:
    requirements = [line.strip() for line in fh if line.strip() and not line.startswith("#")]

setup(
    name="fhir-bulk-loader",
    version="1.0.0",
    author="FHIR Implementation Guide Team",
    author_email="team@example.com",
    description="A Python script to import FHIR NDJSON.gz files into HAPI FHIR server",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/your-org/fhir-bulk-loader",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Healthcare Industry",
        "Topic :: Software Development :: Libraries :: Python Modules",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
    ],
    python_requires=">=3.8",
    install_requires=requirements,
    entry_points={
        "console_scripts": [
            "fhir-bulk-loader=cli:main",
        ],
    },
    include_package_data=True,
)