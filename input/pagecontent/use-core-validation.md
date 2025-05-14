
#### D'une réponse au questionnaire des variables socles à OMOP

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
    <p><b>Le résultat</b> : <a href="QuestionnaireResponse-qr-test-usage-core.html">un exemple de réponse</a></p>
  </li>
  <li>
    <p><b>Transformation d'une ressource `QuestionnaireResponse` en une instance du modèle physique de notre DPI théorique</b> :</p>
    <p>Dans VSCode, ouvrir le fichier `input/fml/usages/core/StructureMap-CoreBusiness2Physical.fml`, puis dans le menu contextuel (clic droit dans le fichier) choisir l'entrée `Validate StructureMap (With input selection)`, puis choisir le fichier `input/test-map/usages/core/QuestionnaireResponse-UsageCoreTest.json`</p>
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
