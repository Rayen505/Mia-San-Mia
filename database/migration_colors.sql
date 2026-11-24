-- =====================================================================
--  UPDATE of an existing MySQL database (keeps your users, orders and tickets)
--  Adds the colours (Red / White) of the big "Match kit" card.
--
--  phpMyAdmin -> click the database "bayern" -> "Import" tab -> choose this file -> "Import".
--  Run it ONCE. (If you prefer to start again from zero, import bayern.sql instead.)
-- =====================================================================

SET NAMES utf8mb4;
USE `bayern`;

CREATE TABLE IF NOT EXISTS `product_colors` (
  `id`               INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_id`       INT UNSIGNED NOT NULL,
  `code`             VARCHAR(20)  NOT NULL,
  `label`            VARCHAR(30)  NOT NULL,
  `swatch`           VARCHAR(9)   NOT NULL DEFAULT '#cccccc',
  `image`            VARCHAR(255) NULL,
  `discount_percent` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `sort_order`       TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_color` (`product_id`, `code`),
  CONSTRAINT `fk_colors_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- the colour chosen for each line of an order
ALTER TABLE `order_items` ADD COLUMN `color` VARCHAR(20) NOT NULL DEFAULT '' AFTER `print_number`;

-- Red (the picture of the product) and White (30% cheaper) for the product shown as the big "Match kit" card
INSERT IGNORE INTO `product_colors` (product_id, code, label, swatch, image, discount_percent, sort_order)
  SELECT id, 'red', 'Red', '#dc052d', NULL, 0, 1 FROM `products` WHERE featured = 1;
INSERT IGNORE INTO `product_colors` (product_id, code, label, swatch, image, discount_percent, sort_order)
  SELECT id, 'white', 'White', '#ffffff', 'img/whitejersey.png', 30, 2 FROM `products` WHERE featured = 1;
