<goal>
Generate comprehensive markdown documentation for this SQL table creation script. The documentation language should match the language used in SQL comments (output in French if comments are in French).
</goal>
<source-of-documenation>
Using the file data-platform\raw-layer\sql\ehr-ddl.sql
</source-of-documenation>

<instructions>
- **Overview**: Summary of the database schema and its purpose
- **Table Documentation**: For each table, create a section with:
  - Table name and description (extracted from SQL comments)
  - Markdown table listing all columns with:
     * Column name
     * Data type
     * Constraints (PK, FK, NOT NULL, UNIQUE, CHECK)
     * Default value
     * Description (from COMMENT statements)
  - Index list with their purposes
  - Foreign key constraints with referenced tables
  - Associated triggers (if any) 
- **Relationships Matrix**: Summary table of all table relationships
- **Business Rules**: Document all CHECK constraints and their business logic
- **Implementation Notes**: Naming conventions, special considerations, etc.
</instructions>
<output>
<format>
- Use well-formatted html tables with a specification for the table width style="width: 100%;" with an indentation of 2 spaces tables
- Include badges/icons for keys (🔑 for PK, 🔗 for FK)
- Extract and integrate all SQL comments (COMMENT ON statements)
- Identify and explain all CHECK constraints and their business rules
- Preserve the original language of comments in the documentation
</format>
<file>
Analyze the SQL script thoroughly and produce clear, professional documentation that serves as a complete technical reference written in the data-platform\semantic-layer\doc\ehr-ddl.md
</file>
</output>