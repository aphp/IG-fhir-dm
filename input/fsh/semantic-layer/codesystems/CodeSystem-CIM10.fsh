CodeSystem: CIM10
Title: "CIM 10 PMSI"
Description: "CIM 10 ATIH pour le PMSI"

* ^status = #active
* ^experimental = false
* ^content = #not-present
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
