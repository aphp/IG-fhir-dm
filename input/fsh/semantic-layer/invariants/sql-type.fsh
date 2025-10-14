Invariant: sql-type
Description: """
If the data type is VARCHAR2 then length cannot be empty.
"""
Severity: #error
Expression: "name = 'VARCHAR2' and (length.empty() or length = 0)"
