ValueSet: DMLaboratoryEstimatedDFGUnit
Title: "Liste des unités possibles pour une estimation du débit de filtration glomérulaire - socle des EDS"
Description: """
Deux unités UCUM possibles pour l'estimation du débit de filtration glomérulaire. L'usage des annotations UCUM (partie entre accolades) étant déconseillé, on privilégiera l'utilisation des 'mL/min'.
"""
* ^experimental = false
* ^immutable = false

* include $ucum#mL/min
* include $ucum#mL/min/{1.73_m2}

Instance: 83568547-f6a1-45d6-ac9b-bc55841ba92d
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(DMLaboratoryEstimatedDFGUnit)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"