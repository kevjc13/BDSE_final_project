-- 移除imdb_id不在basics表格的資料
DELETE FROM title_ratings WHERE imdb_id NOT IN (SELECT imdb_id FROM title_basics); #1
DELETE FROM title_principals WHERE imdb_id NOT IN (SELECT imdb_id FROM title_basics); #379
SELECT name_id FROM title_principals WHERE name_id NOT IN (SELECT name_id FROM name_basics); #158 #id:nm2007716 
DELETE FROM title_principals WHERE name_id = 'nm2007716'; -- 上面語法跑太久了(1616 sec),改直接用id刪除
DELETE FROM title_akas WHERE imdb_id NOT IN (SELECT imdb_id FROM title_basics);


-- 移除imdb_id不在930k資料表的資料, 才可建立外鍵
DELETE FROM title_crew WHERE imdb_id NOT IN (SELECT imdb_id FROM movie_list); #10055431
DELETE FROM title_principals WHERE imdb_id NOT IN (SELECT imdb_id FROM movie_list); #56984878
DELETE FROM title_ratings WHERE imdb_id NOT IN (SELECT imdb_id FROM movie_list); #1163200
DELETE FROM title_akas WHERE imdb_id NOT IN (SELECT imdb_id FROM movie_list); #36212978