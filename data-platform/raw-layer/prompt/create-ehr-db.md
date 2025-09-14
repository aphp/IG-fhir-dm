<subagent>
Use subagent sql-pro
Use subagent architect-reviewer
Use subagent backend-architect
Use subagent code-reviewer
</subagent>

<goal>
Create a SQL script creation of PostgreSQL schema: a concept should translated to a table if its item type is a group, and contains items having simple type (e.g. string, numeric).
</goal>

<input>
Using the file input/resources/usages/core/Questionnaire-UsageCore.json
</input>

<tasks>
- EXPLORE and THINK to understand what you need in order to complete the task. Read the input file that is USEFUL for your task.
- PLAN precisely which actions you need to take to accomplish the task. Clearly define each step to achieve a clean and maintainable result, explicitly listing the names of the items that will become tables.
- You should follow the plan exactly, focusing only on the requested task, especially you perform the translating the core concepts of the questionnaires into SQL tables to propose an SQL schema adapted for PostgreSQL version 17.x (create table DLL).
</taks>

<example-input-json>
{
          "linkId": "2958000860428",
          "text": "Identité patient",
          "type": "group",
          "item": [
            {
              "linkId": "8605698058770",
              "text": "Nom patient",
              "type": "string"
            },
            {
              "linkId": "6214879623503",
              "text": "Prénom patient",
              "type": "string"
            },
            {
              "linkId": "5711960356160",
              "text": "Numéro d'inscription au Répertoire (NIR)",
              "type": "string",
              "item": [
                {
                  "extension": [
                    {
                      "url": "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl",
                      "valueCodeableConcept": {
                        "coding": [
                          {
                            "system": "http://hl7.org/fhir/questionnaire-item-control",
                            "code": "help",
                            "display": "Help-Button"
                          }
                        ],
                        "text": "Intention"
                      }
                    }
                  ],
                  "linkId": "5711960356160_intention",
                  "text": "Numéro unique attribué à chaque personne à sa naissance sur la base d’éléments d’état civil transmis par les mairies à l’INSEE",
                  "type": "display"
                }
              ]
            }
</exemple-input-json>
<exemple-output-sql>
-- 
CREATE TABLE identite_patient (
    nom_patient VARCHAR(200), -- Nom patient
    prenom_patient VARCHAR(200), -- Prénom patient
    nir VARCHAR(20) -- Numéro d'inscription au Répertoire (NIR)
);

COMMENT ON COLUMN identite_patient.nir IS 'Numéro unique attribué à chaque personne à sa naissance sur la base d’éléments d’état civil transmis par les mairies à l’INSEE';
</example-output-json>

<expected-output>
Single DDL script for postgreSQL version 17.x written in the input/sql/applications/ehr/questionnaire-core-ddl.sql.
ADD DELETE IF EXIST. No view. No function. No trigger.
All constraints after the CREATE TABLE statement, explicitly defining foreign keys and indexes.
Link all tables to table corresponding to item.linkId = '2825244231605' and to the table patient.
Build a single consolidated table for all laboratory results differentiated by LOINC codes.
Removed the age column from item.linkId = '2825244231605', and consolidating all patient-related information into one table including *sexe* item.
</expected-output>