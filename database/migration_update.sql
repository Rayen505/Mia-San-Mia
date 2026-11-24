-- =====================================================================
--  UPDATE of an existing MySQL database (KEEPS your users, orders and tickets)
--
--  It adds / updates:
--    * the colours of the big "Match kit" card (Red = Home Kit, White = Away Kit, 30% off)
--    * the customer account of Rayen
--
--  phpMyAdmin -> click the database "bayern" -> "Import" tab -> choose this file -> "Import".
--  It can be imported again without problem. (To start again from zero, import bayern.sql instead.)
-- =====================================================================

SET NAMES utf8mb4;
USE `bayern`;

DROP PROCEDURE IF EXISTS `bayern_update`;

DELIMITER $$
CREATE PROCEDURE `bayern_update`()
BEGIN
  -- table of the colours (created only if it does not exist yet)
  IF NOT EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'product_colors') THEN
    CREATE TABLE `product_colors` (
      `id`               INT UNSIGNED NOT NULL AUTO_INCREMENT,
      `product_id`       INT UNSIGNED NOT NULL,
      `code`             VARCHAR(20)  NOT NULL,
      `label`            VARCHAR(30)  NOT NULL,
      `swatch`           VARCHAR(9)   NOT NULL DEFAULT '#cccccc',
      `image`            VARCHAR(255) NULL,
      `name`             VARCHAR(120) NULL,
      `description`      TEXT         NULL,
      `discount_percent` TINYINT UNSIGNED NOT NULL DEFAULT 0,
      `sort_order`       TINYINT UNSIGNED NOT NULL DEFAULT 0,
      PRIMARY KEY (`id`),
      UNIQUE KEY `uq_color` (`product_id`, `code`),
      CONSTRAINT `fk_colors_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
  END IF;

  -- name and description of a colour (added only if missing)
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'product_colors' AND COLUMN_NAME = 'name') THEN
    ALTER TABLE `product_colors` ADD COLUMN `name` VARCHAR(120) NULL AFTER `image`;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'product_colors' AND COLUMN_NAME = 'description') THEN
    ALTER TABLE `product_colors` ADD COLUMN `description` TEXT NULL AFTER `name`;
  END IF;

  -- the colour chosen for each line of an order (added only if missing)
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'order_items' AND COLUMN_NAME = 'color') THEN
    ALTER TABLE `order_items` ADD COLUMN `color` VARCHAR(20) NOT NULL DEFAULT '' AFTER `print_number`;
  END IF;
END$$
DELIMITER ;

CALL `bayern_update`();
DROP PROCEDURE `bayern_update`;

-- Red (the picture and name of the product) and White (Away Kit, 30% cheaper) for the product shown as the big "Match kit" card
INSERT IGNORE INTO `product_colors` (product_id, code, label, swatch, image, name, description, discount_percent, sort_order)
  SELECT id, 'red', 'Red', '#dc052d', NULL, NULL, NULL, 0, 1 FROM `products` WHERE featured = 1;
INSERT IGNORE INTO `product_colors` (product_id, code, label, swatch, image, name, description, discount_percent, sort_order)
  SELECT id, 'white', 'White', '#ffffff', 'img/whitejersey.jpg', 'FC Bayern Away Kit',
         'The official away shirt in white. Choose your size, add your name and number, and wear it on match day.', 30, 2
    FROM `products` WHERE featured = 1;
-- if the colours were added by an older version, bring White up to date
UPDATE `product_colors` SET image = 'img/whitejersey.jpg', name = 'FC Bayern Away Kit',
       description = 'The official away shirt in white. Choose your size, add your name and number, and wear it on match day.'
 WHERE code = 'white' AND name IS NULL;

-- the customer account of Rayen (nothing happens if the email already exists)
INSERT IGNORE INTO `users` (name, email, password_hash, role, photo)
  VALUES ('Rayen', 'rayenamari505@gmail.com', '$2y$10$RGSB3cFyOuJMDNZbjE62B.XmYrGMNg1O95MxPrOuV2DF8R4RsE2fq', 'user', 'img/3ef3018f927a2b9d57788d7333f3f90f.jpg');
