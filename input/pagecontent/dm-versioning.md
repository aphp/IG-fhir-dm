La gestion des versions s’appuie sur le mécanisme proposé par HL7 FHIR. En FHIR, il y a trois niveaux de version pour une ressource :
1.	La version d’enregistrement : change à chaque fois que la ressource change (habituellement géré par le serveur)
2.	La version métier : change à chaque fois que le contenu d’une ressource change (géré par un l’auteur humain ou par des règles métiers)
3.	La version FHIR : la version de FHIR dans laquelle la ressource est représentée (contrôlé par l’auteur de la ressource)

Références : [ici](http://hl7.org/fhir/R4/resource.html#versions)

### Version FHIR
Pour ce qui est de la version FHIR, la version promue actuellement en France et utilisée majoritairement à l'APHP est la version R4. Seuls l'IG Requirements est en R5. 

### Business version
Pour ce qui est de la version métier (business version), portée par l'attribut `Questionnaire.version` par exemple, elle sera directement reprise du système de production (Orbis par exemple). 
Chaque version integrée dans l'EDS donnera lieu à la création d'une nouvelle instance de Questionnaire avec : 
 - le même nom
 - la même url
 - une version différente
La gestion des versions doit suivre un algorithme documenté pour permettre à un utilisateur d'être sur qu'il utilise la dernière version

**En l'état actuel de la situation, l'IG publisher ne permet pas d'intégrer dans un FHIR IG deux ressources de même id (l'url étant construite sur la base de l'id).** 
il n'est donc pas possible de publier plusieurs business version dans le FIG. Le serveur HAPI n'a pas cette contrainte.  

Références : [ici](https://chat.fhir.org/#narrow/stream/179255-questionnaire/topic/Questionnaire.20versioning/near/419859167)
et [là](https://brianpos.com/2022/12/13/canonical-versioning-in-your-fhir-server/)

### Record version
Pour ce qui est de la version d’enregistrement (record version), portée par l'attribut `.meta.versionId`, elle est gérée par le serveur Fhir, et incrémenté à chaque modification.  

Dans FHIR, toutes les ressources sont conceptuellement versionnés, et chaque ressource se trouve en tête d'une liste linéaire de versions antérieures. 
Les versions antérieures sont remplacées par la version actuelle et ne sont disponibles qu'à des fins d'audit/d'intégrité. 
L’information de version peut être référencée dans une référence de ressource. 
Elle peut être utilisée pour garantir que les mises à jour sont basées sur la dernière version de la ressource. 
La version peut être unique au monde ou limitée par l'ID logique de la ressource. 
Les identifiants de version sont généralement soit un identifiant incrémenté en série limité par l'identifiant logique, soit un “uuid”, bien qu'aucune de ces approches ne soit requise. 
Il n'y a pas d'ordre fixe pour les identifiants de version - les clients ne peuvent pas supposer qu'un identifiant de version qui vient après un autre, numériquement ou alphabétiquement, représente une version ultérieure. 
Le même “versionId” ne peut jamais être utilisé pour plusieurs versions de la même ressource. 
Dans le cas de l'API RESTful : 
lors de la réception d'une mise à jour, d'un correctif ou d'une autre opération FHIR ayant un impact sur l’attribut “meta” d’une ressource, le serveur DOIT mettre à jour cet élément à la valeur actuelle ou le supprimer. 
Notez que les serveurs DEVRAIENT prendre en charge les versions, mais certains sont incapables de le faire.



{% include markdown-link-references.md %}