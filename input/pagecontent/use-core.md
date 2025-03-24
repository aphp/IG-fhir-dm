<!-- If the image below is not wrapped in a div tag, the publisher tries to wrap text around the image, which is not desired. -->
<div id="dm-schema-fonctionnel">
    <div style="horiz-align: center">
        <img src="dm-schema-fonctionnel.png" alt="Le schéma suivant représente le workflow de la méthode employé" height="auto" width="100%" />
    </div>
</div>

À des fins de démonstration, nous nous plaçons dans le contexte d’un DPI générique sur lequel nous souhaitons construire un hub d’intégration en nous appuyant sur le standard FHIR. Cette approche nous permet d’envisager toutes les finalités possibles, notamment la livraison de données au format OMOP.

Le processus de livraison des données se compose de la manière suivante :

1. Intégration des exigences (fichier MSExcel) du cas d'usage.
2. Instruction : Formalisation des exigences dans une ressource FHIR `Questionnaire` puis identification des tables/colonnes mobilisées par les exigences.
3. Conception : de la couche sémantique FHIR puis de la livraison des données en OMOP

### Exigences

{% include use-core-exigence.md %}

### Instruction

{% include use-core-instruction.md %}

### Conception

#### Conception de la couche sémantique (FHIR)

{% include use-core-conception-fhir.md %}

#### Conception de la livraison des données (OMOP)

{% include use-core-conception-omop.md %}