/*1. Пусть задан некоторый пользователь. 
 * Из всех друзей этого пользователя найдите человека, 
 * который больше всех общался с выбранным пользователем (написал ему сообщений).*/

SELECT
    from_user_id fu, COUNT(*) as 'number'  
FROM 
	messages m
join 
	friend_requests fr 
on
	(fr.initiator_user_id=m.from_user_id and fr.target_user_id=1)
or 
	(fr.target_user_id =m.from_user_id and fr.initiator_user_id =1)
WHERE 
	to_user_id = 1 and fr.status ='approved' 
GROUP BY fu
ORDER BY COUNT(fu) DESC; -- сортирует начиная от большего к меньшему количество смс


-- 2. Подсчитать общее количество лайков, которые получили пользователи младше 11 лет.

SELECT 
	count(*) as 'likes count' -- Количество лайков
FROM 
	likes l
JOIN 
	media m 
	ON l.media_id = m.id
JOIN 
	profiles p 
	ON p.user_id = m.user_id
WHERE  
	TIMESTAMPDIFF(YEAR, birthday, NOW()) < 11;

-- 3. Определить кто больше поставил лайков (всего): мужчины или женщины.		

SELECT 
	CASE (gender)
         WHEN 'm' THEN 'мужчин'
         WHEN 'f' THEN 'женщин'
    END AS 'больше всех', COUNT(*) as 'likes'
FROM 
	profiles p 
JOIN
	likes l 
WHERE 
	l.user_id = p.user_id 
GROUP BY gender;

/*SELECT 
	CASE (gender)
         WHEN 'm' THEN 'мужчин'
         WHEN 'f' THEN 'женщин'
    END AS 'больше всех', COUNT(*) as 'likes'
FROM users u
LEFT JOIN profiles p ON p.user_id = u.id
LEFT JOIN likes l ON l.user_id = u.id
WHERE l.media_id AND p.gender = 'm' --'f'
-- UNION;*/















