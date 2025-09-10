Extension: DeathSource
Title: "Source ayant fournie l'information de décès"
Description: "Cette extension permet de formaliser la source d'information de laquelle est issue le statu vital du patient tel que renseigné dans Patien.deceased[x]"
* ^status = #draft
* ^context[0].type = #element
* ^context[=].expression = "Patient.deceased[x]"
* . 0..1
* value[x] only code
* valueCode from DeathSourcesVs (extensible)