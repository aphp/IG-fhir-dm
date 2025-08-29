<subagent>
Use subagent sql-pro
Use subagent architect-reviewer
Use subagent backend-architect
Use subagent code-reviewer
</subagent>

<command>
Using the file /data/projets/code/IG-fhir-dm/input/resources/usages/core/QuestionnaireResponse-test-usage-core.json

Propose an SQL script (specialized for Postgres) reading the data from the input file and populating the database created by /data/projets/code/IG-fhir-dm/scripts/questionnaire-core-ddl-fixed.sql
</command>

<example>
<input type="json">
       {
          "linkId": "2958000860428",
          "text": "Identité patient",
          "item": [
            {
              "answer": [
                {
                  "valueString": "doe"
                }
              ],
              "linkId": "8605698058770",
              "text": "Nom patient"
            },
            {
              "answer": [
                {
                  "valueString": "john"
                }
              ],
              "linkId": "6214879623503",
              "text": "Prénom patient"
            },
            {
              "answer": [
                {
                  "valueString": "1234567890123"
                }
              ],
              "linkId": "5711960356160",
              "text": "Numéro d'inscription au Répertoire (NIR)"
            },
            {
              "answer": [
                {
                  "valueDate": "1948-07-16"
                }
              ],
              "linkId": "5036133558154",
              "text": "Date de naissance"
            }
          ]
        },
</input>
<output type="sql">
INSERT INTO identite_patient(nom_patient,prenom_patient,nir,date_naissance) VALUES ('doe', 'john', '1234567890123', '1948-07-16');
</output>
</example>

<expected_output>
Single SQL script for postgres written in the script/ repository
</expected_output>