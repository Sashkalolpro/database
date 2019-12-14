/* ДЗ УРОК 7 задание 1 */ 
use SHOP;
SELECT u.id, u.name 
FROM 
	users AS u
JOIN 
	orders AS o
ON u.id = o.user_id;

/* ДЗ УРОК 7 задание 2 */ 
SELECT p.name, c.name FROM products AS p, cat AS c; -- старый вариант 

SELECT 
	p.name, c.name
FROM 
	products AS p
LEFT JOIN 
	catalogs AS c
ON p.catalog_id = c.id;

/* ДЗ УРОК 8 задание 1 */
USE vk;
ALTER TABLE profiles MODIFY COLUMN photo_id INT(10) UNSIGNED;

ALTER TABLE profiles
  ADD CONSTRAINT profiles_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT profiles_photo_id_fk
    FOREIGN KEY (photo_id) REFERENCES media(id)
      ON DELETE SET NULL;
      
ALTER TABLE messages
  ADD CONSTRAINT messages_from_user_id_fk 
    FOREIGN KEY (from_user_id) REFERENCES users(id),
  ADD CONSTRAINT messages_to_user_id_fk 
    FOREIGN KEY (to_user_id) REFERENCES users(id),
  ADD CONSTRAINT messages_attached_media_id_fk 
    FOREIGN KEY (attached_media_id) REFERENCES media(id)
      ON DELETE SET NULL;

ALTER TABLE friendship
  ADD CONSTRAINT friendship_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT friendship_friend_id_fk  
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT friendship_status_id_fk  
    FOREIGN KEY (status_id) REFERENCES friendship_statuses(id);
    
ALTER TABLE posts
  ADD CONSTRAINT posts_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
	  ON DELETE CASCADE,
  ADD CONSTRAINT posts_attached_media_id_fk
    FOREIGN KEY (attached_media_id) REFERENCES media(id)
      ON DELETE SET NULL;

ALTER TABLE media
  ADD CONSTRAINT media_media_type_id_fk
    FOREIGN KEY (media_type_id) REFERENCES media_types(id),
  ADD CONSTRAINT media_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE;

ALTER TABLE relations
  ADD CONSTRAINT relations_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT relations_relation_status_id_fk
    FOREIGN KEY (relation_status_id) REFERENCES relation_statuses(id);
    
ALTER TABLE communities
  ADD CONSTRAINT communities_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE RESTRICT; -- запрет на удаление, если пользователь не передал права на группу
  
ALTER TABLE communities_users
  ADD CONSTRAINT communities_users_community_id_fk
    FOREIGN KEY (community_id) REFERENCES communities(id),
  ADD CONSTRAINT communities_users_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE;
      
ALTER TABLE likes
  ADD CONSTRAINT likes_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT likes_target_type_id_fk
    FOREIGN KEY (target_type_id) REFERENCES target_types(id),  
  ADD CONSTRAINT likes_like_type_id_fk 
    FOREIGN KEY (like_type_id) REFERENCES like_types(id);
    
    
/* ДЗ УРОК 8 задание 2 */
-- скриншот приложен на Geekbrains

/* ДЗ УРОК 8 задание 3 */

-- 1 Пусть задан некоторый пользователь. Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользоваетелем.
SELECT 
  m.from_user_id, COUNT(*) AS total_messages
FROM 
  messages AS m
JOIN friendship AS f
  ON m.to_user_id = f.user_id
    OR m.from_user_id = f.user_id
WHERE f.user_id = 73
GROUP BY m.from_user_id
ORDER BY total_messages DESC
  LIMIT 1;

  -- 2 Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.
SELECT SUM(got_like) AS total_youngest
  FROM (
    SELECT
     profiles.user_id, COUNT(likes.target_id) AS got_like 
    FROM
      likes
    RIGHT JOIN 
      profiles
    ON likes.target_id = profiles.user_id
      AND likes.target_type_id = 2 
    GROUP BY profiles.user_id
    ORDER BY profiles.birthday DESC
    LIMIT 10
) AS 10_yougest;

SELECT * FROM profiles ORDER BY birthday DESC LIMIT 10;
  
  
  -- 3  Определить кто больше поставил лайков (всего) - мужчины или женщины?
  SELECT profiles.sex AS SEX, 
  COUNT(likes.id) AS total_likes
  FROM likes
    JOIN profiles
      ON likes.user_id = profiles.user_id
    GROUP BY profiles.sex
    ORDER BY total_likes DESC
    LIMIT 1;
    
-- 4 Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.
SELECT users.id,
  COUNT(DISTINCT messages.id) + COUNT(DISTINCT likes.id) + COUNT(DISTINCT media.id) AS total_activity 
  FROM users
    LEFT JOIN messages 
      ON users.id = messages.from_user_id
    LEFT JOIN likes
      ON users.id = likes.user_id
    LEFT JOIN media
      ON users.id = media.user_id
  GROUP BY users.id
  ORDER BY activity
  LIMIT 10;
  /* 
  так и не придумал как реализовать данную задачу по последней по времени активности
SELECT
 u.id,
 u.updated_at AS action_in_profile,
 p.created_at AS last_post,
 m.created_at AS last_message 
 FROM users AS u
JOIN posts AS p 
JOIN messages AS m;
 */


