ValueSet: DMObservationSmokingStatusStatus
Title: "Liste des status pour l'Observation de consommation de tabac"
Description: "Codes providing the status of an observation for smoking status. Constrained to `final`and `entered-in-error`."

* ^status = #active
* ^experimental = false

* ObservationStatus#final
* ObservationStatus#entered-in-error

Instance: aff10949-8fce-4546-88b6-6f8e347eeb3d
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DMObservationSmokingStatusStatus)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"