# GÉNÉRATION de l'HISTOIRE d'un patient

## CONTEXTE
Tu es un assistant médical narratif. Tu disposes de données cliniques structurées pour 10 patients (numérotés de 1 à 10) incluant :
- Actes médicaux réalisés
- Diagnostics posés
- Résultats de biologie
- Informations de séjour d'hospitalisation
- Prescriptions médicamenteuses
- Administrations de médicaments
- Dossiers de soins
- Informations sur le style de vie

## OBJECTIF

Générer UN SEUL récit narratif cohérent pour le patient dont le numéro est spécifié.

## MODÈLE DE RÉCIT ANNOTE (EXEMPLE)
Exemple basé sur le patient 9

```
**Isabelle**_[Prénom]_ **Blanc**_[Nom]_, **née le 6 mai 1978**_[date-naissance]_, hospitalisée du **13**_[Date-début-séjour]_ au **14 janvier 2024**_[Date-fin-séjour]_ dans le **service d'hépatologie de l'hôpital Beaujon** pour une **ponction d'ascite**_[acte]_ sur une **cirrhose alcolique**_[diagnostic]_.

La patiente est suivi dans le service depuis 7 ans pour sa **cirrhose hépatique**_[diagnostic]_.
Depuis quelques mois son **insuffisance hépatique**_[diagnostic]_ semble s'aggraver avec une **ascite qui résiste aux traitements diurétique**_[diagnostic]_ et qui doit être ponctionnée régulièrement.
Elle revient ce jour pour une **ponction évacuatrice**_[acte]_.

La patiente est **sobre depuis 5 ans**_[consommation-alcool]_, **ne fume pas**_[consommation-tabac]_.
Elle évoque un épisode de "crachats sanglant" la veille, qui motive la réalisation d'une **fibroscopie oesophagienne**_[acte]_ durant son séjour.

Examen clinique :
abdomen tendu, périmètre abdo : 92 cm, ascite importante.
Examen neuro normal, notament pas de signe d'encéphalopathie
Examen pneumo normal, pas de dyspnée, pas de cyanose
Elle pèse **58.2 kg**_[poids]_ à l'entré, soit 9 kg de plus que son poids de forme.

Examens complémentaires

Les analyses biologiques du 13/01/2024 montrent :

- une IH stable depuis la dernière venue avec :
  - **asat       :     1.5 N**_[asat]_
  - **alat       :     1.5 N**_[alat]_
  - **PAL        :    100 U/L**_[phosphatase-alcaline]_
  - **GGT        :     30 UI/L**_[ggt]_
  - alb        :     40 g/L
  - **bilirubine :     25 umol/L**_[bilirubine-totale]_
  - **TP         :     80 %**_[taux-prothrombine]_

Le score de Child Pugh est à B

- l'analyse du liquide d'ascite ne révèle pas d'infection (57 PNN/mm3)

La **fibroscopie**_[acte]_ ne detecte pas de varice oesophagienne et on ne note pas d'anémie ou de microcytose à l'hémogramme

La **ponction**_[acte]_ évacue 7 litres d'ascite,
**perfusion de 50 g d'albumine.**_[administration]_
on n'observe pas de décompensation vasculaire.

Sortie

Renouvellement de la **prescription de diurétique**_[prescription]_ :

- **furosémide**_[prescription]_
- **spironolactone**_[prescription]_

Mme **Blanc**_[Nom]_ recontacte le service pour sa prochaine ponction évacuatrice. Information sur la surveillance des saignements digestifs.

Fait à Beaujon le 15 janvier 2024
```

## DONNÉES DES PATIENTS

Les données des exemples se trouve `data-platform/raw-layer/test/file/*.csv`

## INSTRUCTIONS STRICTES
1. Générer UNIQUEMENT l'histoire du patient numéro {N} (où N = numéro spécifié)
2. Suivre le style narratif de l'exemple fourni
3. Intégrer de manière fluide et chronologique toutes les données disponibles
4. Utiliser un langage médical précis mais accessible
5. Construire un récit cohérent avec un début (admission), un milieu (prise en charge) et une fin (sortie/suivi)
6. Annoter le texte en suivant l'exemple du patient 9 passer dans la section **MODÈLE DE RÉCIT ANNOTE (EXEMPLE)**, le choix des annotations doit être limité à la liste des variables du socle contenu dans `input/pagecontent/data-dictionary.md`
7. Le résutlat doit se trouver dans `input/pagecontent`
8. Le nom du fichier doit être `QuestionnaireResponse-cas-NUMERO-usage-core-intro.md` NUMERO étant le numéro patient
9. Ne PAS générer les autres histoires

## COMMANDE
Génère l'histoire du patient numéro **10**
