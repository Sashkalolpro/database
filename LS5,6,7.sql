/* ДЗ УРОК 5 */

USE vk;
SELECT * FROM users;
DESC users;
/* ДЗ 5 задание 1 */
UPDATE users SET created_at = from_unixtime(FLOOR(RAND() * (1574121600-1160438400) + 1160438400)); -- задаем полю даты регистрации пользователя значение от 10 октября 2006 (дата создания ВК) до 19 ноября 2019 
/* ДЗ 5 задание 2 */
ALTER TABLE users ADD COLUMN test_field VARCHAR(255) AFTER updated_at; -- тестовое поле для реализации задания 2 по теме “Операторы, фильтрация, сортировка и ограничение”
UPDATE users SET test_field = '20.10.2017 8:10' WHERE id = 1; -- задаем тестовое значение
UPDATE users SET test_field = str_to_date(test_field, '%d.%m.%Y %k:%i'); 
ALTER TABLE users CHANGE test_field test_field DATETIME DEFAULT current_timestamp;
/* ДЗ 5 задание 3 */
SELECT * FROM media  ORDER BY (size = 0), size; -- задание №3 по сортировке в порядке увеличения и нулями в конце. 
SELECT * FROM media  ORDER BY (CASE WHEN size = 0 THEN 1 ELSE 0 END), size;         

SELECT * FROM profiles;
/* ДЗ 5 задание 1 агрегация данных*/
SELECT AVG(TIMESTAMPDIFF(YEAR, birthday, NOW())) AS AVG_AGE FROM profiles; -- средний возраст пользователей (задание 1 по теме “Агрегация данных”)
/* ДЗ 5 задание 2 агрегация данных*/
SELECT
	DATE_FORMAT(DATE(CONCAT_WS('-', YEAR(NOW()), MONTH(birthday), DAY(birthday))), '%W') AS day, 
    COUNT(*) AS total 
FROM profiles    
GROUP BY
	day
ORDER BY
	total DESC;
    
    
/* ДЗ УРОК 6 */
/* ДЗ УРОК 6 задание 2 */    
SELECT * FROM messages;
/* для наглядности, находим пользователя, которому больше всего писали */
SELECT 
	to_user_id, COUNT(*) AS all_messages_to
FROM 
	messages
GROUP BY 
	to_user_id
ORDER BY 
	all_messages_to DESC; 
 
 /* посчитал количество сообщений ОТ друга заданному пользователю, как учесть еще и обратные сообщения - быстрого решения не нашел =(  */
SELECT
	from_user_id AS friend_spammer, COUNT(*)
FROM 
	messages
WHERE 
	to_user_id = 73
AND 
	from_user_id IN (
        SELECT friend_id 
          FROM friendship 
            WHERE user_id = 73 
              AND status_id IN (
                SELECT id FROM friendship_statuses 
                  WHERE name != 'Rejected'
              ))
GROUP BY 
	from_user_id;
    
SELECT * FROM friendship;
SELECT * FROM messages;
UPDATE friendship SET friend_id = 107, status_id = 3 WHERE user_id = 73;
INSERT INTO messages (from_user_id, to_user_id, body, is_delivered) VALUES (73, 107, 'test nessage', 1); 

/* ДЗ УРОК 6 задание 3 */ 
SELECT COUNT(target_id) AS likes FROM likes 
WHERE target_id IN (
SELECT user_id FROM (
SELECT user_id, birthday  FROM profiles ORDER BY birthday DESC LIMIT 10) AS tbl);


/* ДЗ УРОК 6 задание 4 */ 
SELECT
	COUNT(user_id) AS total_likes,
    (SELECT sex FROM profiles WHERE user_id = 1) AS sex
FROM
	likes
WHERE 
	user_id IN (
    SELECT user_id
    FROM
		profiles
	WHERE sex='f')
UNION
SELECT
	COUNT(user_id) AS total_likes,
    (SELECT sex FROM profiles WHERE user_id = 4) AS sex
FROM
	likes
WHERE 
	user_id IN (
    SELECT user_id FROM profiles WHERE sex='m'
    )
ORDER BY total_likes DESC
LIMIT 1;

/* ДЗ УРОК 6 задание 5 */ 
SELECT id, updated_at FROM (SELECT id, updated_at  FROM users ORDER BY updated_at  LIMIT 10) as last_iaction
UNION 
(SELECT user_id, created_at FROM posts ORDER BY created_at  LIMIT 10) 
UNION
(SELECT from_user_id, created_at FROM messages ORDER BY created_at  LIMIT 10) 
UNION
(SELECT user_id, created_at FROM media ORDER BY created_at  LIMIT 10) 
UNION
(SELECT user_id, created_at FROM likes ORDER BY created_at  LIMIT 10) 
;

SELECT id, updated_at FROM (SELECT id, updated_at  FROM users ) as last_iaction
UNION 
(SELECT user_id, created_at FROM posts ) 
UNION
(SELECT from_user_id, created_at FROM messages ) 
UNION
(SELECT user_id, created_at FROM media ) 
UNION
(SELECT user_id, created_at FROM likes ) 
GROUP BY id
ORDER BY updated_at
;







/* ДЗ УРОК 7 задание 1 */ 
SELECT u.id, u.name FROM users AS u
WHERE u.id = ANY (SELECT user_id FROM orders);
/* ДЗ УРОК 7 задание 2 */ 
SELECT p.name, c.name FROM products AS p, cat AS c;