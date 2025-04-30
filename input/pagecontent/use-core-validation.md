
#### D'une réponse au questionnaire des variables socles à OMOP

<ol>
  <li>
    <p><b>Un exemple de réponse issue du <a href="Questionnaire-UsageCore.html">questionnaire des variables socles</a></b> :</p>
    <p>TODO mettre le détail du comment</p>
    <p><b>Le résultat</b> : <a href="QuestionnaireResponse-qr-test-usage-core.html">un exemple de réponse</a></p>
  </li>
  <li>
    <p><b>Transformation d'une ressource `QuestionnaireResponse` en une instance du modèle physique de notre DPI théorique</b> :</p>
    <p>Dans VSCode, ouvrir le fichier `input/fml/usages/core/StructureMap-CoreBusiness2Physical.fml`, puis dans le menu contextuel (clic droit dans le fichier) choisir l'entrée `Validate StructureMap (With input selection)`, puis choisir le fichier `input/test-map/usages/core/QuestionnaireResponse-UsageCoreTest.json`</p>
    <p><b>Le résultat doit être équivalent à</b> : `input/test-map/usages/core/CoreDataSet-UsageCoreTest.json`</p>
    <pre>
    {
      "resourceType" : "CoreDataSet",
      "logicalid" : "UUID",
      "patient" : {
        "name" : "doe",
        "firstName" : "john",
        "gender" : "h",
        "birthDate" : "1948-07-16",
        "nir" : "1234567890123"
      }
    }
    </pre>
  </li>
  <li>
    <p><b>Transformation d'une instance de DPI générique vers une instance FHIR (couche sémantique)</b> :</p>
    <p>Dans VSCode, ouvrir le fichier `input/fml/usages/core/StructureMap-CorePhysical2FHIR.fml`, puis dans le menu contextuel (clic droit dans le fichier) choisir l'entrée `Validate StructureMap (With input selection)`, puis choisir le fichier `input/test-map/usages/core/CoreDataSet-UsageCoreTest.json` ou bien prendre le résultat de la transformation précédente</p>
    <p><b>Le résultat doit être équivalent à</b> : `input/test-map/usages/core/Bundle-UsageCoreTest.json`</p>
    <pre>
    {
      "resourceType" : "Bundle",
      "id" : "5ffa8d78-eae5-48bb-8507-ed541096942e",
      "type" : "transaction",
      "entry" : [{
        "fullUrl" : "https://aphp.fr/Patient/06c423fb-e9c2-4dc6-bfd6-b56080caccf6",
        "resource" : {
          "resourceType" : "Patient",
          "id" : "06c423fb-e9c2-4dc6-bfd6-b56080caccf6",
          "meta" : {
            "source" : "https://aphp.fr/fhir/Endpoint/dpi/PatientTable/1"
          },
          "name" : [{
            "use" : "usual",
            "text" : "john doe",
            "family" : "doe",
            "given" : ["john"]
          }],
          "gender" : "male",
          "birthDate" : "1948-07-16"
        },
        "request" : {
          "method" : "POST",
          "url" : "Patient/06c423fb-e9c2-4dc6-bfd6-b56080caccf6"
        }
      },
      {
        "fullUrl" : "https://aphp.fr/Encounter/3bffe646-7612-425f-af20-c068546bcd0a",
        "resource" : {
          "resourceType" : "Encounter",
          "id" : "3bffe646-7612-425f-af20-c068546bcd0a",
          "meta" : {
            "source" : "https://aphp.fr/fhir/Endpoint/dpi/SejourTable/1"
          },
          "status" : "finished",
          "class" : {
            "system" : "http://terminology.hl7.org/CodeSystem/v3-ActCode",
            "code" : "IMP",
            "display" : "inpatient encounter"
          },
          "type" : [{
            "coding" : [{
              "system" : "https://aphp.fr/ig/fhir/dm/CodeSystem/SemanticLayerEncounterType",
              "code" : "b",
              "display" : "Type B"
            }]
          }],
          "subject" : {
            "reference" : "Patient/06c423fb-e9c2-4dc6-bfd6-b56080caccf6"
          },
          "period" : {
            "start" : "2025-02-04",
            "end" : "2025-02-05"
          }
        },
        "request" : {
          "method" : "POST",
          "url" : "Encounter/3bffe646-7612-425f-af20-c068546bcd0a"
        }
      },
      {
        "fullUrl" : "https://aphp.fr/Observation/5b928484-36e1-4a2b-971a-26e6a7862a89",
        "resource" : {
          "resourceType" : "Observation",
          "id" : "5b928484-36e1-4a2b-971a-26e6a7862a89",
          "meta" : {
            "source" : "https://aphp.fr/fhir/Endpoint/dpi/BiologyTable/1"
          },
          "status" : "final",
          "category" : [{
            "coding" : [{
              "system" : "http://terminology.hl7.org/CodeSystem/observation-category",
              "code" : "vital-signs",
              "display" : "Vital Signs"
            }]
          }],
          "code" : {
            "coding" : [{
              "system" : "http://loinc.org",
              "code" : "29463-7"
            }]
          },
          "subject" : {
            "reference" : "Patient/06c423fb-e9c2-4dc6-bfd6-b56080caccf6"
          },
          "encounter" : {
            "reference" : "Encounter/3bffe646-7612-425f-af20-c068546bcd0a"
          },
          "effectiveDateTime" : "2025-02-04T09:30:10+01:00",
          "valueQuantity" : {
            "value" : 45.5,
            "unit" : "kg",
            "system" : "http://unitsofmeasure.org",
            "code" : "kg"
          }
        },
        "request" : {
          "method" : "POST",
          "url" : "Observation/5b928484-36e1-4a2b-971a-26e6a7862a89"
        }
      },
      {
        "fullUrl" : "https://aphp.fr/Encounter/290f200f-2339-4c5d-9824-4f45bcb3024c",
        "resource" : {
          "resourceType" : "Encounter",
          "id" : "290f200f-2339-4c5d-9824-4f45bcb3024c",
          "meta" : {
            "source" : "https://aphp.fr/fhir/Endpoint/dpi/SejourTable/2"
          },
          "status" : "finished",
          "class" : {
            "system" : "http://terminology.hl7.org/CodeSystem/v3-ActCode",
            "code" : "IMP",
            "display" : "inpatient encounter"
          },
          "type" : [{
            "coding" : [{
              "system" : "https://aphp.fr/ig/fhir/dm/CodeSystem/SemanticLayerEncounterType",
              "code" : "b",
              "display" : "Type B"
            }]
          }],
          "subject" : {
            "reference" : "Patient/06c423fb-e9c2-4dc6-bfd6-b56080caccf6"
          },
          "period" : {
            "start" : "2025-03-04"
          }
        },
        "request" : {
          "method" : "POST",
          "url" : "Encounter/290f200f-2339-4c5d-9824-4f45bcb3024c"
        }
      }]
    }
    </pre>
  </li>
  <li>
    <p><b>Transformation d'une instance de FHIR vers une instance OMOP (format le livraison)</b> :</p>
    <p>Dans VSCode, ouvrir le fichier `input/fml/usages/core/StrucutreMap-CoreFHIR2OMOP.fml`, puis dans le menu contextuel (clic droit dans le fichier) choisir l'entrée `Validate StructureMap (With input selection)`, puis choisir le fichier `input/test-map/usages/core/Patient-CoreDataSetTest.json` ou bien prendre le résultat de la transformation précédente</p>
    <p><b>Le résultat doit être équivalent à</b> : `input/`</p>
    <pre>
    {
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
    }
    </pre>
  </li>
</ol>
