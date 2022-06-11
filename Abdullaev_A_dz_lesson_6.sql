/*1. Пусть задан некоторый пользователь. 
Из всех друзей этого пользователя найдите человека, 
который больше всех общался с нашим пользователем.*/

SELECT
    from_user_id, COUNT(*) as 'number'  
FROM messages 
where to_user_id = 1 -- пользователь который получал смс
AND from_user_id IN ( -- пользовтель который больше всех писал смс to_user_id
     select initiator_user_id from friend_requests -- друг который сам подружился
     WHERE (target_user_id = 1) and status ='approved'
     UNION
     select target_user_id from friend_requests -- друг с которым подружился
     WHERE (initiator_user_id = 1) and status ='approved' 
)
GROUP BY from_user_id
ORDER BY COUNT(from_user_id) DESC; -- сортирует начиная от большего к меньшему количество смс

/*SELECT firstname, lastname FROM users WHERE id = (
SELECT from_user_id -- , COUNT(*) as 'number of sms' -- отдельно можно посмотреть количество смс от пользователя
	FROM messages
	WHERE to_user_id = 1 -- пользователь который получал смс
	GROUP BY from_user_id -- пользовтель который больше всех писал смс to_user_id
	ORDER BY COUNT(from_user_id) DESC -- ; -- сортирует начиная от большего к меньшему количество смс
	limit 1
	);   -- покажет только одного пользователя */

-- select firstname, lastname from users where id = messages.from_user_id -- мы обрашаемся к табл users и ничего не знаем про messages.from_user_id
-- в таком случе ее нужно делать вложенным и обозначить т.е AS 'sgfndhg'
-- -------------------------------------------------------------------------------------------------------------------


-- 2. Подсчитать общее количество лайков, которые получили пользователи младше 11 лет.
	
SELECT count(*) as 'likes count' -- Количество лайков
FROM likes
WHERE media_id IN ( -- Все медиа записи, где есть ссылка на пользователя user_id
	SELECT id 
	FROM media 
	WHERE user_id IN ( -- Все пользователи младше 11 лет
		SELECT 
			user_id -- , birthday
		FROM profiles AS p
		WHERE  TIMESTAMPDIFF(YEAR, birthday, NOW()) < 11
	)
);

/* SELECT user_id as 'кто лайкнул', media_id as 'кого лайкнул' FROM likes -- обшая количество лайков
	WHERE user_id in (
	SELECT user_id /*, birthday*//* FROM profiles -- все пользователи
		WHERE TIMESTAMPDIFF(YEAR, birthday, NOW()) < 11);*/ -- пользователи младше 11 лет. это пользователь 2 и 7
-- ------------------------------------------------------------------------------------------------------------------------
-- 3. Определить кто больше поставил лайков (всего): мужчины или женщины.		
		
SELECT 
	CASE (gender)
         WHEN 'm' THEN 'мужчин'
         WHEN 'f' THEN 'женщин'
    END AS 'больше всех', COUNT(*) as 'likes'
FROM (SELECT user_id as profile, (SELECT gender FROM profiles WHERE user_id = profile) AS gender FROM likes) AS likes
GROUP BY gender
LIMIT 1;



















