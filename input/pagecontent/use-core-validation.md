
#### D'une réponse au questionnaire des variables socles à OMOP

<ol>
  <li>
    <p><b>Un exemple de réponse issue du <a href="Questionnaire-UsageCore.html">questionnaire des variables socles</a></b> :</p>
    <p>On peut  utiliser le <a href="https://lhcforms.nlm.nih.gov/lhcforms">LHC-Forms Widget</a>, un outil open source qui propose une interface de saisie et qui génère la ressource QuestionnaireResponse correspondant aux données saisies dans l'interface : 
      <ol>
        <li>On charge <a href="Questionnaire-UsageCore.json">le JSON du Questionnaire</a> via le bouton vert "Load From File",</li>
        <li>On saisi les données que l'on souhaite dans l'interface,</li>
        <li>On enregistre la ressource QuestionnaireResponse via le bouton bleu "Show Form Data As ..." en choisissant l'option "FHIR SDC QuestionnaireResponse"</li>
      </ol>
    </p>
    <p><b>Le résultat</b> : <a href="QuestionnaireResponse-test-usage-core.html">un exemple de réponse</a></p>
  </li>
  <li>
    <p><b>Transformation d'une ressource `QuestionnaireResponse` en une instance du modèle physique de notre DPI théorique</b> :</p>
    <p>Dans VSCode, ouvrir le fichier `input/fml/usages/core/StructureMap-CoreBusiness2Physical.fml`, puis dans le menu contextuel (clic droit dans le fichier) choisir l'entrée `Validate StructureMap (With input selection)`, puis choisir le fichier `input/test-map/usages/core/QuestionnaireResponse-test-usage-core.json`</p>
    <p><b>Le résultat doit être équivalent à</b> : `input/test-map/usages/core/CoreDataSet-UsageCoreTest.json`</p>
    <pre>
    {
      "resourceType" : "CoreDataSet",
      "logicalId" : "UUID",
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
      "id" : "UUID",
      "type" : "transaction",
      "entry" : [{
        "fullUrl" : "https://aphp.fr/Patient/f133b3c0-ccd8-4435-9ead-40b441c2154d",
        "resource" : {
          "resourceType" : "Patient",
          "id" : "f133b3c0-ccd8-4435-9ead-40b441c2154d",
          "identifier" : [{
            "use" : "official",
            "type" : {
              "coding" : [{
                "system" : "https://hl7.fr/ig/fhir/core/CodeSystem/fr-core-cs-v2-0203",
                "code" : "INS-NIR"
              }]
            },
            "system" : "urn:oid:1.2.250.1.213.1.4.8",
            "value" : "1234567890123"
          }],
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
          "url" : "Patient/f133b3c0-ccd8-4435-9ead-40b441c2154d"
        }
      }]
    }
    </pre>
  </li>
  <li>
    <p><b>Transformation d'une instance de FHIR vers une instance OMOP (format le livraison)</b> :</p>
    <p>Dans VSCode, ouvrir le fichier `input/fml/usages/core/StrucutreMap-CoreFHIR2OMOP.fml`, puis dans le menu contextuel (clic droit dans le fichier) choisir l'entrée `Validate StructureMap (With input selection)`, puis choisir le fichier `input/test-map/usages/core/Bundle-UsageCoreTest.json` ou bien prendre le résultat de la transformation précédente</p>
    <p><b>Le résultat doit être équivalent à</b> : `input//test-map/usages/core/OMOP-UsageCoreTest.json`</p>
    <pre>
    {
      "resourceType" : "LogicalBundle",
      "logicalId" : "UUID",
      "type" : "transaction",
      "entry" : [{
        "person" : {
          "gender_concept_id" : {
            "reference" : "Concept/8507"
          },
          "year_of_birth" : 1948,
          "month_of_birth" : 7,
          "day_of_birth" : 16,
          "birth_datetime" : "1948-07-16",
          "person_source_value" : "f133b3c0-ccd8-4435-9ead-40b441c2154d",
          "gender_source_value" : "male"
        }
      }]
    }
    </pre>
  </li>
</ol>

#### D'une réponse au questionnaire des variables socles V2

<ol>
  <li>
    <p><b>Un exemple de réponse issue du <a href="Questionnaire-UsageCore.html">questionnaire des variables socles</a></b> :</p>
    <p>On peut  utiliser le <a href="https://lhcforms.nlm.nih.gov/lhcforms">LHC-Forms Widget</a>, un outil open source qui propose une interface de saisie et qui génère la ressource QuestionnaireResponse correspondant aux données saisies dans l'interface : 
      <ol>
        <li>On charge <a href="Questionnaire-UsageCore.html">le JSON du Questionnaire</a> via le bouton vert "Load From File",</li>
        <li>On saisi les données que l'on souhaite dans l'interface,</li>
        <li>On enregistre la ressource QuestionnaireResponse via le bouton bleu "Show Form Data As ..." en choisissant l'option "FHIR SDC QuestionnaireResponse"</li>
      </ol>
    </p>
    <p><b>Le résultat</b> : <a href="QuestionnaireResponse-test-usage-core-complet.html">un exemple de réponse</a></p>
  </li>
  <li>
    <p><b>Transformation d'une ressource `QuestionnaireResponse` en une instance du modèle physique de notre DPI théorique</b> :</p>
    <p>Dans VSCode, ouvrir le fichier `input/fml/usages/core/StructureMap-CoreBusiness2Physical.fml`, puis dans le menu contextuel (clic droit dans le fichier) choisir l'entrée `Validate StructureMap (With input selection)`, puis choisir le fichier `input/test-map/usages/core/QuestionnaireResponse-test-usage-core-complet.json`</p>
    <p><b>Le résultat doit être équivalent à</b> : `input/test-map/usages/core/CoreDataSet-UsageCoreTestFull.json`</p>
    <pre>
    {
      "resourceType" : "CoreDataSet",
      "logicalId" : "045b10f4-040d-4eb1-929c-6048dea8a312",
      "patient" : {
        "patientNi" : 1,
        "name" : "doe",
        "firstName" : "john",
        "gender" : "h",
        "birthDate" : "1948-07-16",
        "nir" : "1234567890123"
      },
      "address" : [{
        "patientNi" : {
          "reference" : "PatientCore/1"
        },
        "latitude" : 49.451697,
        "longitude" : 1.095129
      }],
      "diag" : [{
        "patientNi" : {
          "reference" : "PatientCore/1"
        },
        "code" : "I10",
        "codeType" : "DP"
      },
      {
        "patientNi" : {
          "reference" : "PatientCore/1"
        },
        "code" : "I10",
        "codeType" : "DAS"
      }],
      "acte" : [{
        "patientNi" : {
          "reference" : "PatientCore/1"
        },
        "code" : "HFFC0044",
        "dateStart" : "2025-06-16T10:31:29.148Z",
        "dateEnd" : "2025-06-16T10:31:29.148Z"
      }]
    }
    </pre>
  </li>
  <li>
    <p><b>Transformation d'une instance de DPI générique vers une instance FHIR (couche sémantique)</b> :</p>
    <p>Dans VSCode, ouvrir le fichier `input/fml/usages/core/StructureMap-CorePhysical2FHIR.fml`, puis dans le menu contextuel (clic droit dans le fichier) choisir l'entrée `Validate StructureMap (With input selection)`, puis choisir le fichier `input/test-map/usages/core/CoreDataSet-UsageCoreTestFull.json` ou bien prendre le résultat de la transformation précédente</p>
    <p><b>Le résultat doit être équivalent à</b> : `input/test-map/usages/core/Bundle-UsageCoreTestFull.json`</p>
    <pre>
    {
      "resourceType" : "Bundle",
      "id" : "2abf7f4c-bd1f-431f-a4c8-667cfa425baf",
      "type" : "transaction",
      "entry" : [{
        "fullUrl" : "https://aphp.fr/Patient/c9ceac8e-8ae4-4cb7-8e99-82549909ce29",
        "resource" : {
          "resourceType" : "Patient",
          "id" : "c9ceac8e-8ae4-4cb7-8e99-82549909ce29",
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
          "birthDate" : "1948-07-16",
          "address" : [{
            "extension" : [{
              "extension" : [{
                "url" : "latitude",
                "valueDecimal" : 49.2
              },
              {
                "url" : "longitude",
                "valueDecimal" : 1.2
              }],
              "url" : "http://hl7.org/fhir/StructureDefinition/geolocation"
            }],
            "use" : "home",
            "text" : "18 Grand Rue",
            "city" : "Dampierre",
            "postalCode" : "78720",
            "country" : "France"
          },
          {
            "extension" : [{
              "extension" : [{
                "url" : "latitude",
                "valueDecimal" : 49.451697
              },
              {
                "url" : "longitude",
                "valueDecimal" : 1.095129
              }],
              "url" : "http://hl7.org/fhir/StructureDefinition/geolocation"
            }],
            "use" : "old",
            "text" : "1 rue Malatiré",
            "city" : "Rouen",
            "postalCode" : "76000",
            "country" : "France"
          }]
        },
        "request" : {
          "method" : "POST",
          "url" : "Patient/c9ceac8e-8ae4-4cb7-8e99-82549909ce29"
        }
      },
      {
        "fullUrl" : "https://aphp.fr/Encounter/0c3bd64b-9f64-456a-b40f-de7a28366f9d",
        "resource" : {
          "resourceType" : "Encounter",
          "id" : "0c3bd64b-9f64-456a-b40f-de7a28366f9d",
          "meta" : {
            "source" : "https://aphp.fr/fhir/Endpoint/dpi/SejourTable/1"
          },
          "status" : "finished",
          "class" : {
            "system" : "http://terminology.hl7.org/CodeSystem/v3-ActCode",
            "code" : "IMP",
            "display" : "inpatient encounter"
          },
          "subject" : {
            "reference" : "Patient/c9ceac8e-8ae4-4cb7-8e99-82549909ce29"
          },
          "period" : {
            "start" : "2025-02-04",
            "end" : "2025-02-05"
          }
        },
        "request" : {
          "method" : "POST",
          "url" : "Encounter/0c3bd64b-9f64-456a-b40f-de7a28366f9d"
        }
      },
      {
        "fullUrl" : "https://aphp.fr/Procedure/779a5b0a-013e-4872-b8ce-6a2ee307d240",
        "resource" : {
          "resourceType" : "Procedure",
          "id" : "779a5b0a-013e-4872-b8ce-6a2ee307d240",
          "meta" : {
            "source" : "https://aphp.fr/fhir/Endpoint/dpi/ActeTable/1"
          },
          "status" : "completed",
          "code" : {
            "coding" : [{
              "system" : "https://smt.esante.gouv.fr/terminologie-ccam",
              "code" : "HFFC0044"
            }]
          },
          "subject" : {
            "reference" : "Patient/c9ceac8e-8ae4-4cb7-8e99-82549909ce29"
          },
          "encounter" : {
            "reference" : "Encounter/0c3bd64b-9f64-456a-b40f-de7a28366f9d"
          },
          "performedPeriod" : {
            "start" : "2025-02-04T10:00:00Z",
            "end" : "2025-02-04T12:30:00Z"
          }
        },
        "request" : {
          "method" : "POST",
          "url" : "Procedure/779a5b0a-013e-4872-b8ce-6a2ee307d240"
        }
      },
      {
        "fullUrl" : "https://aphp.fr/Condition/579e3f8d-0716-40a1-9eec-694393f59209",
        "resource" : {
          "resourceType" : "Condition",
          "id" : "579e3f8d-0716-40a1-9eec-694393f59209",
          "meta" : {
            "source" : "https://aphp.fr/fhir/Endpoint/dpi/DiagTable/1"
          },
          "category" : [{
            "coding" : [{
              "system" : "http://terminology.hl7.org/CodeSystem/condition-category",
              "code" : "encounter-diagnosis",
              "display" : "Encounter Diagnosis"
            }]
          }],
          "code" : {
            "coding" : [{
              "system" : "http://hl7.org/fhir/sid/icd-10",
              "code" : "I10"
            }]
          },
          "subject" : {
            "reference" : "Patient/c9ceac8e-8ae4-4cb7-8e99-82549909ce29"
          },
          "encounter" : {
            "reference" : "Encounter/0c3bd64b-9f64-456a-b40f-de7a28366f9d"
          }
        },
        "request" : {
          "method" : "POST",
          "url" : "Condition/579e3f8d-0716-40a1-9eec-694393f59209"
        }
      },
      {
        "fullUrl" : "https://aphp.fr/Observation/79195715-0c2d-45b5-80d1-992d216c084f",
        "resource" : {
          "resourceType" : "Observation",
          "id" : "79195715-0c2d-45b5-80d1-992d216c084f",
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
            "reference" : "Patient/c9ceac8e-8ae4-4cb7-8e99-82549909ce29"
          },
          "encounter" : {
            "reference" : "Encounter/0c3bd64b-9f64-456a-b40f-de7a28366f9d"
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
          "url" : "Observation/79195715-0c2d-45b5-80d1-992d216c084f"
        }
      },
      {
        "fullUrl" : "https://aphp.fr/Encounter/16d06e18-073e-42b2-b9a1-3ff5d61c5623",
        "resource" : {
          "resourceType" : "Encounter",
          "id" : "16d06e18-073e-42b2-b9a1-3ff5d61c5623",
          "meta" : {
            "source" : "https://aphp.fr/fhir/Endpoint/dpi/SejourTable/2"
          },
          "status" : "finished",
          "class" : {
            "system" : "http://terminology.hl7.org/CodeSystem/v3-ActCode",
            "code" : "IMP",
            "display" : "inpatient encounter"
          },
          "subject" : {
            "reference" : "Patient/c9ceac8e-8ae4-4cb7-8e99-82549909ce29"
          },
          "period" : {
            "start" : "2025-03-04"
          }
        },
        "request" : {
          "method" : "POST",
          "url" : "Encounter/16d06e18-073e-42b2-b9a1-3ff5d61c5623"
        }
      },
      {
        "fullUrl" : "https://aphp.fr/Condition/a81b1210-77ef-4008-85b0-07d6334feaad",
        "resource" : {
          "resourceType" : "Condition",
          "id" : "a81b1210-77ef-4008-85b0-07d6334feaad",
          "meta" : {
            "source" : "https://aphp.fr/fhir/Endpoint/dpi/DiagTable/2"
          },
          "category" : [{
            "coding" : [{
              "system" : "http://terminology.hl7.org/CodeSystem/condition-category",
              "code" : "encounter-diagnosis",
              "display" : "Encounter Diagnosis"
            }]
          }],
          "code" : {
            "coding" : [{
              "system" : "http://hl7.org/fhir/sid/icd-10",
              "code" : "I10"
            }]
          },
          "subject" : {
            "reference" : "Patient/c9ceac8e-8ae4-4cb7-8e99-82549909ce29"
          },
          "encounter" : {
            "reference" : "Encounter/16d06e18-073e-42b2-b9a1-3ff5d61c5623"
          }
        },
        "request" : {
          "method" : "POST",
          "url" : "Condition/a81b1210-77ef-4008-85b0-07d6334feaad"
        }
      }]
    }
    </pre>
  </li>
  <li>
    <p><b>Transformation d'une instance de FHIR vers une instance OMOP (format le livraison)</b> :</p>
    <p>Dans VSCode, ouvrir le fichier `input/fml/usages/core/StrucutreMap-CoreFHIR2OMOP.fml`, puis dans le menu contextuel (clic droit dans le fichier) choisir l'entrée `Validate StructureMap (With input selection)`, puis choisir le fichier `input/test-map/usages/core/Bundle-UsageCoreTestFull.json` ou bien prendre le résultat de la transformation précédente</p>
    <p><b>Le résultat doit être équivalent à</b> : `input//test-map/usages/core/OMOP-UsageCoreTestFull.json`</p>
    <pre>
    
    </pre>
  </li>
</ol>
