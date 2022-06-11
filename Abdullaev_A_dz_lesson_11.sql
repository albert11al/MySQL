/* 1) Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, catalogs и products 
в таблицу logs помещается время и дата создания записи, название таблицы, идентификатор первичного ключа и содержимое поля name.*/

DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
-- id SERIAL PRIMARY KEY, -- указано слишком много ключей; разрешено не более 1 ключа т.к. типа Archive
created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
table_name VARCHAR(25) NOT NULL,
identifier_id INT NOT NULL,
field_name_value VARCHAR(255) NOT NULL
) ENGINE = Archive;

-- для таблицы users

CREATE TRIGGER users_logs
AFTER INSERT 
ON users FOR EACH ROW
BEGIN 
	INSERT INTO shop.logs (created_at, table_name, identifier_id, field_name_value ) VALUES(CURRENT_TIMESTAMP, 'users', NEW.id, NEW.name);
END 

-- для таблицы catalogs

CREATE TRIGGER catalogs_logs
AFTER INSERT 
ON catalogs FOR EACH ROW
BEGIN 
	INSERT INTO shop.logs (created_at, table_name, identifier_id, field_name_value ) VALUES(CURRENT_TIMESTAMP, 'catalogs', NEW.id, NEW.name);
END 

-- для таблицы products

CREATE TRIGGER products_logs
AFTER INSERT 
ON products FOR EACH ROW
BEGIN 
	INSERT INTO shop.logs (created_at, table_name, identifier_id, field_name_value ) VALUES(CURRENT_TIMESTAMP, 'products', NEW.id, NEW.name);
END 

-- ----------------------------------------------------------------------------------------------

INSERT INTO users (name, birthday_at) VALUES
	('kolya', '2004-11-12');

INSERT INTO catalogs VALUES 	
	(NULL, 'Дисководы');
	
INSERT INTO products (name, description, price, catalog_id) VALUES
	('DVD', 'Дисковод PRO ELG, B250, Socket 1151, DDR4, mATX', 4760.00, 6);

select  * from logs;

-- 2) Создайте SQL-запрос, который помещает в таблицу users миллион записей.

CREATE PROCEDURE shop.insert_into_users()
BEGIN
DECLARE i INT DEFAULT 1; -- обьявляем переменную i которая будет довать номер пользователю начиная с 1
  WHILE i <= 1000000 DO -- пока i <= 1000000  выполняется условия, делается заполнение
	INSERT INTO users(name, birthday_at) VALUES (CONCAT('user-', i), NOW());
    SET i = i + 1; -- счетчик начнет присваивать номера пользователю от 1 до 1000000
  END WHILE;
END

-- test
SELECT * FROM users;

CALL insert_into_users(); 

-- SELECT * FROM users LIMIT 10;







