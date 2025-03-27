Cette page documente le jeu de données correspondant au **poids du patient** :
- Documentation des processus de production
    - Description des données integrées dans le Hub de données
- Cas d'usage
- Exemple de ressource FHIR
- Formalisation FHIR


### Processus de production des données

[Aide de lecture](glossary.html#description-des-processus-de-production-des-donn%C3%A9es-sources)

<div style="text-align: center;" id="processus">{%include processus-production-vital-sign.svg%}</div>

<table style="width: 100%">
  <tr><th>Processus</th><th>Nombre d'enregistrements (11/2024)</th><th>Date du premier enregistrement</th><th>Taux de rafraichissement (dans l'EDS)</th></tr>
  <tr><td>Formulaire courbe de croissance</td><td>≈ 1 020 000</td><td>2015</td><td>Quotidien</td></tr>
  <tr><td>Autres formulaires</td><td>≈ 2 230 000</td><td>2015</td><td>Quotidien</td></tr>
  <tr><td><b>Total</b></td><td><b>≈ 3 250 000</b></td><td><b>2015</b></td><td><b>Quotidien</b></td></tr>
</table>

#### Via le formulaire 'Courbe de Croissance'

C'est le processus correspondant au cas 1 dans [la figure ci-dessus](#processus).

<table style="width: 100%">
  <tr><th colspan="2">Caractéristiques de l'enregistrement</th></tr>
  <tr><td>Agent</td><td>Les agents des services d'accueil (IDE, externe, interne...) réalisent les mesures et les saisissent</td></tr>
  <tr><td>Nature</td><td>Mesures de poids (valeur et unité), datées</td></tr>
  <tr><td>Lieu</td><td>Les mesures sont prises dans les services de pédiatrie</td></tr>
  <tr><td>Temps</td><td>Les mesures sont prises lors des visites et saisies dans la foulée</td></tr>
  <tr><td>Modalité</td><td>Les données sont enregistrées via le formulaire 'Courbe de Croissance' d'Orbis</td></tr>
  <tr><td>Raison d'être</td><td>La mesure du poids, et son suivi dans le temps, corrélativement à d'autres données anthropométriques, permettent de détecter un problème de croissance</td></tr>
</table>

#### Via un autre formulaire Orbis

C'est le processus correspondant au cas 2 dans [la figure ci-dessus](#processus).

<table style="width: 100%">
  <tr><th colspan="2">Caractéristiques de l'enregistrement</th></tr>
  <tr><td>Agent</td><td>Inconnu</td></tr>
  <tr><td>Nature</td><td>Mesures de poids (valeur et unité), datées</td></tr>
  <tr><td>Lieu</td><td>Inconnu</td></tr>
  <tr><td>Temps</td><td>Inconnu</td></tr>
  <tr><td>Modalité</td><td>Inconnu</td></tr>
  <tr><td>Raison d'être</td><td>Ces mesures enrichissent le formulaire 'Courbe de Croissance' afin d'améliorer la détection des problèmes de croissance</td></tr>
</table>

### Cas d'usages

Dans le tableau ci-dessous sont référencés tous les cas d'usages présents et passés de la variable **poids du patient**.

<table style="width: 100%">
  <tr><th>Nom</th><th>Description</th></tr>
  <tr><td><a href="dm-core.html">Socles pour les EDSH</a></td><td>Les variables socles pour les EDSH.</td></tr>
</table>

### Exemples

{% include markdown-link-references.md %}
