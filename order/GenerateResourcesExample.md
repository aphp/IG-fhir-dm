# Transformation QuestionnaireResponse vers Profils FHIR (FSH)

## Contexte
Je travaille sur un guide d'implémentation FHIR et j'ai besoin de transformer des ressources QuestionnaireResponse en instances conformes aux profils définis dans le guide.

## Objectif
Analyser un QuestionnaireResponse fourni et générer des instances FSH (FHIR Shorthand) des profils appropriés basés sur les réponses du questionnaire.

## Inputs fournis

### 1. Liste des profils disponibles
`input/fsh/semantic-layer/profiles/*.fsh`

### 2. QuestionnaireResponse à transformer
`input/resources/usages/core/QuestionnaireResponse-cas-1-usage-core.json`

### 3. Numéro de cas
1

## Tâches attendues

1. **Analyser le QuestionnaireResponse** : Extraire toutes les réponses (item.answer) et leur linkId associé

2. **Mapper vers les profils appropriés** : 
   - Identifier quels profils doivent être instanciés selon les réponses
   - Créer une instance par profil nécessaire
   - Assurer la conformité avec les contraintes des profils

3. **Générer les fichiers FSH** avec :
   - Convention de nommage : `ResourceType-cas-NUMERO-NomSpecifique.fsh`
   - Exemples : 
     - `Patient-cas-01-jean-dupont.fsh`
     - `Observation-cas-01-poids.fsh`
     - `Encounter-cas-01-consultation-initiale.fsh`

4. **Organiser les fichiers** dans : `input\fsh\examples\cas-NUMERO\`

## Format de sortie FSH attendu

Chaque fichier doit contenir :
```fsh
Instance: ResourceType-cas-NUMERO-NomSpecifique
InstanceOf: NomDuProfil
Usage: #example
Title: "Titre descriptif"
Description: "Description de l'instance et son contexte"

* champ1 = "valeur extraite du QuestionnaireResponse"
* champ2 = valeur
// etc.
```

## Critères de qualité

- ✅ Toutes les réponses du QuestionnaireResponse sont utilisées
- ✅ Les instances sont valides selon les profils
- ✅ Les références entre ressources sont correctement établies
- ✅ La convention de nommage est respectée
- ✅ Les fichiers sont dans le bon répertoire
- ✅ Commentaires FSH pour expliquer les mappings complexes

## Questions à poser si nécessaire

Si des informations sont ambiguës ou manquantes dans le QuestionnaireResponse, me demander des clarifications avant de générer les instances.

## Commencer par

1. Lire et comprendre la structure du QuestionnaireResponse
2. Identifier les profils nécessaires
3. Créer le répertoire `input\fsh\examples\cas-NUMERO\` si nécessaire
4. Générer les instances une par une
5. Valider la cohérence globale
