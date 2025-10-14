ValueSet: BloodPressureMeasurementBodyLocationPrecoodinated
Title: "Blood Pressure Measurement Body Location Precoordinated"
Description: "SELECT SNOMED CT code system values that describe the location on the body where the blood pressure was measured."

* ^copyright = "This value set includes content from SNOMED CT, which is copyright © 2002+ International Health Terminology Standards Development Organisation (IHTSDO), and distributed by agreement between IHTSDO and HL7. Implementer use of SNOMED CT is not covered by this agreement"

* $sct#49256001 "Structure of dorsal digital artery of foot (body structure)"
* $sct#368469003 "Structure of proper volar digital arteries (body structure)"
* $sct#17137000 "Structure of brachial artery (body structure)"
* $sct#723961002 "Structure of left brachial artery (body structure)"
* $sct#723962009 "Structure of right brachial artery (body structure)"
* $sct#7657000 "Structure of femoral artery (body structure)"
* $sct#113270003 "Structure of left femoral artery (body structure)"
* $sct#69833005 "Structure of right femoral artery (body structure)"
* $sct#45631007 "Structure of radial artery (body structure)"
* $sct#368504007 "Structure of left radial artery (body structure)"
* $sct#368503001 "Structure of right radial artery (body structure)"
* $sct#13363002 "Structure of posterior tibial artery (body structure)"
* $sct#214912001 "Structure of left posterior tibial artery (body structure)"
* $sct#214811007 "Structure of right posterior tibial artery (body structure)"
* $sct#54247002 "Ascending aorta structure (body structure)"
* $sct#281130003 "Descending aorta structure (body structure)"
* $sct#57034009 "Aortic arch structure (body structure)"
* $sct#7832008 "Abdominal aorta structure (body structure)"

Instance: cd4510db-9337-4350-8a35-4a77e26ab498
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(BloodPressureMeasurementBodyLocationPrecoodinated)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"