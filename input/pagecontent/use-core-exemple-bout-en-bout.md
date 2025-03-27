<ol>
  <li><a href="Questionnaire-UsageCore.html">Questionnaire des exigences</a></li>
  <li><a href="QuestionnaireResponse-qr-test-usage-core.html">QuestionnaireResponse des exigences</a></li>
  <li><a href="StructureMap-CoreBusiness2Physical.html">StructureMap de génération du dataset depuis la QuestionnaireResponse</a></li>
  <li>DataSet Patient généré par l'éxecution de la StructureMap sur le QuestionnaireResponse : 
    <pre>{
  "patient" : {
    "name" : "doe",
    "firstName" : "john",
    "gender" : "h",
    "birthDate" : "1948-07-16",
    "nir" : "1234567890123"
  }
}</pre></li>
  <li><a href="StructureMap-CorePhysical2FHIR.html">StructureMap de génération de la ressource Patient depuis le datasetPatient</a></li>
  <li><a href="Patient-8f005d60-b59b-47f7-b04a-f877378f8d68.html">Patient généré par l'éxecution de la StructureMap sur le dataset patient</a></li>
  <li><a href="StructureMap-CoreFHIRPatient2OMOP.html">StructureMap de génération de l'entrée OMOP depuis la ressource Patient</a></li>
  <li>Entrée de la table OMOP générée par l'éxecution de la StructureMap sur la ressource Patient : <pre>{
  "person" : {
    "gender_concept_id" : {
      "reference" : "Concept/8507"
    },
  "year_of_birth" : 1948,
  "month_of_birth" : 7,
  "day_of_birth" : 16,
  "birth_datetime" : "1948-07-16",
  "person_source_value" : "8f005d60-b59b-47f7-b04a-f877378f8d68",
  "gender_source_value" : "male"
  }
}</pre></li>
</ol>


