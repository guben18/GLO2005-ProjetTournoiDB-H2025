CREATE DATABASE IF NOT EXISTS TournoiPedia;
USE TournoiPedia;

CREATE TABLE Utilisateurs (id_utilisateur INT PRIMARY KEY, pseudo VARCHAR(50) UNIQUE NOT NULL, courriel VARCHAR(100) UNIQUE NOT NULL, DDN DATE NULL, pays VARCHAR(50) NULL, password_hash VARCHAR(255) NOT NULL, created_at DATE);

CREATE TABLE Organisations (id_org INT PRIMARY KEY, nom_org VARCHAR(100) NOT NULL, description TEXT, site VARCHAR(255), created_at DATE);

CREATE TABLE Joueurs (id_utilisateur INT PRIMARY KEY, matches_joues INT DEFAULT 0, match_gagnes INT DEFAULT 0, created_at DATE,
                     FOREIGN KEY (id_utilisateur) REFERENCES Utilisateurs(id_utilisateur));

CREATE TABLE OrgaTournoi (id_utilisateur INT PRIMARY KEY, tournois_organises INT DEFAULT 0, created_at DATE,
                         FOREIGN KEY (id_utilisateur) REFERENCES Utilisateurs(id_utilisateur));
            
CREATE TABLE Equipes (id_equipe INT PRIMARY KEY, id_org INT, nom_equipe VARCHAR(100) NOT NULL, status ENUM('actif', 'inactif') DEFAULT 'actif', matches_joues INT DEFAULT 0, match_gagnes INT DEFAULT 0, created_at DATE,
                     FOREIGN KEY(id_org) REFERENCES Organisations(id_org));

CREATE TABLE JoueursEquipes (id_utilisateur INT, id_equipe INT, PRIMARY KEY (id_utilisateur, id_equipe), 
                            FOREIGN KEY (id_utilisateur) REFERENCES Utilisateurs(id_utilisateur), FOREIGN KEY (id_equipe) REFERENCES Equipes(id_equipe));

CREATE TABLE Tournois (id_tournoi INT PRIMARY KEY, id_organisateur INT, nom_tournoi VARCHAR(255) NOT NULL, type_tournoi ENUM('solo', 'equipe'), nbre_participants INT, date_debut DATE, status ENUM('actif', 'a venir', 'termine'),
                       FOREIGN KEY (id_organisateur) REFERENCES OrgaTournoi(id_utilisateur));

CREATE TABLE TournoiEquipe (id_equipe INT UNIQUE, id_tournoi INT, 
                        PRIMARY KEY (id_equipe, id_tournoi), FOREIGN KEY (id_equipe) REFERENCES Equipes(id_equipe), FOREIGN KEY (id_tournoi) REFERENCES Tournois(id_tournoi));

CREATE TABLE TournoiSolo (id_utilisateur INT UNIQUE, id_tournoi INT, 
                        PRIMARY KEY (id_utilisateur, id_tournoi), FOREIGN KEY (id_utilisateur) REFERENCES Utilisateurs(id_utilisateur), FOREIGN KEY (id_tournoi) REFERENCES Tournois(id_tournoi));

CREATE TABLE Matches (id_match INT PRIMARY KEY, id_tournoi INT NOT NULL, id_equipe1 INT, id_equipe2 INT, id_joueur1 INT, id_joueur2 INT, id_gagnant_joueur INT, id_gagnant_equipe INT, date_match DATE, status ENUM('en cours', 'a venir', 'fini'), round INT,
                     FOREIGN KEY (id_tournoi) REFERENCES Tournois(id_tournoi), FOREIGN KEY (id_equipe1) REFERENCES Equipes(id_equipe), FOREIGN KEY (id_equipe2) REFERENCES Equipes(id_equipe), FOREIGN KEY (id_joueur1) REFERENCES Joueurs(id_utilisateur), FOREIGN KEY (id_joueur2) REFERENCES Joueurs(id_utilisateur), FOREIGN KEY (id_gagnant_joueur) REFERENCES Joueurs(id_utilisateur), FOREIGN KEY (id_gagnant_equipe) REFERENCES Equipes(id_equipe));

INSERT INTO Utilisateurs (pseudo, courriel, password_hash, DDN, pays, created_at) VALUES (%s, %s, %s, %s, %s, NOW()); -- Inscription (role gere en backend selon selection) -- 

SELECT id_utilisateur, pseudo, password_hash  FROM Utilisateurs  WHERE pseudo = %s; -- Connexion --

SELECT u.id_utilisateur, u.pseudo, u.courriel, u.DDN, u.pays, e.nom_equipe AS team, COUNT(DISTINCT t.id_tournoi) AS total_tournaments, j.matches_joues, j.match_gagnes FROM Utilisateurs u
LEFT JOIN Joueurs j ON u.id_utilisateur = j.id_utilisateur
LEFT JOIN JoueursEquipes je ON u.id_utilisateur = je.id_utilisateur
LEFT JOIN Equipes e ON je.id_equipe = e.id_equipe
LEFT JOIN TournoiSolo ts ON u.id_utilisateur = ts.id_utilisateur
LEFT JOIN Tournois t ON ts.id_tournoi = t.id_tournoi
WHERE u.pseudo = %s
GROUP BY u.id_utilisateur, e.nom_equipe, j.matches_joues, j.match_gagnes; -- Requete infos profil joueur --

                     
DELIMITER //

CREATE TRIGGER nbJoueurs_nbEquipes BEFORE INSERT ON Matches FOR EACH ROW
BEGIN
DECLARE nb_joueurs INT;
DECLARE nb_equipes INT;

SET nb_joueurs = (NEW.id_joueur1 IS NOT NULL) + (NEW.id_joueur2 IS NOT NULL);
SET nb_equipes = (NEW.id_equipe1 IS NOT NULL) + (NEW.id_equipe2 IS NOT NULL);

IF NOT (nb_joueurs = 2 AND nb_equipes = 0) OR (nb_joueurs = 0 AND nb_equipes = 2) THEN 
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un match doit contenir deux joueurs ou deux equipes.';
END IF;
END;
//

CREATE TRIGGER maxTournoiSolo BEFORE INSERT ON TournoiSolo FOR EACH ROW 
BEGIN 
DECLARE nb_inscrits INT;
DECLARE max_participants INT;
SELECT COUNT(*), nbre_participants INTO nb_inscrits, max_participants FROM Tournois LEFT JOIN TournoiSolo ON Tournois.id_tournoi = TournoiSolo.id_tournoi WHERE Tournois.id_tournoi = NEW.id_tournoi;
IF nb_inscrits >= max_participants THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Le tournoi a atteint le nombre maximum de participants.';
END IF;
END;
//

CREATE TRIGGER maxTournoiEquipe BEFORE INSERT ON TournoiEquipe FOR EACH ROW 
BEGIN 
DECLARE nb_inscrits INT;
DECLARE max_participants INT;
SELECT COUNT(*), nbre_participants INTO nb_inscrits, max_participants FROM Tournois LEFT JOIN TournoiEquipe ON Tournois.id_tournoi = TournoiEquipe.id_tournoi WHERE Tournois.id_tournoi = NEW.id_tournoi;
IF nb_inscrits >= max_participants THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Le tournoi a atteint le nombre maximum de participants.';
END IF;
END;
//

CREATE TRIGGER typeTournoiEquipe BEFORE INSERT ON TournoiEquipe FOR EACH ROW
BEGIN
DECLARE type_tournoi enum('solo', 'equipe');
SELECT type_tournoi INTO type_tournoi FROM Tournois WHERE id_tournoi = NEW.id_tournoi;
IF type_tournoi <> 'solo' THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Veuillez vous inscrire en equipe uniquement.';
END IF;
END;
//

CREATE TRIGGER typeTournoiSolo BEFORE INSERT ON TournoiSolo FOR EACH ROW
BEGIN
DECLARE type_tournoi enum('solo', 'equipe');
SELECT type_tournoi INTO type_tournoi FROM Tournois WHERE id_tournoi = NEW.id_tournoi;
IF type_tournoi <> 'equipe' THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Veuillez vous inscrire en equipe uniquement.';
END IF;
END;
//

DELIMITER ;
