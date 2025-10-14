Invariant: sql-name
Description: """
Name is limited to letters, numbers, or underscores and cannot start with an
underscore -- i.e. with a regular expression of: ^[A-Za-z][A-Za-z0-9_]*$


This makes it usable as table names in a wide variety of databases.
"""
Severity: #error
Expression: "empty() or matches('^[A-Za-z][A-Za-z0-9_]*$')"
