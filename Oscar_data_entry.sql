USE movies;

DROP TABLE IF EXISTS oscars;
CREATE TABLE oscars (
ceremony INT,
year_ceremony VARCHAR(10),
class VARCHAR(50),
canonicalCategory VARCHAR(255),
category VARCHAR(255),
nomId VARCHAR(50),
title VARCHAR(255),
imdb_id VARCHAR(50),
primaryName TEXT,
nominees TEXT,
nomineeId TEXT,
winner VARCHAR(50),
detail TEXT,
note TEXT,
citation TEXT,
multiFilmNomination VARCHAR(50)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\oscars.csv'
INTO TABLE oscars
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@ceremony, @year_ceremony, @class, @canonicalCategory, @category, @nomId, @title, @imdb_id, @primaryName, @nominees, @nomineeId, @winner, @detail, @note, @citation, @multiFilmNomination)
SET
  ceremony = NULLIF(@ceremony, ''),
  year_ceremony = NULLIF(@year_ceremony, ''),
  class = NULLIF(@class, ''),
  canonicalCategory = NULLIF(@canonicalCategory, ''),
  category = NULLIF(@category, ''),
  nomId = NULLIF(@nomId, ''),
  title = NULLIF(@title, ''),
  imdb_id = NULLIF(@imdb_id, ''),
  primaryName = NULLIF(@primaryName, ''),
  nominees = NULLIF(@nominees, ''),
  nomineeId = NULLIF(@nomineeId, ''),
  winner = NULLIF(@winner, ''),
  detail = NULLIF(@detail, ''),
  note = NULLIF(@note, ''),
  citation = NULLIF(@citation, ''),
  multiFilmNomination = NULLIF(@multiFilmNomination, '');

UPDATE oscars
SET winner = 'False'
WHERE winner IS NULL;

UPDATE oscars
SET  multiFilmNomination = 'False'
WHERE  multiFilmNomination IS NULL;

UPDATE oscars
SET year_ceremony = SUBSTRING_INDEX(year_ceremony, '/', -1)
WHERE year_ceremony LIKE '%/%';


DELETE FROM oscars WHERE imdb_id NOT IN (SELECT imdb_id FROM movie_list);

ALTER TABLE oscars
ADD FOREIGN KEY (imdb_id) REFERENCES movie_list (imdb_id) ON DELETE CASCADE;

SELECT * FROM oscars LIMIT 10;
                        
                            
        
