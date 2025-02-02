### <a id="0.1.11">Version 0.1.11</a>

<details>
  <summary>Cliquez ici pour voir les évolutions liées à la version 0.1.11</summary>
<ul>
    <li>Ajout d'un dictionnaire des données integrées dans l'EDS</li>
</ul>
</details>

### <a id="0.1.10">Version 0.1.10</a>

<details>
  <summary>Cliquez ici pour voir les évolutions liées à la version 0.1.10</summary>
<b> Croissance pédiatrique</b>
<ul>
    <li>Ajout du contexte, et des introductions sur les profils fhir des variables poids, taille et périmètre crânien</li>
</ul>
</details>

### <a id="0.1.9">Version 0.1.9</a>

<details>
  <summary>Cliquez ici pour voir les évolutions liées à la version 0.1.9</summary>
<ul>
    <li>Simplification de la gestion des identifiers : il n'y a plus qu'un type d'identifier : identifiant source, et on n'utilise plus l'attribut use. </li>
    <li>Modification des profiles et valueSet qui usait des concepts qui ont été retirées</li>
</ul>
</details>

### <a id="0.1.8">Version 0.1.8</a>

<details>
  <summary>Cliquez ici pour voir les évolutions liées à la version 0.1.8</summary>
<ul>
    <li>Suppression de ressources inutilisées, correspondant à des tests de stratégies qui n'ont pas été retenues</li>
    <li>Refonte de l'organisation des profils pour améliorer la cohérence dans l'emboitement des ig (fr core & annuaire santé > aphp core > aphp eds)</li>
    <li>Mise en cohérence des autres ressources (exemple, StructureMap, ressource terminologiques...)</li>
    <li>Suppression de la dépendance à l'IG requirement (R5)</li>
    <li>Coquilles : correction de liens morts, de contraintes trop forte (codeableConcept to pattern), correction de domaines dans les exemples, coquille test map, coding dans les  endpoint</li>
</ul>
</details>

### <a id="0.1.7">Version 0.1.7</a>

<details>
  <summary>Cliquez ici pour voir les évolutions liées à la version 0.1.7</summary>
<ul>
    <li>Rationalisation du codesystem des domaines, mise à jours de toutes les ressources et de tous les documents concernés</li>    
</ul>
</details>

### <a id="0.1.6">Version 0.1.6</a>

<details>
  <summary>Cliquez ici pour voir les évolutions liées à la version 0.1.6</summary>
<b> Usage cathéters :</b>
<ul>
    <li>correction de coquilles dans les ressources terminologiques</li>
    <li>ajout de l'usage catheter dans le domain reanimation</li>    
</ul>
</details>

### <a id="0.1.5">Version 0.1.5</a>

<details>
  <summary>Cliquez ici pour voir les évolutions liées à la version 0.1.5</summary>
<b> Croissance pédiatrique</b>
<ul>
    <li>Ajout d'exemples pour les profils fhir</li>
</ul>
</details>


### <a id="0.1.4">Version 0.1.4</a>

<details>
  <summary>Cliquez ici pour voir les évolutions liées à la version 0.1.4</summary>
<b> Dependencies</b>
<ul>
    <li>montée de version de l'ig annuaire santé (dont dépend l'ig aphp core) et correction de conflit</li>
</ul>
</details>


### <a id="0.1.3">Version 0.1.3</a>

<details>
  <summary>Cliquez ici pour voir les évolutions liées à la version 0.1.3</summary>
<b> Usage cathéters :</b>
<ul>
    <li> Instruction de l'usage Cathéters </li>
</ul>
<b> Usage croissance pédiatrique :</b>
<ul>
    <li> Corrections : nommage des maps </li>
</ul>
</details>

### <a id="0.1.2">Version 0.1.2</a>

<details>
  <summary>Cliquez ici pour voir les évolutions liées à la version 0.1.2</summary>
<b> Usage croissance pédiatrique :</b>
<ul>
    <li> Mise à jour de la structureMap Métier vers FHIR : fonctionne dans matchbox, ajout de la génération de la provenance, ajout d'un jeu test</li>
    <li> mise à jour de la conceptMap pour la standardisation des unités</li>
</ul>
</details>

### <a id="0.1.1">Version 0.1.1</a>

<details>
  <summary>Cliquez ici pour voir les évolutions liées à la version 0.1.1</summary>
<b> Mise à jour de la ressource Questionnaire Fiche Hospitalisation :</b>
<ul>
    <li> ajout de l'item 701451197770 qui correspond à la présentation à l’entrée en travail ou en début de césarienne pour les formulaires à partir de novembre 2023</li>
    <li> ajout de l'item 7622203412168, qui prend en compte 701451197770 s'il existe, sinon F_MATER_004842</li>
    <li> modification des items à valueSet variable pour prendre en compte la solution FHIR standard (utilisation d'une variable et d'une answerExpression)</li>
    <li> mise en conformité des unités</li>
</ul>
</details>

{% include markdown-link-references.md %}