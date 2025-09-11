<goal>
Convert examples from the logical EHR model format into CSV compliant with the SQL tables.
</goal>

<input-logic>
input\fsh\ehr\logicals\StructureDefinition-EHR.fsh
</input-logic>

<input>
input\test\map\test-ehr-Bernard-Lucas.json
input/test/map/test-ehr-Dore-Jeanne.json
input/test/map/test-ehr-Dubois-Marie.json
input/test/map/test-ehr-Dupont-Jean.json
input/test/map/test-ehr-Faure-Camille.json
input/test/map/test-ehr-Girard-Michel.json
input/test/map/test-ehr-Leroy-Sophie.json
input/test/map/test-ehr-Martin-Pierre.json
input/test/map/test-ehr-Moreau-Claire.json
input/test/map/test-ehr-Petit-Unknown.json
input/test/map/test-ehr-Roux-Antoine.json
</input>

<output-sql>
data-plateform\ehr\sql\ehr-ddl.sql
</output-sql>

<output>
The expected output is one file per table, in CSV format, and compliant with the EHR tables into `data-plateform\transform-layer\data-ingestor\seeds` directory.
</output>