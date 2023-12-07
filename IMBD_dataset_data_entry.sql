use movies;

DROP TABLE IF EXISTS title_basics;
CREATE TABLE title_basics (
imdb_id VARCHAR(50) PRIMARY KEY,
title_type VARCHAR(50),
primaryTitle TEXT,
originalTitle TEXT,
adult BOOLEAN,
startYear INT,
endYear INT,
runtime INT,
genres TEXT
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\title.basics.tsv'
INTO TABLE title_basics
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT * FROM title_basics LIMIT 10;

DROP TABLE IF EXISTS name_basics;
CREATE TABLE name_basics (
name_id VARCHAR(50) PRIMARY KEY,
primaryName VARCHAR(255),
birthYear INT,
deathYear INT,
primaryProfession VARCHAR(255),
knownForTitles VARCHAR(255)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\name.basics.tsv'
INTO TABLE name_basics
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT * FROM name_basics LIMIT 10;
SELECT * FROM name_basics WHERE primaryName LIKE 'Mel Blanc';

DROP TABLE IF EXISTS title_crew;
CREATE TABLE title_crew (
imdb_id VARCHAR(50) PRIMARY KEY,
directors TEXT,
writers TEXT
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\title.crew.tsv'
INTO TABLE title_crew
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

ALTER TABLE title_crew
ADD FOREIGN KEY (imdb_id) REFERENCES movie_list (imdb_id) ON DELETE CASCADE;


SELECT * FROM title_crew LIMIT 10;

DROP TABLE IF EXISTS title_principals;
CREATE TABLE title_principals (
imdb_id VARCHAR(50),
ordering INT,
name_id VARCHAR(50),
category VARCHAR(255),
job TEXT,
characters TEXT
);

ALTER TABLE title_principals
ADD FOREIGN KEY (imdb_id) REFERENCES movie_list (imdb_id) ON DELETE CASCADE;
ALTER TABLE title_principals
ADD FOREIGN KEY (name_id) REFERENCES name_basics (name_id) ON DELETE CASCADE;


LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\title.principals.tsv'
INTO TABLE title_principals
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT * FROM title_principals LIMIT 10;

DROP TABLE IF EXISTS title_ratings;
CREATE TABLE title_ratings (
  imdb_id VARCHAR(50) PRIMARY KEY,
  averageRating DECIMAL(3, 1),
  name_id VARCHAR(50)
); 

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\title.ratings.tsv'
INTO TABLE title_ratings
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

ALTER TABLE title_ratings
ADD FOREIGN KEY (imdb_id) REFERENCES movie_list (imdb_id) ON DELETE CASCADE;
ALTER TABLE title_ratings
CHANGE COLUMN name_id numVotes VARCHAR(50);

SELECT * FROM title_ratings LIMIT 10;

DROP TABLE IF EXISTS title_akas;
CREATE TABLE title_akas (
  imdb_id VARCHAR(50),
  ordering INT,
  title TEXT,
  region VARCHAR(25),
  movie_language VARCHAR(25),
  movie_types VARCHAR(25),
  attributes VARCHAR(255),
  isOriginalTitle BOOLEAN
  );

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\title.akas.tsv'
INTO TABLE title_akas
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

ALTER TABLE title_akas
ADD FOREIGN KEY (imdb_id) REFERENCES movie_list (imdb_id) ON DELETE CASCADE;

SELECT * FROM title_akas LIMIT 10;