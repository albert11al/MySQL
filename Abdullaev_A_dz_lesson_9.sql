-- --------------------------------------
-- Транзакции, переменные, представления
-- --------------------------------------

/* 1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.*/

-- БД sample из ДЗ 2-го урока.
-- решение в файле Abdullaev_A_dz_lesson_9_task_1.1
/*START TRANSACTION;

INSERT INTO sample.users 
SELECT id, name 
FROM shop.users 
WHERE id = 1;

DELETE FROM shop.users
WHERE id=1; 

COMMIT;*/
-- ----------------------------------------------------------------------
SELECT * FROM users;

/* 2. Создайте представление, которое выводит название name товарной позиции из таблицы products 
и соответствующее название каталога name из таблицы catalogs.*/

CREATE OR REPLACE VIEW products_catalogs 
	AS
SELECT products.name AS product, catalogs.name AS catalog
	FROM
		products 
	RIGHT JOIN
		catalogs
	ON
		products .catalog_id = catalogs.id;

-- Обратимся к представлению
SELECT * FROM products_catalogs;

-- ---------------------------------------
-- Хранимые процедуры и функции, триггеры
-- ---------------------------------------

/* 1. Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", 
с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
с 18:00 до 00:00 — "Добрый вечер", 
с 00:00 до 6:00 — "Доброй ночи".*/

CREATE FUNCTION hello()
RETURNS TEXT DETERMINISTIC -- тип DETERMINISTIC выбрано т.к. входные и выходные данные одинаковы 
BEGIN
	DECLARE time INT;  --  обьявляем переменную time
	SET time = HOUR(now());  -- присваиваем значение time которая ровна текушему времени и дате
	CASE
		WHEN time BETWEEN 0 AND 5 THEN  -- BETWEEN ... AND ... Находится ли значение в диапазоне значений. если нет то тогда THEN
			RETURN 'Доброй ночи!';		-- RETURN фия которая возрашает какое то значение
		WHEN time BETWEEN 6 AND 11 THEN 
			RETURN 'Доброе утро!';
		WHEN time BETWEEN 12 AND 17 THEN 
			RETURN 'Добрый день!';
		WHEN time BETWEEN 18 AND 23 THEN 
			RETURN 'Добрый вечер!';
	END CASE;
END

SELECT hello() as greeting, now() as time_now;

/* 2. В таблице products есть два текстовых поля: name с названием товара и description с его описанием.
Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. 
Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. 
При попытке присвоить полям NULL-значение необходимо отменить операцию. */ 

-- triger
CREATE TRIGGER name_description_insert
BEFORE INSERT 				-- Ключевое слово BEFORE указывает время действия триггера. 
ON products FOR EACH ROW	-- В этом случае триггер срабатывает перед каждой вставленной в таблицу строкой.

BEGIN
    IF NEW.name IS NULL AND NEW.description IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Сработал Тригер! NULL в обоих полях!';
	END IF;
END
/*если name с названием товара принимает значение NULL и description с его описанием если тоже будет NULL 
 * то тогда посылается сигнал на срабатывание ошибки
 */ 

SELECT * FROM products; 

INSERT INTO products (name, description)
VALUES (NULL, NULL); -- Ошибка, предупреждение о триггере

INSERT INTO products (name, description)
VALUES ("GeForce GTX 1080", NULL); -- нет ошибки

INSERT INTO products (name, description)
VALUES ("GeForce GTX 1080", "Мощная видеокарта"); -- нет ошибки








