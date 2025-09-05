<subagent>
Use subagent sql-pro
Use subagent architect-reviewer
Use subagent backend-architect
Use subagent code-reviewer
</subagent>

<goal>
Create a SQL script to insert data from input into EHR PostgreSQL database to test.
</goal>

<tasks>
1. You should begin by analyzing the input files, with a particular focus on explaining the relationships between the Questionnaire, QuestionnaireResponse and EHR data model.
2. Then, you present your plan before proceeding further.
3. If I accepted, you should perform the job. The EHR data model is derived from input/resources/usages/core/Questionnaire-UsageCore.json as the source QuestionnaireResponse. You should leverage this file to design an optimized SQL script that inserts data from the QuestionnaireResponse source into the EHR data model.
4. You should verify that referential integrity is respected.
</tasks>

<input>
A QuestionnaireResponse source of to convert into SQL is input/resources/usages/core/QuestionnaireResponse-test-usage-core-complet.json.
A source of EHR data model is input/sql/applications/ehr/questionnaire-core-ddl.sql.
</input>

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
INSERT INTO identite_patient(nom_patient,prenom_patient,nir,date_naissance) VALUES ('Doré', 'Jeanne', '1590778035124', '1959-07-07');
</output>
</example>

<expected-output>
Single DML script for postgreSQL version 17.x written in the input/test/sql/applications/ehr/test-core-dml.sql.
</expected-output>