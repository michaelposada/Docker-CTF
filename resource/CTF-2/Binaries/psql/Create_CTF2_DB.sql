CREATE TABLE users( user_id serial PRIMARY KEY, username VARCHAR(50) UNIQUE NOT NULL, password VARCHAR(50) NOT NULL);
CREATE TABLE files( file_id serial PRIMARY KEY, name TEXT, owner TEXT);
CREATE ROLE "www-data" LOGIN;
GRANT ALL PRIVILEGES 
ON ALL TABLES IN SCHEMA public TO "www-data";
INSERT INTO
   users (username, password) 
VALUES
   (
      'AdminDave', 'p4sswuuurd'
   )
;
INSERT INTO
   users (username, password) 
VALUES
   (
      'Sharon', 'MoreSecretFlag3'
   )
;
INSERT INTO
   users (username, password) 
VALUES
   (
      'Joe', 'pass'
   )
;
INSERT INTO
   files (name, owner) 
VALUES
   (
      'Bitcoin', 'AdminDave'
   )
;
INSERT INTO
   FILES (name, owner) 
VALUES
   (
      'Imporant Project', 'Sharon'
   )
;
INSERT INTO
   FILES (name, owner) 
VALUES
   (
      'flag', 'MoreSecretFlag7'
   )
;
