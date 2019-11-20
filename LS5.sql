USE vk;
SELECT * FROM users;
DESC users;
UPDATE users SET created_at = from_unixtime(FLOOR(RAND() * (1574121600-1160438400) + 1160438400)); -- задаем полю даты регистрации пользователя значение от 10 октября 2006 (дата создания ВК) до 19 ноября 2019 
ALTER TABLE users ADD COLUMN test_field VARCHAR(255) AFTER updated_at; -- тестовое поле для реализации задания 2 по теме “Операторы, фильтрация, сортировка и ограничение”
UPDATE users SET test_field = '20.10.2017 8:10' WHERE id = 1;
-- решение не нашел =(

SELECT * FROM media  ORDER BY (size = 0), size; -- задание №3 по сортировке в порядке увеличения и нулями в конце. 
SELECT * FROM media  ORDER BY (CASE WHEN size = 0 THEN 1 ELSE 0 END), size;         

SELECT * FROM profiles;
SELECT AVG(TIMESTAMPDIFF(YEAR, birthday, NOW())) AS AVG_AGE FROM profiles; -- средний возраст пользователей (задание 1 по теме “Агрегация данных”)

SELECT dayname(
