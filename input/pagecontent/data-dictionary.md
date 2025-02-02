Le tableau suivant récapitule les données intégré dans le Hub de données du système d'information de l'organisation exemple.

<table style="width: 100%">
  <tr><th>Domaine principal</th><th>Données</th><th>Caractéristiques</th></tr>
  <tr><td>Identité patient</td><td><a href="StructureDefinition-DMPatient.html">Patient</a></td><td>Données maîtres ; <a href="https://ansforge.github.io/IG-FHIR-EDS-SOCLE-COMMUN/result.html#identité-patient">Socle de données commun aux EDS</a></td></tr>
  <tr><td>Identité patient</td><td><a href="StructureDefinition-DMEncounter.html">Venue</a></td><td>Données maîtres ; <a href="https://ansforge.github.io/IG-FHIR-EDS-SOCLE-COMMUN/result.html#identité-patient">Socle de données commun aux EDS</a></td></tr>
  <tr><td>Identité patient</td><td><a href="StructureDefinition-DMOrganization.html">Structure</a></td><td>Données maîtres ; <a href="https://ansforge.github.io/IG-FHIR-EDS-SOCLE-COMMUN/result.html#identité-patient">Socle de données commun aux EDS</a></td></tr>
  <tr><td>Dossier de soin</td><td><a href="StructureDefinition-DMObservationBodyWeight.html">Poids</a></td><td>Données d'intérêt ; <a href="https://ansforge.github.io/IG-FHIR-EDS-SOCLE-COMMUN/result.html#dossier-de-soins">Socle de données commun aux EDS</a></td></tr>
  <tr><td>Dossier de soin</td><td><a href="StructureDefinition-DMObservationBodyHeight.html">Taille</a></td><td>Données d'intérêt ; <a href="https://ansforge.github.io/IG-FHIR-EDS-SOCLE-COMMUN/result.html#dossier-de-soins">Socle de données commun aux EDS</a></td></tr>
</table>

Indications de lecture : 
- Colonne "Domaine principal" : Il s'agit du contexte de production des données qui ont été integrées. On trouvera [une spécialité médicale au sens de la Fédération des Spécialitées Médicales](CodeSystem-SpecialitesMedicalesFSM.html).
- Colonne "Données" : données du système d'information de l'organisation exemple qui ont été intégrées dans le Hub de données. 
- Colonne "Caractéristiques" :
  - Données transactionnelles: données qui représentent l'achèvement d'une action ou d'un plan d'action « métier ».  il ne s’agit pas ici de « transaction » au sens informatique de « suite d’opérations modifiant l’état d’une base de données », mais de transaction au sens commercial ; dans notre contexte, un épisode de soin, par exemple, représente une transaction. On distingue :
    - Données issues de formulaire : ces données sont restituées sous la forme sous laquelle elles ont été saisies. Leur forte adhérence à des processus de production spécifiques les rend difficilement utilisables pour des agents non au fait desdits processus. 
    - Données d'intérêt : ces données ont bénéficié d'une étape de standardisation lors de leur intégration dans l'EDS, ce qui favorise leur réutilisabilité.
  - Données de références : il s'agit des données utilisées pour organiser ou catégoriser d'autres données, ou pour relier des données à des informations à l'intérieur et à l'extérieur des limites de l'hôpital. Il s'agit généralement de codes et de descriptions ou de définitions.
  - Données maîtres : elles fournissent le contexte des données relatives à l'activité métier sous la forme de concepts communs et abstraits qui se rapportent à l'activité. Elles comprennent les détails (définitions et identifiants) des objets internes et externes impliqués dans les transactions métier, tels que les clients, les produits, les employés, les fournisseurs et les domaines contrôlés (valeurs de code).
  - Socle de données commun aux EDS : ces données ont été identifiées, au niveau national, comme devant être prioritairement collectées, mise en qualité, standardisées et mises à disposition au sein des entrepôts de données de santé hospitaliers.


{% include markdown-link-references.md %}