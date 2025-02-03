Logical: UseCoreQuestionnaire
Parent: Base
Characteristics: #can-be-target
Title: "Core - Questionnaire"
Description: """
Lien vers le questionnaire pour l'usage Core.
"""

* episode 1..1 Reference(UseCoreContactSystemeSante) "Contact"
* questionnaire 1..1 Reference(Questionnaire) "Questionnaire"
* questionnaire = Reference(Questionnaire/UsageCore) (exactly)