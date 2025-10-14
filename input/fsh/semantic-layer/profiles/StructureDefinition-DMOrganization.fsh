Profile: DMOrganization
Parent: AsOrganizationProfile
Title: "Organization"
Description: "Organization adapted for Data Management"

* partOf only Reference(DMOrganization or AsOrganizationProfile or FRCoreOrganizationProfile)

Instance: f4a5b6c7-8d9e-0f1a-2b3c-4d5e6f7a8b9c
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DMOrganization)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"