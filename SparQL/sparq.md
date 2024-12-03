# DBPedia

## Introduction

L'objectif de ce TP est de pratiquer le langage
[SPARQL](http://www.w3.org/TR/2013/REC-sparql11-query-20130321/). Pour
ce faire on utilisera la base publique DBPedia qui expose au format RDF
des données issues de [Wikipedia](https://www.wikipedia.org/).

Un formulaire permettant de soumettre des requêtes SPARQL est librement
accessible ici: <http://dbpedia.org/sparql>

Il est possible d'utiliser les préfixes prédéfinis suivants dans les
requêtes:

| préfixe | IRI                                           |
|---------|-----------------------------------------------|
| rdf:    | <http://www.w3.org/1999/02/22-rdf-syntax-ns#> |
| rdfs:   | <http://www.w3.org/2000/01/rdf-schema#>       |
| xsd:    | <http://www.w3.org/2001/XMLSchema#>           |
| dbo:    | <http://dbpedia.org/ontology/>                |
| dbr:    | <http://dbpedia.org/resource/>                |
| dbp:    | <http://dbpedia.org/property/>                |
| yago:   | <http://dbpedia.org/class/yago/>              |

**Attention:** Il ne faut pas changer le nom du graphe requêté (/
Default Data Set Name (Graph IRI)/).

## Questions

1.  Donner l'IRI de quelques noeuds de type
    <http://dbpedia.org/ontology/Restaurant>

    ```sparql
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    PREFIX dbo: <http://dbpedia.org/ontology/>

    SELECT DISTINCT ?restaurant WHERE {
        ?restaurant rdf:type dbo:Restaurant
    } LIMIT 100    

2.  Donner le label du noeud
    <http://dbpedia.org/resource/Light_Horse_Tavern>
    ```sparql
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX dbr: <http://dbpedia.org/resource/>

    SELECT DISTINCT ?label WHERE {
        dbr:Light_Horse_Tavern rdfs:label ?label
    }

3.  Donner le nom (label) de quelques noeuds de type
    <http://dbpedia.org/ontology/Chef>
    ```sparql
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX dbo: <http://dbpedia.org/ontology/>

    SELECT DISTINCT ?label WHERE {
        dbo:Chef rdfs:label ?label
    } LIMIT 10

4.  Donner des prédicats ayant pour sujet
    <http://dbpedia.org/resource/Light_Horse_Tavern>
    ```sparql
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX dbr: <http://dbpedia.org/resource/>

    SELECT DISTINCT ?predicat WHERE {
        dbr:Light_Horse_Tavern?predicat ?label
    }

5.  Donner l'adresse (sous forme d'une chaîne de caractères en anglais
    (i.e. `en`) "adresse - ville - pays") du restaurant
    <http://dbpedia.org/resource/Light_Horse_Tavern>

    Remarques:

    - on peut s'appuyer sur la question précédente pour connaître quels
      sont les prédicats à utiliser
    - la fonction `concat` peut être utilisée
    - on peut tester la langue d'une chaîne de caractères avec
      LANG(?machaine) = "en" dans un FILTER
    ```sparql
    PREFIX dbr: <http://dbpedia.org/resource/>
    PREFIX dbo: <http://dbpedia.org/ontology/>
    PREFIX dbp: <http://dbpedia.org/property/>

    SELECT ?title WHERE {
    dbr:Light_Horse_Tavern dbo:address ?adresse.

    ?city dbp:name ?ville.
    dbr:Light_Horse_Tavern dbp:city ?city.

    ?country dbp:commonName ?pays.
    dbr:Light_Horse_Tavern dbp:country ?country.

    FILTER ( lang(?adresse) = "en" ).
    FILTER ( lang(?ville) = "en" ).
    FILTER ( lang(?pays) = "en" ).

    BIND(CONCAT(?adresse, " - ", ?ville, " - ", ?pays) AS ?title).
    
    }

6.  Donner le nom (label) d'un restaurant créé (`dbp:established`) en
    2002 ou après.

    Remarque: les années sont représentées par des entiers. On peut
    représenter l'entier 2002 par `"2002"^^xsd:integer`
    ```sparql
    PREFIX dbp: <http://dbpedia.org/property/>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

    SELECT DISTINCT ?label WHERE {
    ?rest rdfs:label ?label.

    ?rest dbp:established ?year.
    FILTER( ?year >= 2002).
    
    } LIMIT 1

7.  Donner des couples de restaurants ayant le même chef (`dbo:chef`)
    ```sparql
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX dbo: <http://dbpedia.org/ontology/>

    SELECT DISTINCT ?label1, ?label2 WHERE {
    ?rest1 rdfs:label ?label1.
    ?rest2 rdfs:label ?label2.

    ?rest1 dbo:chef ?chef1.
    ?rest2 dbo:chef ?chef2.
    
    FILTER( ?chef1 = ?chef2).
    FILTER(?label1 != ?label2).
    } 

8.  Afficher un chef avec le nombre de restaurants dont il est chef. On
    veut le nom du chef et pas son IRI.
    
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        PREFIX dbo: <http://dbpedia.org/ontology/>

        SELECT DISTINCT ?label (COUNT(?label) AS ?nb_restaurants) WHERE {
        ?chef rdfs:label ?label.
        ?rest dbo:chef ?chef.
        }

    Comment se fait-il qu'un chef puisse apparaitre plusieurs fois ?
    
        Parce que le label est en plusieurs langues
9.  Existe-il un chef ayant (`dbo:chef`) deux restaurants dans des
    villes différentes ? Donner son nom ainsi que celui des deux
    restaurants concernés.

10. A partir des informations récupérées depuis le [schéma du type
    Restaurant](http://dbpedia.org/ontology/Restaurant), et de la
    [description de la ressource Locanda
    Locatelli](http://dbpedia.org/resource/Locanda_Locatelli) donner
    deux restaurants ayant le même chef et dont l'un des deux est un
    restaurant étoilés dans le guide Michelin.
