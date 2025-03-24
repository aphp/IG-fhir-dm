Profile: DMClaimRSS
Parent: DMClaimPMSIMCO
Title: "RSS du PMSI MCO"
Description: "Profil pour les Résumés de Sortie Standardisé (RSS) du PMSI MCO."

* billablePeriod.start ^short = "date d'entrée dans la première unité médicale visitée"
* billablePeriod.end ^short = "date de sortie de la dernière unité médicale visitée"
* billablePeriod MS

* supportingInfo ^slicing.discriminator[0].type = #value
* supportingInfo ^slicing.discriminator[=].path = "code.coding.code"
* supportingInfo ^slicing.discriminator[+].type = #value
* supportingInfo ^slicing.discriminator[=].path = "code.coding.system"
* supportingInfo ^slicing.description = "Slicing de supportingInfo"
* supportingInfo ^slicing.rules = #open
* supportingInfo ^short = "supportingInfo"
* supportingInfo contains
    ModeIn 1..1 MS
    and ModeOut 1..1 MS

* supportingInfo[ModeIn]
  * category = FrClaimSupInfoCategoryPMSIMCO#RUM (exactly)
  * code
    * coding ^slicing.discriminator[0].type = #value
    * coding ^slicing.discriminator[=].path = "code"
    * coding ^slicing.discriminator[+].type = #value
    * coding ^slicing.discriminator[=].path = "system"
    * coding ^slicing.rules = #open
    * coding contains 
        ModeInCode 1..1 MS

    * coding[ModeInCode]
      * system = $ClaimMode (exactly)
      * code = #0 (exactly)
      
  * value[x] only string
  * valueString ^short = "valeur du mode d'entrée"
  * valueString MS

* supportingInfo[ModeOut]
  * category = FrClaimSupInfoCategoryPMSIMCO#RUM (exactly)
  * code
    * coding ^slicing.discriminator[0].type = #value
    * coding ^slicing.discriminator[=].path = "code"
    * coding ^slicing.discriminator[+].type = #value
    * coding ^slicing.discriminator[=].path = "system"
    * coding ^slicing.rules = #open
    * coding contains 
        ModeOutCode 1..1 MS

    * coding[ModeOutCode]
      * system = $ClaimMode (exactly)
      * code = #1 (exactly)

  * value[x] only string
  * valueString ^short = "valeur du mode de sortie"
  * valueString MS

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
  * procedureCodeableConcept from CCAM