Profile: DMObservationLaboratoryGeneric
Parent: Observation // pas de profil ANS (et le profil mesure glucose me semble inadapté), pas de profil FHIR, uscore propose un profil lab générique.
Title: "Résultat de laboratoire"
Description: """
Profil générique des résultats de laboratoire du socle commun des EDS.
"""

* ^abstract = true

* status MS // restreindre à final, amended et corrected ? Enfait, le GT demande un status, mais il n'y a pas de place dans OMOP pour cela. 

* category MS
* category 1..1
* category = $observation-category#laboratory (exactly)

* code MS
* code from DMLaboratory (required)

* subject MS
* subject only Reference(DMPatient)
* subject ^short = "L'observation concerne la personne que l'on analyse."

* effective[x] MS

* value[x] MS

* obeys dm-lab-1
* obeys dm-lab-2
* obeys dm-lab-3
* obeys dm-lab-4
* obeys dm-lab-5
* obeys dm-lab-6

* component MS
  * code MS
  * code from DMLaboratory (required) // créer le VS et le CS

  * value[x] MS

  * referenceRange MS