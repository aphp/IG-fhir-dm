CodeSystem: Ccam
Title: "CCAM illustrative"
Description: "Fragment de CCAM permettant d'illustrer l'utilisation des codes CCAM dans les ressources procedures. Idéalement, il faudrait disposer d'une CCAM descriptive dans un serveur de terminologie FHIR. Pour l'heure, on ne dispose que d'une ccam facturante sur le SMT de l'ANS, sans ValueSet associés."

* ^status = #active
* ^experimental = false
* ^content = #fragment
* ^hierarchyMeaning = #grouped-by
* ^caseSensitive = false

* #BGQP002...01. "Examen du fond d'oeil par biomicroscopie avec verre de contact - Phase par defaut - 1° activité chir/med - NA"
* #DEQP003...01. "Électrocardiographie sur au moins 12 dérivations - Phase par defaut - 1° activité chir/med - NA"
* #HFFC0044 "Cholécystectomie, par coelioscopie - anesthésie"
* #DDAF007 "Dilatation intraluminale de 2 vaisseaux coronaires avec artériographie coronaire, avec pose d'endoprothèse, par voie artérielle transcutanée"
* #DEQP003 "Électrocardiographie sur au moins 12 dérivations"
* #HEQE002 "Endoscopie oeso-gastro-duodénale"
* #JQGD010 "Accouchement céphalique unique par voie naturelle, chez une primipare"
* #GELD004 "Intubation trachéale"
* #DDQH012 "Artériographie coronaire avec ventriculographie gauche, par voie artérielle transcutanée"
* #DDQH009 "Artériographie coronaire sans ventriculographie gauche, par voie artérielle transcutanée"
* #ACQJ002 "Remnographie [IRM] du crâne et de son contenu, avec injection intraveineuse de produit de contraste"
* #NBCA008 "Ostéosynthèse de fracture du grand trochanter"
* #HPHB003 "Ponction d'un épanchement péritonéal, par voie transcutanée"
* #GLQP008 "Mesure de la capacité vitale lente et de l'expiration forcée, avec gazométrie sanguine artérielle [Spirométrie standard avec gaz du sang]"


Instance: 65fd8653-66bb-4219-b02b-803af9bc1ef0 
InstanceOf: Provenance
Title: "ajout des codes CCAM pour la validation des cas de test"
Description: """ajout des codes CCAM pour la validation des cas de test"""
Usage: #definition

* target[0] = Reference(Ccam)
* occurredDateTime = "2025-10-16"
* reason.text = """ajout des codes CCAM pour la validation des cas de test"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "Nicolas Griffon"
* recorded = "2025-10-16T18:00:00+02:00"

Instance: d4e5f6a7-8b9c-0d1e-2f3a-4b5c6d7e8f9a
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(Ccam)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"