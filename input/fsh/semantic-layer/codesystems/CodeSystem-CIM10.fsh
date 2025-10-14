CodeSystem: CIM10
Title: "CIM 10 PMSI"
Description: "CIM 10 ATIH pour le PMSI"

* ^status = #active
* ^experimental = false
* ^content = #fragment
* ^hierarchyMeaning = #grouped-by
* ^caseSensitive = false

* ^property[0].code = #typeMcoHad
* ^property[=].description = """Le Type MCO/HAD est destiné à permettre d'établir la distinction entre les codes autorisés dans les RUM (RPSS pour HAD), et ceux qui sont interdits.

Il faut noter que cette information est redondante par rapport au contenu de la table
DIAG10CR de la FG MCO, utilisée par le moteur de groupage (cf. la fonction groupage
MCO), puisque ce moteur doit pouvoir fonctionner même en l'absence de tables de
libellés.

**Valeurs prises par le champ Type MCO/HAD**
- 0 : Pas de restriction particulière (valeur par défaut).
- 1 : Diagnostic interdit en DP et DR - Autorisé ailleurs
- 2 : Diagnostic interdit en DP et DR - Cause externe de morbidité
- 3 : Diagnostic interdit en DP, DR et DA - Catégories et sous-catégories non vides ou code père
interdit
- 4 : Diagnostic interdit en DP - Autorisé ailleurs
"""
* ^property[=].type = #code

* #I10 "Hypertension essentielle"
* #I10 ^property[+].code = #typeMcoHad
* #I10 ^property[=].valueCode = #0
* #J41.1 "Bronchite chronique mucopurulente"
* #J41.1 ^property[+].code = #typeMcoHad
* #J41.1 ^property[=].valueCode = #0

Instance: c3d4e5f6-7a8b-9c0d-1e2f-3a4b5c6d7e8f
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(CIM10)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"
