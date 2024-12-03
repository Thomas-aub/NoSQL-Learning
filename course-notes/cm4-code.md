# Code pour le cours l'algèbre de collections

## Introduction

Lancer le serveur (ici la version docker qui utilise le fichier [docker-compose.yaml](docker-compose.yaml))

```shell
docker compose up -d
```

Récupérer et importer les données exemple

```
curl -o grades.json https://raw.githubusercontent.com/ozlerhakan/mongodb-json-files/master/datasets/grades.json
cat grades.json | docker compose exec -T mongo mongoimport --collection grades --drop
```

> Afficher un document

```js
db.grades.findOne();
```

## Utilisation des différents opérateurs

> Pour chaque étudiant, son nombre de records

```js
db.grades.aggregate([{ $group: { _id: "$student_id", nombre: { $sum: 1 } } }]);
```

> Pour chaque type de devoir, le nombre de notes

```js
db.grades.aggregate([
  { $unwind: "$scores" },
  { $group: { _id: "$scores.type", nombre: { $sum: 1 } } },
]);
```

> Pour chaque étudiant et chaque matière le tableau contenant la moyenne de chaque type de devoir.
> On sauvegarde le résultat dans grades_avg

```js
db.grades.aggregate([
    { $unwind: "$scores" },
    { $group: { _id: { student_id: "$student_id",
                       class_id: "$class_id",
                       type: "$scores.type" },
                moy: { $avg: "$scores.score" } }},
    { $group: { _id: { student_id: "$_id.student_id",
                       class_id: "$_id.class_id" },
                moyennes: { $push: { type: "$_id.type", moy: "$moy" } } }},
    { $project: { _id: 0,
                  student_id: "$_id.student_id",
                  class_id: "$_id.class_id",
                  moyennes: 1 }},
    { $merge: { into: "grades_avg" }}
])
```

> Pour chaque étudiant de la matière 4, le tableau contenant la moyenne de chaque type de devoir

```js
db.grades.aggregate([
    { $match: { class_id: 4 } },
    { $unwind: "$scores" },
    { $group: { _id: { student_id: "$student_id",
                       type: "$scores.type" },
                moy: { $avg: "$scores.score" } }},
    { $group: { _id: "$_id.student_id",
                moyennes: { $push: { type: "$_id.type", moy: "$moy" } } }},
    { $project: { _id: 0,
                  student_id: "$_id",
                  moyennes: 1 }}
])
```

> Pour chaque étudiant et chaque matière, combien d'étudiants ont une meilleure note
> que l'étudiant considéré. La note d'un étudiant pour une classe est la moyenne
> des moyennes des 3 types d'épreuves.

```js
db.grades_notes.deleteMany({})

db.grades_avg.aggregate([
    { $unwind: "$moyennes" },
    { $group: {
        _id: { student_id: "$student_id", class_id: "$class_id" },
        note: { $avg: "$moyennes.moy" },
      }},
    { $project: {
        _id: 0,
        student_id: "$_id.student_id",
        class_id: "$_id.class_id",
        note: 1
    }},
    { $merge: { into: "grades_notes" }}
])

db.grades_notes.aggregate([
    { $lookup: { from: "grades_notes", localField: "class_id", foreignField: "class_id", as: "other" }},
    { $unwind: "$other" },
    { $match: { $expr: { $lt: [ "$note", "$other.note" ] } }},
    { $group: { _id: { student_id: "$student_id", class_id: "$class_id" },
                nombre: { $sum: 1 } }},
    { $project: { _id: 0,
                  student_id: "$_id.student_id",
                  class_id: "$_id.class_id",
                  nombre: 1
                  }}
])
```

## Aggrégations à plusieurs niveaux

> Pour chaque étudiant, son nombre de notes (entrée dans les scores), ainsi que sa
> note (moyenne des moyennes) de classe

```js
db.grades.aggregate([
    { $unwind: "$scores" },
    { $group: {
        _id: { s: "$student_id", c: "$class_id", t: "$scores.type" },
        moytype: { $avg: "$scores.score" },
        nb: { $sum: 1 },
    }},
    { $group: {
        _id: { s: "$_id.s", c: "$_id.c" },
        note: { $avg: "$moytype" },
        nb: { $sum: "$nb" }
    }},
    { $project: {
        _id: 0,
        student_id: "$_id.s",
        class_id: "$_id.c",
        note: 1,
        nb: 1,
    }}
])
```
