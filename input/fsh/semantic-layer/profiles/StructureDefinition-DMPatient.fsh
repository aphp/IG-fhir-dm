Profile: DMPatient
Parent: FRCorePatientINSProfile
Title: "Patient"
Description: "Profil Patient du socle commun des EDSH"

* identifier[NSS] MS

/*
* identifier contains
    INS-NIR 0..*

* identifier[INS-NIR] ^short = "INS-NIR - The patient national health identifier INS obtained by requesting the national patient identification service (CNAM) called the INSi teleservice. Identifiant national de santé (NIR) du patient INS provenant du téléservice INSi (service national d'identification des patients (CNAM))"
* identifier[INS-NIR].use = #official
* identifier[INS-NIR].type = $fr-core-cs-v2-0203#INS-NIR
* identifier[INS-NIR].system = "urn:oid:1.2.250.1.213.1.4.8"
* identifier[INS-NIR].system ^short = "Autorité d'affectation des INS-NIR"
* identifier[INS-NIR].value 1..
* identifier[INS-NIR] MS

* gender MS
* gender from $fr-core-vs-patient-gender-INS (required)
* gender ^short = "male | female | unknown"

* birthDate MS
*/
* deceased[x] MS
* deceased[x] 
  * extension contains
    DeathSource named DeathSource 0..1

* address MS 
* address only DMAddress

* multipleBirthInteger MS