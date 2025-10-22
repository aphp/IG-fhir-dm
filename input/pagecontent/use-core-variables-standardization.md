{% include markdown-link-references.md %}

Les [exigences de l'usage **Variables socles pour les EDSH** (fichier MSExcel)](DocumentReference-CoreExigences.html) 
référencées issues des travaux du GT Standards & Interopérabilité. 

### Modèles standardisés (Profils FHIR)

Le tableau ci-dessous référence tous les profils FHIR résultat du processus de standardisation des données au format FHIR.

{% include data-dictionary.md %}

### Exemples

#### Cas 1 :

#### Cas 2 :

#### Cas 3 :

#### Cas 4 :

#### Cas 5 :

#### Cas 6 :

#### Cas 7 :

#### Cas 8 :

#### Cas 9 : Patiente bénéficiant d'une ponction d'ascite évacuatrice et d'exploration de sa cirrhose

Dans l'histoire du cas 9 on peut représenter plusieurs informations dans le modèle standard :

- [la patiente elle même](Patient-cas-9.html)
- [son séjour hopsitalier](Encounter-sejour-cas-9.html)
- les affections prises en charges lors de son séjour : [son ascite](Condition-ascite-cas-9.html), et [sa cirrhose](Condition-cirrhose-cas-9.html)
- [ses habitudes de consommation d'alcool](Observation-alcool-cas-9.html)
- son [poids](Observation-poids-cas-9.html)
- les actes dont elle a bénéficié : [sa ponction d'ascite](Procedure-ponction-cas-9.html) et [sa fibroscopie oeso-gastro-duodénale](Procedure-fogd-cas-9.html)
- certains des dosages biologiques dont elle a bénéficié :
  - [asat](Observation-asat-cas-9.html)
  - [alat](Observation-alat-cas-9.html)
  - [phosphatases alcalines](Observation-phosphatases-alcalines-cas-9.html)
  - [gamma-glutamyl-transférase](Observation-ggt-cas-9.html)
  - [bilirubine totale](Observation-bilirubine-totale-cas-9.html)
  - [taux de prothrombine](Observation-tp-cas-9.html)
- ses prescriptions médicamenteuses : [furosémide](MedicationRequest-furosemide-cas-9.html), [spironolactone](MedicationRequest-spironolactone-cas-9.html) et [albumine](MedicationRequest-albumine-cas-9.html)
- ses administrations médicamenteuses
  - [J1 furosémide](MedicationAdministration-furosemide-j1-cas-9.html)
  - [J2 furosémide](MedicationAdministration-furosemide-j2-cas-9.html)
  - [J1 spironolactone](MedicationAdministration-spironolactone-j1-cas-9.html)
  - [J2 spironolactone](MedicationAdministration-spironolactone-j2-cas-9.html)
  - [Albumine](MedicationAdministration-albumine-j1-cas-9.html)

#### Cas 10 :

#### Cas 11 : Suivi diabète de type 2

TO DO