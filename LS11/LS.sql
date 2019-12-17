/* ДЗ 9.1  “Транзакции, переменные, представления”
 В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных.
 Переместите запись id = 1 из таблицы shop.users в таблицу sample.users.
Используйте транзакции. */
 
INSERT INTO sample.users SELECT * FROM shop.users WHERE id = 1;
DELETE FROM shop.users WHERE id = 1;

/* ДЗ 9.2 “Транзакции, переменные, представления”
Создайте представление, которое выводит название name товарной позиции из таблицы products
и соответствующее название каталога name из таблицы catalogs */
USE SHOP;
CREATE OR REPLACE VIEW name_from_produscts_catalogs AS 
SELECT 
  p.name AS product_name,
  c.name AS catalog_name
FROM products AS p
JOIN catalogs AS c
ON c.id = p.catalog_id;

/* ДЗ 9.1 Администрирование MySQL”
Создайте двух пользователей которые имеют доступ к базе данных shop.
 Первому пользователю shop_read должны быть доступны только запросы на чтение данных,
 второму пользователю shop — любые операции в пределах базы данных shop */
CREATE USER 'shop_read'@'localhost';
GRANT SELECT, SHOW VIEW ON shop.* TO 'shop_read'@'localhost' IDENTIFIED BY ''; -- только чтение
CREATE USER 'shop'@'localhost';
GRANT ALL ON shop.* TO 'shop'@'localhost' IDENTIFIED BY ''; -- все права

/* ДЗ 9.2 Администрирование MySQL”
Пусть имеется таблица accounts содержащая три столбца id, name, password, содержащие первичный ключ, имя пользователя и его пароль.
Создайте представление username таблицы accounts, предоставляющий доступ к столбца id и name. Создайте пользователя user_read,
 который бы не имел доступа к таблице accounts, однако, мог бы извлекать записи из представления username. */
 
CREATE OR REPLACE VIEW username AS SELECT id, name FROM accounts;
CREATE USER 'user_read'@'localhost';
GRANT SELECT (id, name) ON shop.username TO 'user_read'@'localhost';

/* ДЗ 9.1 Хранимые процедуры и функции, триггеры"
Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток.
С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день",
 с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи". */

SET GLOBAL log_bin_trust_function_creators = 1;
DROP FUNCTION IF EXISTS hello;

DELIMITER //

CREATE FUNCTION hello (hour INT)
RETURNS VARCHAR(255) NOT DETERMINISTIC
BEGIN
  CASE
    WHEN hour BETWEEN 0 AND 5 THEN
      RETURN "Доброй ночи";
    WHEN hour BETWEEN 6 AND 11 THEN
      RETURN "Доброе утро";
    WHEN hour BETWEEN 12 AND 17 THEN
      RETURN "Добрый день";
    WHEN hour BETWEEN 18 AND 23 THEN
      RETURN "Добрый вечер";
  END CASE;
END//

SELECT hello (13)//

/* ДЗ 9.2 Хранимые процедуры и функции, триггеры"
В таблице products есть два текстовых поля: name с названием товара и description с его описанием.
Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное
значение NULL неприемлема. Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены.
При попытке присвоить полям NULL-значение необходимо отменить операцию. */

DELIMITER //

CREATE TRIGGER two_NULL_insert BEFORE INSERT ON products
FOR EACH ROW BEGIN
IF NEW.name IS NULL AND NEW.description IS NULL THEN
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'One of this parametrs: name or description, must be NOT NULL';
END IF;
END//

CREATE TRIGGER two_NULL_update BEFORE UPDATE ON products
FOR EACH ROW BEGIN
IF NEW.name IS NULL AND NEW.description IS NULL THEN
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'One of this parametrs: name or description, must be NOT NULL';
END IF;
END//



DELIMITER ;



/* ДЗ 10.1 Проанализировать какие запросы могут выполняться наиболее часто в процессе работы приложения и добавить необходимые индексы. */

-- происходит ли автоматическая индексация FOREIGN KEY так же как и главного ключа ?   если нет - то тогда это имеет смысл для большинства полей,
-- т к я бы делал индексы на те поля, которые часто попадают в WHERE, GROUP BY, ORDER BY и ON при объединении, а в этих случаях чаще всего и используются ключи
-- И, наверное имеет смысл сделать индексы на дату создания (например для создания отсортированной по дате ленты постов или сообщений между пользователями),
-- но исключить то, что имеет поле UPDATED, т к тогда придется проводить индексацию по нему и часто переиндексировать, т к эти данные могут обновиться 

CREATE INDEX messages_created_at_idx On messages(created_at);
CREATE INDEX posts_created_at_idx On posts(created_at);


/* ДЗ 10.2. Задание на оконные функции
Построить запрос, который будет выводить следующие столбцы:
имя группы
среднее количество пользователей в группах
самый молодой пользователь в группе
самый пожилой пользователь в группе
общее количество пользователей в группе
всего пользователей в системе
отношение в процентах (общее количество пользователей в группе / всего пользователей в системе) * 100 */

-- получилось посчитать только среднее значение пользователей в группе
-- при попытке реализовать другие "столбцы" данные получались не адекватными =( 


USE vk;
SELECT DISTINCT communities.name, communities.id,
COUNT(*) OVER (PARTITION BY communities.id) AS users_in_group
  FROM (communities
    JOIN communities_users ON communities.id = communities_users.community_id
    JOIN users ON communities_users.user_id = users.id);

