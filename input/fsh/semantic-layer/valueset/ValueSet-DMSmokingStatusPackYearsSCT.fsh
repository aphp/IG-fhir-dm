ValueSet: DMSmokingStatusPackYearsSCT
Title: "Smoking Status Pack Years SCT"
Description: "Type de statut tabagique en provenance de SNOMED CT"

* ^experimental = false
* ^immutable = false

* include codes from system $sct
    where concept is-a #401201003
* include codes from system $sct
    where concept is-a #782516008