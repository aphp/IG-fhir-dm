Profile: DMAddress
Parent: FRCoreAddressProfile
Title: "Address"
Description: "Profil Address du socle commun des EDS"

* extension contains 
  $geolocation named geolocation 0..1
  and PmsiCodeGeo named PmsiCodeGeo 0..1

* extension[geolocation] MS
* extension[inseeCode] MS
* text MS
* line MS
* city MS
* postalCode MS

Instance: bde2c040-e464-4735-8b9a-e6ace74659ed
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DMAddress)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"
