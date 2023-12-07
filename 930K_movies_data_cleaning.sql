-- 移除非英語類的數據 #442935 
DELETE FROM movie_temp WHERE original_language != 'en';

-- 移除imdb_id為空白的數據 #211241
DELETE FROM movie_temp WHERE TRIM(imdb_id) = '';

-- 移除沒有上映日的數據 #19724
DELETE FROM movie_temp WHERE TRIM(release_date) = '';

-- 移除1910以前的數據 #2604
DELETE FROM movie_temp WHERE release_date < '1910-01-01';

-- 移除2024以後的數據 #35
DELETE FROM movie_temp WHERE release_date > '2024-12-31';

-- 移除已被取消發行的電影 #1
DELETE FROM movie_temp WHERE status = 'Canceled';

-- 已發行,拍攝中,後製中,計畫中的電影數量
SELECT status, COUNT(*) AS total FROM movie_temp GROUP BY status;

-- 檢查是否有重複資料
SELECT imdb_id FROM movie_temp GROUP BY imdb_id HAVING count(*) > 1; -- 7筆資料重複
SELECT t1.id
FROM  movie_temp t1
JOIN movie_temp t2 ON t1.id > t2.id AND t1.imdb_id = t2.imdb_id;
DELETE FROM movie_temp WHERE id IN (1197374, 
1188432,
1189366,
1194731,
1199081,
1194553,
1197104);


-- 檢查資料是否都有電影名
SELECT * FROM movie_temp WHERE TRIM(title) = ''; -- 0

-- 移除imdb_id不在官網文件的資料
DELETE FROM movie_temp WHERE imdb_id NOT IN (SELECT imdb_id FROM title_basics);

-- 清整完後的電影數量 #274888
SELECT count(*) FROM movie_temp;






