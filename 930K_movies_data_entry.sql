DROP DATABASE IF EXISTS Movies;
CREATE DATABASE Movies;
USE Movies;


-- 新建暫存表以儲存符合csv檔的資料型態
CREATE TABLE movie_temp (
    id INT,
    title TEXT,
    vote_average FLOAT,
    vote_count INT,
    status VARCHAR(50),
    release_date VARCHAR(50),
    revenue BIGINT,
    runtime INT,
    adult VARCHAR(50),
    backdrop_path TEXT,
    budget BIGINT,
    homepage TEXT,
    imdb_id VARCHAR(50),
    original_language VARCHAR(20),
    original_title TEXT,
    overview TEXT,
    popularity FLOAT,
    poster_path TEXT,
    tagline TEXT,
    genres TEXT,
    production_companies TEXT,
    production_countries TEXT,
    spoken_languages TEXT
);

DROP TABLE movie_temp;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\(AMD)TMDB_movie_dataset_v11.csv'
INTO TABLE movie_temp
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT * FROM movie_temp LIMIT 10;

DROP TABLE IF EXISTS movie_list;
-- 正式的表格將imdb_id設為主鍵並修正資料型態
CREATE TABLE movie_list (
    id INT,
    title VARCHAR(255),
    vote_average FLOAT,
    vote_count INT,
    status VARCHAR(50),
    release_date VARCHAR(50),
    revenue BIGINT,
    runtime INT,
    adult VARCHAR(50),
    backdrop_path TEXT,
    budget BIGINT,
    homepage TEXT,
    imdb_id VARCHAR(50) PRIMARY KEY,
    original_language VARCHAR(20),
    original_title TEXT,
    overview TEXT,
    popularity FLOAT,
    poster_path TEXT,
    tagline TEXT,
    genres TEXT,
    production_companies TEXT,
    production_countries TEXT,
    spoken_languages TEXT
);

-- 將資料從暫存表中匯入到正式的表格
INSERT INTO movie_list
SELECT *
FROM movie_temp;

DESCRIBE movie_list;

SELECT * FROM movie_list LIMIT 10;
SELECT * FROM movie_list WHERE title LIKE '%SPIDER%MAN%';

ALTER TABLE movie_list
MODIFY COLUMN imdb_id VARCHAR(50) AFTER id;


SELECT count(*) FROM movie_list WHERE rating IS NOT NULL;
SELECT count(*) FROM movie_list WHERE vote_count IS NOT NULL or vote_count != 0; 
SELECT count(*) FROM movie_list WHERE numVotes IS NOT NULL or numVotes != 0; 
