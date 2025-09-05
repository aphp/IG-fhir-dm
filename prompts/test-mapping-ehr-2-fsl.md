<subagent>
Use subagent fsh-specialist
Use subagent architect-reviewer
Use subagent backend-architect
Use subagent code-reviewer
</subagent>

<goal>
Create an instance of StructureDefinitition king logical EHR to test StructreMap EHR2FSL.
</goal>

<tasks>
1. You should begin by analyzing the input files, with a particular focus on explaining the relationships between the QuestionnaireResponse and EHR logical model.
2. Then, you present your plan before proceeding further.
3. If I accepted, you should perform the job.
</tasks>

<input>
The reference EHR logical model is input/fsh/applications/ehr/logicals/StructureDefinition-EHR.fsh
A QuestionnaireResponse source of to convert into instance of EHR logical model is input/resources/usages/core/QuestionnaireResponse-test-usage-core.json.
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
<output type="json">
{
  "resourceType": "EHR",
  "patient": {
    "patientId": "1",
    "nom": "doe",
    "prenom": "john",
    "nir": "1234567890123",
    "dateNaissance": "1948-07-16"
  }
}
</output>
</example>

<expected-output>
An instance of EHR logical model with values of QuestionnaireResponse in format JSON written in the input/test-map/test-ehr-[nom]-[prenom].json.
Note: value betwwen [] should be remplaced by corresponding values.
</expected-output>