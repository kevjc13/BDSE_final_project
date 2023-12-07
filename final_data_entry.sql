USE movies;

-- 備份資料表
DROP TABLE IF EXISTS final_list;
CREATE TABLE final_list (
    id INT,
    imdb_id VARCHAR(50) PRIMARY KEY,
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

INSERT INTO final_list
SELECT *
FROM movie_list;

-- 插入導演
ALTER TABLE movie_list
ADD COLUMN director TEXT;

UPDATE movie_list m
SET m.director = (
    SELECT GROUP_CONCAT(primaryName SEPARATOR ', ')
    FROM title_principals p
    JOIN name_basics n ON n.name_id = p.name_id
    WHERE p.imdb_id = m.imdb_id AND p.category = 'director'
);

-- 插入編劇
ALTER TABLE movie_list
ADD COLUMN writer TEXT AFTER director;

UPDATE movie_list m
SET m.writer = (
	SELECT GROUP_CONCAT(primaryName SEPARATOR ', ')
    FROM title_principals p
    JOIN name_basics n ON n.name_id = p.name_id
    WHERE p.imdb_id = m.imdb_id AND p.category = 'writer'
);

-- 插入編劇與導演相同的電影
UPDATE movie_list m
SET m.writer = COALESCE(m.writer, (
		SELECT primaryName 
        FROM title_crew c 
        JOIN name_basics n ON c.writers = n.name_id 
        WHERE m.imdb_id = c.imdb_id
        )
	),
    m.director = COALESCE(m.director, (
		SELECT primaryName
        FROM title_crew c
        JOIN name_basics n ON c.directors = n.name_id
        WHERE m.imdb_id = c.imdb_id
        )
	);

-- 定義一個遞歸的數字表，生成一個從 1 到 100 的數字序列
WITH RECURSIVE numbers AS (
  SELECT 1 AS value
  UNION ALL
  SELECT value + 1 AS value
  FROM numbers
  WHERE value < 100
),
-- 使用前面創建的數字表，將 title_crew 表中的逗號分隔的 directors 和 writers 字段拆分成單獨的 ID
split_values AS (
  SELECT imdb_id,
    directors,
    SUBSTRING_INDEX(SUBSTRING_INDEX(directors, ',', numbers.value), ',', -1) as director_id,
    writers,
    SUBSTRING_INDEX(SUBSTRING_INDEX(writers, ',', numbers.value), ',', -1) as writer_id
  FROM
    title_crew,
    numbers
  WHERE
    numbers.value <= LENGTH(directors) - LENGTH(REPLACE(directors, ',', '')) + 1
    OR numbers.value <= LENGTH(writers) - LENGTH(REPLACE(writers, ',', '')) + 1
),
-- 基於 split_values 表，聚合每個 imdb_id 對應的所有 writer_id/director_id 的名字
writer_names AS (
  SELECT split_values.imdb_id, 
         GROUP_CONCAT(name_basics.primaryName SEPARATOR ', ') AS writer_names
  FROM split_values
  JOIN name_basics ON name_basics.name_id = split_values.writer_id
  GROUP BY split_values.imdb_id
),
director_names AS(
  SELECT split_values.imdb_id, 
         GROUP_CONCAT(name_basics.primaryName SEPARATOR ', ') AS director_names
  FROM split_values
  JOIN name_basics ON name_basics.name_id = split_values.director_id
  GROUP BY split_values.imdb_id
)
UPDATE movie_list m
LEFT JOIN writer_names wn ON m.imdb_id = wn.imdb_id
LEFT JOIN director_names dn ON m.imdb_id = dn.imdb_id
SET m.writer = COALESCE(m.writer, wn.writer_names),
    m.director = COALESCE(m.director, dn.director_names);


-- 插入演員
ALTER TABLE movie_list
ADD COLUMN cast TEXT;

UPDATE movie_list m
SET m.cast = (
	SELECT GROUP_CONCAT(primaryName SEPARATOR ', ')
    FROM title_principals p 
	JOIN name_basics n ON n.name_id = p.name_id
	WHERE p.imdb_id = m.imdb_id AND (category = 'actor' or category = 'actress')
);

-- 插入評分及評分人數
ALTER TABLE movie_list
ADD COLUMN rating DECIMAL(3, 1),
ADD COLUMN numVotes INT;

UPDATE movie_list m
SET 
	m.rating = (
	SELECT averageRating
    FROM title_ratings r
    WHERE m.imdb_id = r.imdb_id
),
	m.numVotes = (
	SELECT numVotes
    FROM title_ratings r
    WHERE m.imdb_id = r.imdb_id
);

-- 插入奧斯卡提名數
ALTER TABLE movie_list
ADD COLUMN oscarNominations INT;

UPDATE movie_list m
SET m.oscarNominations = (
	SELECT count(*)
	FROM oscars o
	WHERE m.imdb_id = o.imdb_id
	GROUP BY imdb_id 
);

UPDATE movie_list
SET oscarNominations = 0
WHERE oscarNominations IS NULL;

-- 插入奧斯卡獲獎數
ALTER TABLE movie_list
ADD COLUMN oscarWinner INT;

UPDATE movie_list m
SET m.oscarWinner = (
    SELECT SUM(CASE WHEN o.winner = 'True' THEN 1 ELSE 0 END)
    FROM oscars o
    WHERE m.imdb_id = o.imdb_id
);

-- 插入奧斯卡提名獎項名
ALTER TABLE movie_list
ADD COLUMN oscarNominationCategory TEXT AFTER oscarNominations;

UPDATE movie_list m
SET m.oscarNominationCategory = (
	SELECT GROUP_CONCAT(DISTINCT canonicalCategory SEPARATOR ', ')
    FROM oscars o
    WHERE m.imdb_id = o.imdb_id
);

-- 插入奧斯卡獲獎獎項名
ALTER TABLE movie_list
ADD COLUMN oscarWinnerCategory TEXT AFTER oscarWinner ;

UPDATE movie_list m
SET m.oscarWinnerCategory = (
	SELECT GROUP_CONCAT(DISTINCT canonicalCategory SEPARATOR ', ')
    FROM oscars o
    WHERE m.imdb_id = o.imdb_id AND o.winner = 'True'
);

ALTER TABLE movie_list
DROP COLUMN backdrop_path,
DROP COLUMN homepage,
DROP COLUMN poster_path;

-- 歷年奧斯卡獎項
SELECT distinct canonicalCategory FROM oscars; # 71 rows
SELECT distinct canonicalCategory FROM oscars WHERE class = 'acting'; #6 

-- 驗證得獎演員id與imdb官方資料是否相同
SELECT DISTINCT primaryName, nomineeId FROM oscars WHERE class = 'acting';
SELECT nomineeId FROM oscars WHERE class = 'acting' AND nomineeId NOT IN (SELECT name_id FROM name_basics); #0

-- 新增前4卡司以及演員是否得到當屆的奧斯卡
ALTER TABLE movie_list
ADD COLUMN cast1 VARCHAR(255), 
ADD COLUMN cast2 VARCHAR(255), 
ADD COLUMN cast3 VARCHAR(255),
ADD COLUMN cast4 VARCHAR(255),
ADD COLUMN isActingWinner VARCHAR(10);

-- 電影卡司,並依照官方的名單順序,增加一個排序欄位
WITH ranked AS (
	SELECT m.imdb_id, n.name_id, n.primaryName as name, ROW_NUMBER() OVER (partition by imdb_id) AS leadingRoleRank
	FROM movie_list m
	JOIN title_principals p ON m.imdb_id = p.imdb_id
	JOIN name_basics n ON n.name_id = p.name_id
	WHERE category = 'actor' or category = 'actress'
),
-- 歷屆男女主角及男女配角
actingWinner AS ( 
	SELECT imdb_id, nomineeId
	FROM oscars
    WHERE class = 'acting' AND winner = 'True'
)
-- 劇組排名在前4外卻得獎的人數 
-- SELECT COUNT(*) FROM ranked r JOIN actingWinner a ON r.imdb_id = a.imdb_id  AND r.name_id = a.nomineeId WHERE r.leadingRoleRank > 4; #0

 UPDATE movie_list m
 SET 
	cast1 = ( SELECT r.name FROM ranked r WHERE m.imdb_id = r.imdb_id AND leadingRoleRank = 1 ),
	cast2 = ( SELECT r.name FROM ranked r WHERE m.imdb_id = r.imdb_id AND leadingRoleRank = 2 ),
	cast3 = ( SELECT r.name FROM ranked r WHERE m.imdb_id = r.imdb_id AND leadingRoleRank = 3 ),
	cast4 = ( SELECT r.name FROM ranked r WHERE m.imdb_id = r.imdb_id AND leadingRoleRank = 4 ),
	isActingWinner = 
					CASE
						WHEN m.cast1 IN (SELECT r.name FROM ranked r JOIN actingWinner a ON r.imdb_id = a.imdb_id AND r.name_id = a.nomineeId WHERE m.imdb_id =r.imdb_id) OR
							 m.cast2 IN (SELECT r.name FROM ranked r JOIN actingWinner a ON r.imdb_id = a.imdb_id AND r.name_id = a.nomineeId WHERE m.imdb_id =r.imdb_id) OR
							 m.cast3 IN (SELECT r.name FROM ranked r JOIN actingWinner a ON r.imdb_id = a.imdb_id AND r.name_id = a.nomineeId WHERE m.imdb_id =r.imdb_id) OR
							 m.cast4 IN (SELECT r.name FROM ranked r JOIN actingWinner a ON r.imdb_id = a.imdb_id AND r.name_id = a.nomineeId WHERE m.imdb_id =r.imdb_id)
						THEN 'True'
						ELSE 'False'
					END;

SELECT COUNT(*) FROM movie_list WHERE isActingWinner = 'True'; #294

UPDATE movie_list m
SET m.genres = ( SELECT b.genres FROM title_basics b WHERE m.imdb_id = b.imdb_id )
WHERE m.genres IS NULL;

ALTER TABLE movie_list
RENAME COLUMN adult to isAdult,
ADD COLUMN Action TINYINT AFTER genres,
ADD COLUMN Adult TINYINT AFTER Action,
ADD COLUMN Adventure TINYINT AFTER Adult,
ADD COLUMN Animation TINYINT AFTER Adventure,
ADD COLUMN Biography TINYINT AFTER Animation,
ADD COLUMN Comedy TINYINT AFTER Biography,
ADD COLUMN Crime TINYINT AFTER Comedy,
ADD COLUMN Documentary TINYINT AFTER Crime,
ADD COLUMN Drama TINYINT AFTER Documentary,
ADD COLUMN Family TINYINT AFTER Drama,
ADD COLUMN Fantasy TINYINT AFTER Family,
ADD COLUMN GameShow TINYINT AFTER Fantasy,
ADD COLUMN History TINYINT AFTER GameShow,
ADD COLUMN Horror TINYINT AFTER History,
ADD COLUMN Music TINYINT AFTER Horror,
ADD COLUMN Musical TINYINT AFTER Music,
ADD COLUMN Mystery TINYINT AFTER Musical,
ADD COLUMN News TINYINT AFTER Mystery,
ADD COLUMN RealityTV TINYINT AFTER News,
ADD COLUMN Romance TINYINT AFTER RealityTV,
ADD COLUMN SciFi TINYINT AFTER Romance,
ADD COLUMN Short TINYINT AFTER SciFi,
ADD COLUMN Sport TINYINT AFTER Short,
ADD COLUMN TalkShow TINYINT AFTER Sport,
ADD COLUMN Thriller TINYINT AFTER TalkShow,
ADD COLUMN TV_Movie TINYINT AFTER Thriller,
ADD COLUMN War TINYINT AFTER TV_Movie,
ADD COLUMN Western TINYINT AFTER War;

ALTER TABLE movie_list
ADD COLUMN other TINYINT AFTER Western;

WITH split_genres AS (
	SELECT DISTINCT
		TRIM(BOTH ' ' FROM SUBSTRING_INDEX(SUBSTRING_INDEX(genres, ',', n.digit + 1), ',', -1)) AS genre
	FROM
		movie_list
		JOIN (
			SELECT (pow(2,(@num:=@num+1))-1) AS digit
			FROM (
				SELECT 1 UNION ALL
				SELECT 2 UNION ALL
				SELECT 3 UNION ALL
				SELECT 4 UNION ALL
				SELECT 5 UNION ALL
                SELECT 6
			) t
			CROSS JOIN (SELECT @num:=0) d
		) n
		ON LENGTH(genres) - LENGTH(REPLACE(genres, ',', '')) >= n.digit
	ORDER BY
		genre
)
-- SELECT COUNT(*) FROM split_genres; #29個電影類別
-- SELECT * FROM split_genres; 
UPDATE movie_list
SET Action = CASE WHEN genres LIKE '%action%' THEN 1 ELSE 0 END,
    Adult = CASE WHEN genres LIKE '%adult%' THEN 1 ELSE 0 END,
    Adventure = CASE WHEN genres LIKE '%adventure%' THEN 1 ELSE 0 END,
    Animation = CASE WHEN genres LIKE '%animation%' THEN 1 ELSE 0 END,
    Biography = CASE WHEN genres LIKE '%biography%' THEN 1 ELSE 0 END,
    Comedy = CASE WHEN genres LIKE '%comedy%' THEN 1 ELSE 0 END,
    Crime = CASE WHEN genres LIKE '%crime%' THEN 1 ELSE 0 END,
    Documentary = CASE WHEN genres LIKE '%documentary%' THEN 1 ELSE 0 END,
    Drama = CASE WHEN genres LIKE '%drama%' THEN 1 ELSE 0 END,
    Family = CASE WHEN genres LIKE '%family%' THEN 1 ELSE 0 END,
    Fantasy = CASE WHEN genres LIKE '%fantasy%' THEN 1 ELSE 0 END,
    GameShow = CASE WHEN genres LIKE '%Game-Show%' THEN 1 ELSE 0 END,
    History = CASE WHEN genres LIKE '%history%' THEN 1 ELSE 0 END,
    Horror = CASE WHEN genres LIKE '%horror%' THEN 1 ELSE 0 END,
    Music = CASE WHEN genres LIKE '%music%' THEN 1 ELSE 0 END,
    Musical = CASE WHEN genres LIKE '%musical%' THEN 1 ELSE 0 END,
    Mystery = CASE WHEN genres LIKE '%mystery%' THEN 1 ELSE 0 END,
    News = CASE WHEN genres LIKE '%news%' THEN 1 ELSE 0 END,
    RealityTV = CASE WHEN genres LIKE '%Reality-TV%' THEN 1 ELSE 0 END,
    Romance = CASE WHEN genres LIKE '%romance%' THEN 1 ELSE 0 END,
    SciFi = CASE WHEN genres LIKE '%sci-fi%' OR genres LIKE '%science fiction%' THEN 1 ELSE 0 END,
    Short = CASE WHEN genres LIKE '%short%' THEN 1 ELSE 0 END,
    Sport = CASE WHEN genres LIKE '%sport%' THEN 1 ELSE 0 END,
    TalkShow = CASE WHEN genres LIKE '%talk-show%' THEN 1 ELSE 0 END,
    Thriller = CASE WHEN genres LIKE '%thriller%' THEN 1 ELSE 0 END,
    TV_Movie = CASE WHEN genres LIKE '%tv movie%' THEN 1 ELSE 0 END,
    War = CASE WHEN genres LIKE '%war%' THEN 1 ELSE 0 END,
    Western = CASE WHEN genres LIKE '%western%' THEN 1 ELSE 0 END,
    Other = CASE WHEN genres IS NULL THEN 1 ELSE 0 END;

-- 沒有電影類型的資料
SELECT COUNT(*) FROM movie_list WHERE genres IS NULL; #2162
-- 沒有電影類型,但有導演,編劇,卡司,得獎紀錄
DELETE FROM movie_list WHERE genres IS NULL AND director IS NULl AND writer IS NULL AND cast IS NULL; #180
SELECT * FROM movie_list WHERE genres IS NULL AND director IS NULl AND writer IS NULL AND cast IS NOT NULL; #103


SELECT COUNT(*) FROM movie_list; #274708
SELECT * FROM movie_list WHERE title LIKE 'Inception' or title LIKE 'everything everywhere all at once';
SELECT * FROM movie_list WHERE title LIKE 'Top Gun%';
SELECT COUNT(*) FROM movie_list WHERE budget != 0 AND budget IS NOT NULL;
SELECT COUNT(*) FROM movie_list WHERE numVotes != 0 or numVotes IS NOT NULL;

SELECT COUNT(*) AS num_columns
FROM information_schema.columns
WHERE table_name = 'movie_list' AND table_schema = 'movies';

SELECT * FROM movie_list WHERE status != 'Released' AND director IS NOT NULL ORDER BY release_date;

CREATE TABLE movie_prediction_list
SELECT * FROM movie_list WHERE status != 'Released';

SELECT * FROM movie_prediction_list;
