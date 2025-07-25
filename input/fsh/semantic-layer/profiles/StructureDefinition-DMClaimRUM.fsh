Profile: DMClaimRUM
Parent: DMClaimPMSIMCO
Title: "RUM du PMSI MCO"
Description: "Profil pour les Résumés d'Unité Médicale (RUM) du PMSI MCO."

* extension contains
    DRG named DRG 0..1
    and ItemRank named ItemRank 1..1

* subType 1..1
* subType = FrClaimType#RUM

* billablePeriod.start ^short = "date d'entrée dans la première unité médicale visitée"
* billablePeriod.end ^short = "date de sortie de la dernière unité médicale visitée"
* billablePeriod MS

* diagnosis MS
* diagnosis ^slicing.discriminator[+].type = #value
* diagnosis ^slicing.discriminator[=].path = "type"
* diagnosis ^slicing.description = "slicing permettant de préciser le binding terminologique des codes diagnostics en fonction de leur type"
* diagnosis ^slicing.rules = #open
* diagnosis contains
  dp 1..1 MS
  and dr 0..1 MS
  and da 0..* MS
  and dad 0..* MS

* diagnosis[dp]
  * diagnosis[x] only CodeableConcept
  * diagnosisCodeableConcept from CIM10PMSIDP
  * type = PMSIMCODiagType#DP (exactly)

* diagnosis[dr]
  * diagnosis[x] only CodeableConcept
  * diagnosisCodeableConcept from CIM10PMSIDR
  * type = PMSIMCODiagType#DR (exactly)

* diagnosis[da]
  * diagnosis[x] only CodeableConcept
  * diagnosisCodeableConcept from CIM10PMSIDA
  * type = PMSIMCODiagType#DA (exactly)

* diagnosis[dad]
  * diagnosis[x] only CodeableConcept
  * diagnosisCodeableConcept from CIM10PMSI
  * type = PMSIMCODiagType#DAD (exactly)

* procedure MS
* procedure
  * procedure[x] only CodeableConcept
  * procedureCodeableConcept from CcamVS

* item.category from FrMCOClaimItemCategory (required)

* item ^slicing.discriminator[+].type = #value
* item ^slicing.discriminator[=].path = "category"
* item ^slicing.rules = #open
* item ^slicing.description = "Slicing des items de claim"
* item contains
    RUMGrouped 0..1 MS
    and CCAMProcedure 0..* MS

* item[RUMGrouped]
  * category 1..1 
  * category = FrMCOClaimItemCategory#1    //RUM
  * productOrService from GHMVS (extensible)

  * modifier ^slicing.discriminator[+].type = #value
  * modifier ^slicing.discriminator[=].path = "coding.system"
  * modifier ^slicing.rules = #open
  * modifier ^slicing.description = "Slicing des modifier pour les items de type RUM"
  * modifier contains
    MDE 1..1 MS and
    MDS 1..1 MS

  * modifier[MDE] ^short = "Mode d'entrée du patient"
  * modifier[MDE].coding.system = "https://aphp.fr/ig/fhir/core/CodeSystem/PMSIMCOMDE"
  * modifier[MDE] from PMSIMCOMDEVS (required)

  * modifier[MDS] ^short = "Mode de sortie du patient"
  * modifier[MDS].coding.system = "https://aphp.fr/ig/fhir/core/CodeSystem/PMSIMCOMDS"
  * modifier[MDS] from PMSIMCOMDSVS (required)



* item[CCAMProcedure]
  * category 1..1
  * category = FrMCOClaimItemCategory#0    //Procédure
  * productOrService from CcamVS (extensible)

