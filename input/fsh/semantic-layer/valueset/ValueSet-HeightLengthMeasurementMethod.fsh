ValueSet: HeightLengthMeasurementMethod
Title: "Height Length Measurement Method"
Description: "SELECT SNOMED CT code system values that describe how the height/length was measured."
* ^copyright = "This value set includes content from SNOMED CT, which is copyright © 2002+ International Health Terminology Standards Development Organisation (IHTSDO), and distributed by agreement between IHTSDO and HL7. Implementer use of SNOMED CT is not covered by this agreement"
* $sct#414135002 "Estimated (qualifier value)"
* $sct#258104002 "Measured (qualifier value)"
* $sct#733985002 "Reported (qualifier value)"

Instance: 11ea4e94-9b76-43c4-9b42-159582728c14
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(HeightLengthMeasurementMethod)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"