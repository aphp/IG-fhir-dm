Profile: DMObservationLaboratoryAlat
Parent: DMObservationLaboratoryGeneric
Title: "Alanine aminotransférase (ALAT)"
Description: """
Taux d'ALAT dans le sang. L'alanine-aminotransférase est capable de transférer le groupement amine de l'acide glutamique sur l'acide pyruvique avec formation d'une molécule d'acide α-cétoglutarique et d'alanine.
"""

* code = $loinc#1743-4 "Alanine aminotransférase [Catalytique/Volume] Sérum/Plasma ; Numérique ; Avec phosphate de pyridoxal" (exactly)

* value[x] only Quantity
* valueQuantity.value ^short = "Valeur mesurée"
* valueQuantity.system = $ucum (exactly)
* valueQuantity.code = #[IU]/L (exactly)
* valueQuantity.unit = "[IU]/L"


Instance: 4244bd90-f876-4507-945f-7f57c116e6c2
InstanceOf: Provenance
Title: "Modification du nom du profil pour respect des conventions"
Description: """Modification du nom du profil pour respect des conventions"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryAlat)
* occurredDateTime = "2025-11-10"
* reason.text = """Modification du nom du profil pour respect des conventions"""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-11-10T16:00:00+02:00"

Instance: 6b8b7a13-8482-474b-83c7-d65be26142a4
InstanceOf: Provenance
Title: "Ajout du profil pour les alat qui était manquant"
Description: """Ajout du profil pour les alat qui était manquant"""
Usage: #definition

* target[0] = Reference(DMObservationLaboratoryAlat)
* occurredDateTime = "2025-10-16"
* reason.text = """Ajout du profil pour les alat qui était manquant"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-10-16T14:43:23+02:00"
