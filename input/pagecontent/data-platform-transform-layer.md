Le modèle présenté s’appuie sur un DPI théorique conçu pour persister les variables du socle nécessaires aux usages des Entrepôts de Données de Santé Hospitaliers (EDSH). L’objectif de cette modélisation est de disposer d’une représentation conceptuelle stable, indépendante des implémentations logicielles spécifiques, afin de faciliter l’interopérabilité, la standardisation et la valorisation secondaire des données de santé.

Dans cette approche, chaque table du modèle physique du DPI est alignée conceptuellement avec une ou plusieurs ressources FHIR partageant une proximité sémantique et fonctionnelle. Cet alignement permet d’établir un pont entre les structures relationnelles historiques des systèmes d’information hospitaliers et les modèles d’échange normalisés portés par HL7 FHIR.

Les transformations nécessaires au passage du modèle source vers les profils FHIR sont organisées sous forme de *groups*, chacun correspondant à un ensemble cohérent de règles de transformation et de mapping. Cette structuration favorise la lisibilité, la maintenabilité et la réutilisation des règles d’alignement.

Une fois les éléments pertinents de la source identifiés (périmètre final) et les profils FHIR élaborés, il est possible de formaliser les règles d’alignement des premiers vers les seconds via la rédaction d’une `StructureMap`.

Vous pouvez trouver l’alignement formel entre le modèle physique du DPI et les profils FHIR : [Alignement DPI vers FHIR](StructureMap-EHR2FSL.html).

#### Table Patient vers FHIR Patient

```fml
// ---------------------------------------------------------
// PATIENT TRANSFORMATION
// ---------------------------------------------------------

group TransformPatient(source src, target tgt : Patient) {
  src -> tgt.id = uuid() "setId";
  //  src.patientId as id -> tgt.id = id "patient-id"; 
  
  // Identifiers
  src.patientId as pid -> tgt.identifier as identifier then {
    pid -> identifier.use = 'usual' "id-use";
    pid -> identifier.type = cc('http://terminology.hl7.org/CodeSystem/v2-0203', 'PI', 'Patient Identifier') "id-type";
    pid -> identifier.system = 'https://hospital.eu/ehr/patient-id' "id-system";
    pid -> identifier.value = pid "id-value";
  } "patient-identifier";

  // NIR identifier <- C'est pas terrible côté expression de besoin : qu'est ce qu'ils veulent quand ils disent NIR ? ça peut être le NSS, mais du coup c'est pas un identifier (un NSS peut correspondre à plusieurs ayant droits), et ce serait plutôt une info qui irait côté claim. ça peut aussi être l'ins-nir, mais du coup qu'est ce qu'ils attendent dans l'ins ? Bref, à mon avis, faut discuter cette variable au niveau du GT. 
/*
  src.nir as nir where nir.exists() -> tgt.identifier as insIdentifier then {
    nir -> insIdentifier.use = 'official' "ins-use";
    nir -> insIdentifier.type = cc('http://hl7.fr/fhir/CodeSystem/fr-v2-0203', 'INS-NIR') "ins-type";
    nir -> insIdentifier.system = 'urn:oid:1.2.250.1.213.1.4.8' "ins-system";
    nir -> insIdentifier.value = nir "ins-value";
  } "ins-identifier"; 
*/

  // Alternative INS from ins field
  src.ins as ins where ins.exists() -> tgt.identifier as insIdentifier then {
    ins -> insIdentifier.use = 'official' "ins-use"; // On part du principe qu'on n'est pas sur un old.
    ins -> insIdentifier.type = cc('https://hl7.fr/ig/fhir/core/CodeSystem/fr-core-cs-v2-0203', 'INS-NIR', 'NIR définitif') "ins-type";
    ins -> insIdentifier.system = 'urn:oid:1.2.250.1.213.1.4.8' "ins-system";
    ins -> insIdentifier.value = ins "ins-value";
  } "ins-identifier";

  // Name
  src where src.nom.exists() or src.prenom.exists() -> tgt.name as name then {
    src.nom as lastName -> name.family = lastName "family-name";
    src.prenom as firstName -> name.given = firstName "given-name";
    src -> name.use = 'official' "name-use"; // hypothèse un peu forte.
  } "patient-name";

  // Demographics On aurait pu faire plus élégant avec un ConceptMap
  src.dateNaissance as birthDate -> tgt.birthDate = birthDate "birth-date";
  src.sexe as gender where gender = 'h' -> tgt.gender = 'male' "gender-male"; 
  src.sexe as gender where gender = 'f' -> tgt.gender = 'female' "gender-female";
  src.sexe as gender where gender.exists() and gender != 'h' and gender != 'f' -> tgt.gender = 'unknown' "gender-unknown"; // n'a pas grand sens en l'état des contraintes SQL

  // Death information
  src.dateDeces as deathDate where deathDate.exists() -> tgt.deceased = cast(deathDate, 'dateTime') as deceasedDate then {
    src.sourceDeces as deathSource where deathSource.exists() -> deceasedDate.extension as DeathSourceExtension then {
      deathSource -> DeathSourceExtension.url = 'https://interop.aphp.fr/ig/fhir/dm/StructureDefinition/DeathSource' "deathSourceUrl";
      deathSource -> DeathSourceExtension.value = cast(deathSource, 'code') "deathSourceValue";
    } "deathSource";
  } "deathDate";

  // Multiple birth
  src.rangGemellaire as twin where twin.exists() -> tgt.multipleBirth = twin "multiple-birth";

}
```
