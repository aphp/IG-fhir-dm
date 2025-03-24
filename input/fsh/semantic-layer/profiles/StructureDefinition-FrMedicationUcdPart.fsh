Profile: FrMedicationUcdPart
Parent: Medication
Id: FrMedicationUcdPart
Title: "French Ucd Part Medication"
Description: "Part of a multipart branded medication."
* code ^short = "Short text that identifies this branded medication part"
* code ^definition = "A short relevant text to discern each part."
* code ^comment = "No code assigned by the regultory authorities, use a short relevant text to discern each part."
* code.coding ..0
* code.coding ^definition = "Code for the part : no code assigned by the regultory authorities"
* code.coding ^comment = "No code but a short text depicting the part. For instance, white tablet for a proprietary named medication made of white tablets and blue tablets"
* code.coding ^requirements = "No code but a text descripting the part."
* code.text 1..
* code.text ^short = "Short plain text representation of the part"
* code.text ^definition = "No regulatory authority label but a text descripting the part. It is a short text, relevant enough to discern the different parts of the medication."
* code.text ^comment = "A short text, relevant enough to discern the different parts of the medication."
* code.text ^requirements = "This is the only way for identifing the part to the medication. However it is not an absolute idenfication."
* manufacturer ..0
* manufacturer ^definition = "No distinct manufacturer for each part of the medication"
* manufacturer ^comment = "No distinct manufacturer for each part. Each part inherits the whole medication manufacturer."
* form 1..
* form from FrMpDoseForm (extensible)
* form ^comment = "This is the defined dose form of this part of the branded medication."
* form ^requirements = "The dose form of the part is always defined and SHALL be provided."
* ingredient ^comment = "For the active ingedients, the medication contains ALL the ingredients and ONLY the ingredients."
* ingredient.item[x] only CodeableConcept or Reference(FrMedicationUcdPart)
* ingredient.item[x] ^short = "The actual substance or sub-part of the part"
* ingredient.item[x] ^definition = "The actual substance or sub-part of the part of the branded medication."
* ingredient.item[x] ^comment = "Most of the few multi-part branded medication have a single level of parts with no sub-parts. For instance, a white tablet and a bue tablet. The item[x].refeence(FrMedicationUcdPart) is intende to describe the very few more complex multipart branded medications."
* ingredient.item[x] ^requirements = "Support of french multi-part branded medication identfied by a code UDC."
* ingredient.strength only FrRatioUcum
* ingredient.strength ^definition = "Specifies how much subtance of the item[x]:codeableConcept(snomedSubstance) or how many of the item[x]:refernce(FrMedciationUcdPart) there are in this FrMedicationUcdPart"
* ingredient.strength ^comment = "The quantity of this ingredient defining the medication. For instance, 50 mg/mL defining the glucose quantity for the glucose 5% or 500 mg medicine and 30 mg respectively defining the paracetamol and the codeine quantity for the association paracetamol+codeine 500 mg+30 mg medicine."
* batch ^definition = "This applies for the proprietary named medication involved in a MedicationDispense, MedicationAdministration or a MedicationUse."
* batch ^comment = "WARNING: it is the batch number of the part.\r\nIf it is not discerned for each part, it SHALL NOT be provided here but at the grouping level where it is defined, most often the UCD."