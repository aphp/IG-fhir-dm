
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
    <p><b>Le résultat doit être équivalent à</b> : `input/test-map/usages/core/CoreDataSet-QRGenerated.json`</p>
    <pre>
    {
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
    <p>Dans VSCode, ouvrir le fichier `input/fml/usages/core/StructureMap-CorePhysical2FHIR.fml`, puis dans le menu contextuel (clic droit dans le fichier) choisir l'entrée `Validate StructureMap (With input selection)`, puis choisir le fichier `input/test-map/usages/core/CoreDataSet-test.json` ou bien prendre le résultat de la transformation précédente</p>
    <p><b>Le résultat doit être équivalent à</b> : `input/test-map/usages/core/Bundle-test.json`</p>
    <pre>
    {
      "resourceType" : "Bundle",
      "id" : "829a6481-2fdb-4ddf-8ec1-2b5442866ba4",
      "type" : "transaction",
      "entry" : [{
        "fullUrl" : "Patient/3e355ac9-9a5b-4a18-a551-6fa0eb187c67",
        "resource" : {
          "resourceType" : "Patient",
          "id" : "3e355ac9-9a5b-4a18-a551-6fa0eb187c67",
          "meta" : {
            "source" : "https://aphp.fr/fhir/Endpoint/dpi/PatientTable/1"
          },
          "name" : [{
            "text" : "john doe",
            "family" : "doe",
            "given" : ["john"]
          }],
          "gender" : "male",
          "birthDate" : "1948-07-16"
        },
        "request" : {
          "method" : "POST",
          "url" : "Patient/3e355ac9-9a5b-4a18-a551-6fa0eb187c67"
        }
      },
      {
        "fullUrl" : "Encounter/681fea7f-5267-4d7e-9934-29c616e93264",
        "resource" : {
          "resourceType" : "Encounter",
          "id" : "681fea7f-5267-4d7e-9934-29c616e93264",
          "meta" : {
            "source" : "https://aphp.fr/fhir/Endpoint/dpi/SejourTable/1"
          },
          "type" : [{
            "coding" : [{
              "system" : "https://aphp.fr/ig/fhir/dm/CodeSystem/SemanticLayerEncounterType",
              "code" : "b",
              "display" : "Type B"
            }]
          }],
          "subject" : {
            "reference" : "Patient/3e355ac9-9a5b-4a18-a551-6fa0eb187c67"
          },
          "period" : {
            "start" : "2025-02-04",
            "end" : "2025-02-05"
          }
        },
        "request" : {
          "method" : "POST",
          "url" : "Encounter/681fea7f-5267-4d7e-9934-29c616e93264"
        }
      },
      {
        "fullUrl" : "Observation/cf1b90c7-05f2-4b5b-9a45-2670d8b90c6e",
        "resource" : {
          "resourceType" : "Observation",
          "id" : "cf1b90c7-05f2-4b5b-9a45-2670d8b90c6e",
          "meta" : {
            "source" : "https://aphp.fr/fhir/Endpoint/dpi/BiologyTable/1"
          },
          "code" : {
            "coding" : [{
              "system" : "http://loinc.org",
              "code" : "29463-7"
            }]
          },
          "subject" : {
            "reference" : "Patient/3e355ac9-9a5b-4a18-a551-6fa0eb187c67"
          },
          "encounter" : {
            "reference" : "Encounter/681fea7f-5267-4d7e-9934-29c616e93264"
          },
          "effectiveDate" : "2025-02-04",
          "valueQuantity" : {
            "value" : 45.5,
            "unit" : "kg",
            "system" : "http://unitsofmeasure.org"
          }
        },
        "request" : {
          "method" : "POST",
          "url" : "Observation/cf1b90c7-05f2-4b5b-9a45-2670d8b90c6e"
        }
      },
      {
        "fullUrl" : "Encounter/872b55a4-1e81-47f4-bdf8-5a234f1c9edc",
        "resource" : {
          "resourceType" : "Encounter",
          "id" : "872b55a4-1e81-47f4-bdf8-5a234f1c9edc",
          "meta" : {
            "source" : "https://aphp.fr/fhir/Endpoint/dpi/SejourTable/2"
          },
          "type" : [{
            "coding" : [{
              "system" : "https://aphp.fr/ig/fhir/dm/CodeSystem/SemanticLayerEncounterType",
              "code" : "b",
              "display" : "Type B"
            }]
          }],
          "subject" : {
            "reference" : "Patient/3e355ac9-9a5b-4a18-a551-6fa0eb187c67"
          },
          "period" : {
            "start" : "2025-03-04"
          }
        },
        "request" : {
          "method" : "POST",
          "url" : "Encounter/872b55a4-1e81-47f4-bdf8-5a234f1c9edc"
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
