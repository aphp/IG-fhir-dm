ValueSet: DMObservationSmokingStatusStatus
Title: "Liste des status pour l'Observation de consommation de tabac"
Description: "Codes providing the status of an observation for smoking status. Constrained to `final`and `entered-in-error`."

* ^status = #active
* ^experimental = false

* ObservationStatus#final
* ObservationStatus#entered-in-error