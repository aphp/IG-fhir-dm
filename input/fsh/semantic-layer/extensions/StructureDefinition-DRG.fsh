Extension: DRG
Title: "Groupe Homogène de Malade"
Description: "Cette extension permet de renseigner le Groupe Homogène de Malade dans lequel le séjour a été classé en R4"
* ^status = #draft
* ^context[0].type = #element
* ^context[=].expression = "Claim"
* . 0..1
* value[x] 0..0

* extension contains
  GHM 0..1 and 
  codeRetour 0..1 and
  vClassif 0..1

* extension[GHM] only Extension
* extension[GHM] ^short = "GHM pour ce séjour"
* extension[GHM] ^definition = "Il s'agit de porter le GHM dans lequel le séjour a été groupé."
* extension[GHM].url only uri
* extension[GHM].value[x] 1..1
* extension[GHM].value[x] only CodeableConcept
* extension[GHM].valueCodeableConcept from GHMVS

* extension[codeRetour] only Extension
* extension[codeRetour] ^short = "Code retour de la fonction groupage"
* extension[codeRetour] ^definition = "Porte le code retour de la fonction groupage."
* extension[codeRetour].url only uri
* extension[codeRetour].value[x] 1..1
* extension[codeRetour].value[x] only string

* extension[vClassif] only Extension
* extension[vClassif] ^short = "version de la classification des GHM"
* extension[vClassif] ^definition = "version"
* extension[vClassif].url only uri
* extension[vClassif].value[x] 1..1
* extension[vClassif].value[x] only string