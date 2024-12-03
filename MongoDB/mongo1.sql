select jsonb_path_query(data, '$.metadata.uid') as resultat
from pods
where uid = '45c71a9d-55aa-482f-9fb2-b12931b272d9';

-- 2.2 Interrogation des informations du pod 45c71a9d-55aa-482f-9fb2-b12931b272d9 

-- 1 - Quel est le nom (name) du pod (dans les métadonnées) ?
select jsonb_path_query(data, '$.metadata.name') as resultat
from pods
where uid = '45c71a9d-55aa-482f-9fb2-b12931b272d9';


--2 Quels sont les différents types de conditions par lesquelles ce pod est passé (dans status)?
select jsonb_path_query(data, '$.status.conditions[*].type') as resultat
from pods
where uid = '45c71a9d-55aa-482f-9fb2-b12931b272d9';


--3 Donner le nom (name) des volumes (dans spec) qui possèdent un champ secret.
SELECT jsonb_path_query(data, '$.spec.volumes[*] ? (@.secret.secretName != "") .name') AS resultat
FROM pods
WHERE uid = '45c71a9d-55aa-482f-9fb2-b12931b272d9';

/*  CORRECTION 3 */
select jsonb_path_query(data, '$.spec.volumes[*] ?(exists(@.secret)) .name') as resultat
from pods
where uid = '45c71a9d-55aa-482f-9fb2-b12931b272d9';
/*   FIN CORRECTION 3   */


--4 Donner les arguments (args) du conteneur (containers dans spec) nommé "prometheus".
select jsonb_path_query(data, '$.spec.containers[*] ? (@.name == "prometheus") .args') as resultat
from pods
where uid = '45c71a9d-55aa-482f-9fb2-b12931b272d9';


--5 Donner les types de conditions (dans status) dont le lastTransitionTime est plus grand que l'heure de démarrage (startedAt) d'un des conteneurs (accessible dans containerStatuses).
select jsonb_path_query(data, '$.status.conditions[*] ? (@.lastTransitionTime > $.status.startTime) .type') as resultat
from pods
where uid = '45c71a9d-55aa-482f-9fb2-b12931b272d9';

/*  CORRECTION 5 */
select jsonb_path_query(data, '$.status.conditions[*] ?(@.lastTransitionTime > $.status.containerStatuses.state.*.startedAt) .type') as resultat
from pods
where uid = '45c71a9d-55aa-482f-9fb2-b12931b272d9';
/*   FIN CORRECTION 5   */


--6 Donner la liste des clés du dictionnaire labels dans metadata. On pourra commencer par donner l'ensemble des clés/valeurs.
select jsonb_path_query(data, '$.metadata.keyvalue()') as resultat
from pods
where uid = '45c71a9d-55aa-482f-9fb2-b12931b272d9';

/*  CORRECTION 6 */
select jsonb_path_query(data, '$.metadata.labels.keyvalue().key') as resultat
from pods
where uid = '45c71a9d-55aa-482f-9fb2-b12931b272d9';
/*   FIN CORRECTION 6   */

--7 Donner la liste des différent états (clé dans state) des conteneurs (containerStatuses et initContainerStatuses).
select jsonb_path_query(data, '$.status[*].keyvalue()') as resultat
from pods
where uid = '45c71a9d-55aa-482f-9fb2-b12931b272d9';

/*  CORRECTION 7 */
select jsonb_path_query(data, '$.status.*[*].state.keyvalue().key') as resultat
from pods
where uid = '45c71a9d-55aa-482f-9fb2-b12931b272d9';
/*   FIN CORRECTION 7   */


