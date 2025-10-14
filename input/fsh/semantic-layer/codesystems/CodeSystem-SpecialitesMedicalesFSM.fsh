CodeSystem: SpecialitesMedicalesFSM
Id:         SpecialitesMedicalesFSM
Title:     "Specialités médicales au sens de la Fédération des Spécialités Médicales (FSM)"
Description: "CodeSystem reprenant les spécialités médicales listés par la FSM. En pratique, il s'agit des spécialités représentées par un Conseil National Professionnel au sein de la FSM. Voir ici : https://specialitesmedicales.org/la-fsm/a-propos/presentation-fsm/"

* ^experimental = false
* ^caseSensitive = true
* ^status = #active
* ^content = #complete
* ^hierarchyMeaning = #grouped-by

* #addiction "Addictologie"
* #intensivecare "Médecine Intensive et Réanimation"
* #emergency "Médecine d'Urgence"
* #endocrinology "Endocrinologie, Diabétologie et Nutrition"
* #gynecology "Gynécologie Obstétrique et Gynécologie Médicale"
* #hematology "Hématologie"
* #oncology "Oncologie"
* #pediatrics "Pédiatrie"
* #publichealth "Santé Publique"
* #urology "Urologie"

/* 
* #àfaire "Anatomie et Cytologie Pathologiques"
* #àfaire "Anesthésie-Réanimation et Médecine péri-opératoire"
* #àfaire "Biologie Médicale"
* #àfaire "Chirurgie Maxillo-Faciale, Stomatologie et Chirurgie Orale Médicale"
* #àfaire "Chirurgie Orthopédique et Traumatologique"
* #àfaire "Chirurgie de l'Enfant et de l'Adolescent"
* #àfaire "Chirurgie Plastique, Reconstructrice et Esthétique"
* #àfaire "Chirurgie Thoracique et Cardio-Vasculaire"
* #àfaire "Chirurgie Vasculaire et Endovasculaire"
* #àfaire "Chirurgie Viscérale et Digestive"
* #àfaire "Dermatologie et Vénéréologie"
* #àfaire "Endocrinologie, Diabétologie et Nutrition"
* #geriatrics "Gériatrie"
* #àfaire "Génétique Clinique, Chromosomique et Moléculaire"
* #àfaire "Hépato Gastro Entérologie"
* #àfaire "Médecine du Sport"
* #àfaire "Médecine du Travail"
* #àfaire "Médecine Interne"
* #àfaire "Médecine Nucléaire"
* #àfaire "Médecine Palliative"
* #àfaire "Médecine Physique et Réadaptation"
* #àfaire "Néphrologie"
* #àfaire "Neurochirurgie"
* #àfaire "Neurologie"
* #àfaire "ORL et CCF"
* #àfaire "Ophtalmologie"
* #àfaire "Pneumologie"
* #àfaire "Psychiatrie"
* #àfaire "Rhumatologie"
* #àfaire "Allergologie"
* #àfaire "Maladies Infectieuses et Tropicales"
* #àfaire "Médecine Légale et Expertise Médicale"
* #àfaire "Médecine Vasculaire"
* #àfaire "Biologie des agents infectieux-Hygiène hospitalière"
* #àfaire "Cardiovasculaire"
* #àfaire "Radiologie et Imagerie Médicale"
* #àfaire "Orthopédie Dento-Faciale - Orthopédie Dento-Maxillo-Faciale"
* #àfaire "Vigilance et Thérapeutique Transfusionnelles, Tissulaires et Cellulaires"
*/


/*  Les vieux : 
* #maternity "Maternité"
* #pediatric "Pédiatrie"
  * #pediatric-growth "Croissance pédiatrique"
* #reanimation "Réanimation"
  * #catheters "Cathéters"

remplacé dans l'IG, dans l'arbo, le yaml
voir dans le FB de prod ?

*/

Instance: a1b2c3d4-5e6f-7a8b-9c0d-1e2f3a4b5c6d
InstanceOf: Provenance
Title: "refactor(docs): reorganize knowledge acquisition process documentation"
Description: """refactor(docs): reorganize knowledge acquisition process documentation"""
Usage: #definition

* target[0] = Reference(SpecialitesMedicalesFSM)
* occurredDateTime = "2025-10-14"
* reason.text = """refactor(docs): reorganize knowledge acquisition process documentation"""
* activity = $v3-DataOperation#UPDATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "David Ouagne"
* recorded = "2025-10-14T11:36:20+02:00"

Instance: b2c3d4e5-6f7a-8b9c-0d1e-2f3a4b5c6d7e
InstanceOf: Provenance
Title: "first import"
Description: """first import"""
Usage: #definition

* target[0] = Reference(SpecialitesMedicalesFSM)
* occurredDateTime = "2025-02-02"
* reason.text = """first import"""
* activity = $v3-DataOperation#CREATE
* agent
  * type = $provenance-participant-type#author
  * who.display = "@ngr"
* recorded = "2025-02-02T21:36:10+01:00"
