[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/LLSk9Iyx)
# Projet de Base de Données (GLO-2005) Hiver 2025

## Introduction

Bla bla bla

## Prérequis

Vous devez avoir [MySQL8](https://dev.mysql.com/doc/mysql-installation-excerpt/8.0/en/) et Python installés sur votre machine.

Plusieurs packages Python sont requis pour ce projet. Afin de tous les installer facilement, roulez la commande:
```shell
pip install -r requirements.txt
```

## Mise en situation et structure du code

Ce projet représente une application web bla bla bla

## Étape 1 - Configurer votre environnement de travail

Bla bla bla

### Utiliser des variables d'environnement

La solution à ce problème est d'utiliser des variables d'environnement. Celles-ci sont des variables externes au programme, dont les valeurs peuvent être récupérées au moment de l'exécution du programme. Chaque membre de l'équipe aura donc ses propres variables d'environnement contenant les informations de connexion à leur BD locale.

Pour commencer, vous devez créer une nouvelle base de données nommée *atelier_bd* sur votre serveur MySQL local:
```sql
CREATE DATABASE Tournoi;
USE Tournoi;
```

Maintenant, vous devez créer les variables d'environnement propices à la bonne connexion de l'application à cette base de données. Pour ce faire, une bonne pratique est de mettre ces variables dans un fichier **.env** qui se trouve à la racine de votre projet. Par la suite, il sera possible d'indiquer à l'application d'aller récupérer les valeurs souhaitées directement dans ce fichier.

**Créez un fichier .env à la racine de votre projet.** Vous avez un exemple avec le fichier env.example.

**À l'intérieur de ce fichier, vous devez ajouter les variables d'environnement**. Le format d'un fichier **.env** est une paire clé-valeur (nom de la variable ainsi que sa valeur) par ligne:
```
VAR1=VALEUR1
VAR2=VALEUR2
```

Vous devez ajouter les 5 variables d'environnement suivantes, nommées exactement comme ceci:

- HOST: l'adresse de votre serveur SQL. En local, ceci est 127.0.0.1
- PORT: le numéro de port de votre serveur SQL. Par défaut, MySQL roule sur le port 3306
- DATABASE: le nom de votre BD. Dans notre cas, **Tournoi**
- USER: votre nom d'utilisateur pour votre serveur
- PASSWORD: votre mot de passe


**ATTENTION! Votre fichier .env vous est unique. Il ne doit pas être ajouté au repo Git, car cela constituerait la même faille de sécurité que d'écrire vos identifiants directement dans le code!** Pour que Git ignore ce fichier, il suffit de l'ajouter dans le fichier *.gitignore*. Dans cet atelier, ceci est déjà fait pour vous.


### Récupérer des variables d'environnement

Pour récupérer les variables d'environnement depuis un fichier .env, commencez par utiliser la fonction load_dotenv() du package python-dotenv:
```python
from dotenv import load_dotenv

load_dotenv()
```

Ensuite, pour accéder aux variables dans le code de l'application Python, utilisez la fonction getenv() du module os:
```python
import os

os.getenv("NOM DE LA VARIABLE")
```
**Placez la fonction load_dotenv() juste avant d'accéder aux valeurs avec getenv().** Par défaut, Python recherche les variables d'environnement dans votre système, mais load_dotenv() permet de les charger depuis le fichier **.env**.

### Tester le tout

La classe *Database* contient tout le code pour se connecter à la BD et l'initialiser à son schéma initial. Si vous avez bien suivi les étapes précédentes, vous pouvez lancer le serveur en tapant la commande:

```shell
python server.py
```
ou en roulant le fichier directement depuis votre IDE. Puis, naviguez à l'URL 127.0.0.1:5000 dans votre navigateur, cliquez sur le bouton *(Re)créer la BD* puis sur le bouton *Rafraîchir*. Vous devriez voir le schéma de départ de la BD.

Si vous souhaitez voir les instructions exactes de mise en route de la BD, référez-vous au fichier *db_scripts/up.sql*.


## Travailler sur une base de données partagée

Maintenant que tous les membres de l'équipe peuvent se connecter à leur instance de BD en roulant le même code, nous allons voir comment apporter des modifications au schéma et aux données afin que tout le monde travaille sur le même état de base de données.

**À noter que dans le contexte d'une base de données hébergée dans un cloud distant, les mêmes principent s'appliquent. Les prochaines étapes s'appliqueraient uniquement à la BD distante au lieu de s'appliquer à chaque membre de l'équipe respectivement.**

### Grands principes

Afin que tous les membres de l'équipe puissent travailler sur le même état de base de données, chaque changement d'un état vers un autre doit être programmé et ajouté au Git afin que tous les membres puissent appliquer la modification. Par exemple, dans ce projet, plusieurs fichiers *.sql* sont présents dans le dossier *db_scripts/*. Ceux-ci permettent à tous les membres d'appliquer les mêmes opérations sur la base de données. Par exemple, le fichier *up.sql* permet d'initialiser la BD à son schéma initial. Afin de rouler ce fichier, vous pouvez à tout moment cliquer sur le bouton *(Re)créer la BD* dans l'interface graphique. Le fichier *drop.sql*, quant à lui, sert à effacer tout le contenu de la BD. Les deux autres fichiers sont vides pour le moment. Vous devrez les compléter dans les prochaines étapes.

## Migration de schéma

Migrer le schéma d'une BD signifie changer les définitions de ses tables. Par exemple, on peut vouloir renommer des attributs, ajouter ou supprimer des colonnes, ajouter des tables, modifier des clés etc. Une migration doit être définie par une suite d'instructions qui peuvent être appliquées au schéma actuel afin de l'amener vers le schéma cible. Dans le contexte d'un travail en équipe, tout changement au schéma de la BD doit être répertorié dans un fichier de migration, afin que tous les membres puissent appliquer les mêmes changements de leur côté. Dans le contexte d'une BD distante, ceci devrait être fait une fois uniquement.

En général, tout changement de schéma doit pouvoir être annulé. C'est ce que l'on appelle une migration arrière, ou *rollback*. En parallèle du fichier de migration, il est important de créer un fichier de *rollback* afin de pouvoir revenir à l'état précédent si cela est nécessaire.

## Empilage de migrations

Grâce à ce processus, il est possible de créer une pile de migrations, c'est-à-dire que plusieurs migrations peuvent être appliquées l'une à la suite de l'autre. En définissant un *rollback* pour chaque migration, il est donc possible de dépiler une migration en appliquant son *rollback*.


## Étape 2 - Première migration

### Migration

Vous allez mettre ce processus en pratique. Vous devez migrer le schéma de la base de données de l'état initial vers l'état numéro 1, défini dans [SCHEMA.md](SCHEMA.md).

Pour ce faire, remplissez le fichier migrate_1.sql avec une suite d'instructions SQL, afin d'obtenir le schéma désiré.

Par exemple, la table *singer* est renommée à *musician*. Vous pouvez faire ceci en écrivant la commande suivante dans le fichier:

```sql
ALTER TABLE singer RENAME TO musician;
```

À tout moment, vous pouvez tester votre migration en cliquant sur le bouton *Migrer* dans l'interface. **Attention: une fois une migration appliquée, si vous souhaitez recommencer ou retester, vous devez remettre la BD dans son état initial en cliquant sur le bouton *(Re)créer la BD*, sinon vous tenterez d'appliquer votre migration au nouveau schéma!**

Si vous obtenez une erreur lors de la migration, regardez la console de votre IDE. Une exception a probablement été lancée.

### Rollback

Une fois votre migration réussie, remplissez le fichier *rollback_1.sql* afin de passer du nouvel état post-migration à l'état initial. Attention, l'ordre des opérations SQL peut avoir une importance!

À chaque test de rollback, assurez-vous de remettre la BD à l'état initial et de ré-appliquer votre migration 1, afin d'être sûr de travailler sur un état propre.


### Tester

Si vous avez bien rempli les deux fichiers, le script de correction devrait afficher que tous les tests sont tous réussis.


## Étape 3 - Push de votre solution

⚠️ **Attention!** Limitez le nombre de pushs. Testez d'abord votre code en local, et effectuez un push uniquement lorsque tous les tests réussissent. Puisque les tests s'exécutent via GitHub Actions, le nombre de minutes est limité, donc il est important d'éviter les pushs fréquents. Un seul push suffit à la fin du travail.⚠️

Lorsque vous avez terminé, il vous suffit de créer un commit et de *push* votre branche principale:

```shell
git add .
git commit -m "Message de commit"
git push
```
