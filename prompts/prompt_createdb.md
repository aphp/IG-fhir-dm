<subagent>
Use subagent sql-pro
Use subagent architect-reviewer
Use subagent backend-architect
Use subagent code-reviewer
</subagent>

<command>
Using the file input/resources/usages/core/Questionnaire-UsageCore.json
propose an SQL schema (create table DLL) specialized for Postgres translating the core concepts of the questionnaires into SQL tables.
A concept should translated to a table if its item type is a group, and contains items having simple type (e.g. string, numeric).
</command>

<example>
<input type="json">
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
</input>
<output type="sql">
-- 
CREATE TABLE identite_patient (
    nom_patient VARCHAR(200), -- Nom patient
    prenom_patient VARCHAR(200), -- Prénom patient
    nir VARCHAR(20) -- Numéro d'inscription au Répertoire (NIR)
);

COMMENT ON COLUMN identite_patient.nir IS 'Numéro unique attribué à chaque personne à sa naissance sur la base d’éléments d’état civil transmis par les mairies à l’INSEE';
</output>
</example>

<expected_output>
Single DDL script for postgres written in the script/ repository
</expected_output>