ValueSet: DMExerciceStatusType
Title: "Exercice Status Type"
Description: "Type d'activité physique"

* ^experimental = false
* ^immutable = false

* $loinc#68516-4 "On those days that you engage in moderate to strenuous exercise, how many minutes, on average, do you exercise"
* $loinc#89555-7 "How many days per week did you engage in moderate to strenuous physical activity in the last 30 days"

Instance: 97e06a30-044c-423a-b449-9437e34d0ca3
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DMExerciceStatusType)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"