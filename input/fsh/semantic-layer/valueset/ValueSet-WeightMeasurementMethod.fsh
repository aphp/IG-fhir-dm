ValueSet: WeightMeasurementMethod
Title: "Weight Measurement Method"
Description: "SELECT SNOMED CT code system values that describe how the weight was measured."

* ^experimental = false
* ^immutable = false
* ^copyright = "This value set includes content from SNOMED CT, which is copyright © 2002+ International Health Terminology Standards Development Organisation (IHTSDO), and distributed by agreement between IHTSDO and HL7. Implementer use of SNOMED CT is not covered by this agreement"

* $sct#414135002 "Estimated (qualifier value)"
* $sct#258104002 "Measured (qualifier value)"
* $sct#733985002 "Reported (qualifier value)"

Instance: b24c6e2f-5706-4bf9-842d-2a8130694e19
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(WeightMeasurementMethod)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"