On peut avoir différentes sources dans le système d'information (SI) de production qui peuvent fournir des informations équivalentes avec des status différents. 
Idéalement, on s'attachera à reconstruire, au niveau du Hub de données, le cycle de vie de la ressource, avec les experts métiers. 
Cette tâche peut néanmoins être difficile et on pourra être amené à intégrer dans un hub de données, depuis deux sources différentes, des données qui correspondent à une seule information à un stade différent dans son cycle de vie. 
On s'astreindra donc à toujours mentionner la source (via l'attribut `meta.source`) dans les ressources FHIR manipulées au niveau du Hub de données (voir [convention de nommage des uris source](glossary.html#uri-des-sources)). 

Dans tous les cas, on essayera d'expliciter dans les ressources l'étape du cycle de vie, au-delà de la source de l'information. 

Ces décisions seront documentées dans le présent IG ainsi que les profils/extensions à mettre en œuvre le cas échéant. 

### Le codage des diagnostics et des actes

Il existe à l'heure actuelle deux sources d’information pour le codage des diagnostics et des actes :
 - le dossier patient informatisé
 - la base consolidée des données transmises aux tutelles dans le cadre du PMSI

Les données sont très colinéaires. On note néanmoins que les données du DPI sont saisies (et disponible dans le Hub de données) en temps réel alors que celles de la base consolidée sont validées par le DIM dans un délai d’un mois. 

Il a été décidé de conserver les deux codages

**à valider avec le GT DIM** 
On utilisera en outre l’attribut `recorder` des ressources Condition et Procedure pour clarifier le responsable de l'information codé. 
Lorsque la donnée est issue du DPI, le `recorder` pointe sur un practitionerRole défini par le code 'membre de l'équipe de soin'. 
Lorsque la donnée est issue de la base consolidée, le `recorder` pointe sur un practitionerRole défini par le code 'Agent de contrôle du codage'.

### Le codage des groupes homogènes de malades (GHM)

**à valider avec le GT DIM**
Les GHM constituent une information calculée à partir des informations du PMSI. Il semble pertinent de considérer que seul la version validée par le DIM et transmise aux tutelles fait fois et atteint le status 'active'. Les groupages qui peuvent avoir été calculés en amont, sur la base de dossiers non contrôlés par le DIM restent au status 'draft'. 

{% include markdown-link-references.md %}