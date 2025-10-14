ValueSet: BloodPressureMeasurementMethod
Title: "Blood Pressure Measurement Method"
Description: "SELECT SNOMED CT code system values that describe how a blood pressure was measured."

* ^copyright = "This value set includes content from SNOMED CT, which is copyright © 2002+ International Health Terminology Standards Development Organisation (IHTSDO), and distributed by agreement between IHTSDO and HL7. Implementer use of SNOMED CT is not covered by this agreement"
* $sct#77938009 "Arterial pressure monitoring, invasive method (regime/therapy)"
* $sct#17146006 "Arterial pressure monitoring, non-invasive method (regime/therapy)"
* $sct#37931006 "Auscultation (procedure)"
* $sct#765172009 "Doppler ultrasound (procedure)"
* $sct#13385008 "Mediate auscultation (procedure)"
* $sct#113011001 "Palpation (procedure)"
* $sct#31813000 "Vascular oscillometry (procedure)"
* SolorTemporary#911000205109 "Measurement of blood pressure using intravascular transducer (procedure)"
* SolorTemporary#641000205104 "Auscultation - automatic (procedure)"

Instance: e98e8d34-4e08-432d-ada8-f6d9dcf48ef3
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(BloodPressureMeasurementMethod)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"