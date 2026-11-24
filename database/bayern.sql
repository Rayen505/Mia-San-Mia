-- =====================================================================
--  FC Bayern website - MySQL / MariaDB database (WAMP + phpMyAdmin)
--
--  How to use: phpMyAdmin -> "Import" tab -> choose this file -> "Import".
--  It creates the database "bayern", all the tables, the administrator
--  account, the customer account of Rayen and the store products.
--
--  WARNING: importing this file again RESETS the database
--  (users, orders and products go back to the start).
--
--  Administrator login:  admin@bayern.com   /   Admin#2026
--  (change this password in the Profile page of the website)
--  Customer account:     rayenamari505@gmail.com   /   00000000
-- =====================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS `bayern`
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `bayern`;

DROP TABLE IF EXISTS `tickets`;
DROP TABLE IF EXISTS `contest_entries`;
DROP TABLE IF EXISTS `order_items`;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `product_colors`;
DROP TABLE IF EXISTS `products`;
DROP TABLE IF EXISTS `stands`;
DROP TABLE IF EXISTS `matches`;
DROP TABLE IF EXISTS `users`;

-- ---------------------------------------------------------------------
--  users : one row per account (filled by the sign up form)
--  role  : 'user' (customer) or 'admin' (can manage products and orders)
--  photo : path of the profile picture uploaded at sign up (mandatory)
--  The password is NEVER saved in clear text, only its hash.
-- ---------------------------------------------------------------------
CREATE TABLE `users` (
  `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`          VARCHAR(60)  NOT NULL,
  `email`         VARCHAR(120) NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `role`          ENUM('user','admin') NOT NULL DEFAULT 'user',
  `photo`         VARCHAR(255) NOT NULL,
  `created_at`    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_users_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
--  products : the shirts of the store ("publications"). The administrator
--  can add, edit and delete them from the website.
--  category : red | white | dark | other      sizes : comma separated list
--  featured = 1 is the big "Match kit" card at the top of the store page
-- ---------------------------------------------------------------------
CREATE TABLE `products` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`        VARCHAR(120) NOT NULL,
  `category`    VARCHAR(20)  NOT NULL,
  `price`       DECIMAL(8,2) NOT NULL,
  `image`       VARCHAR(255) NOT NULL,
  `short_info`  VARCHAR(255) NOT NULL,
  `description` TEXT         NOT NULL,
  `sizes`       VARCHAR(60)  NOT NULL DEFAULT 'S,M,L,XL,XXL',
  `printable`   TINYINT(1)   NOT NULL DEFAULT 1,
  `featured`    TINYINT(1)   NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
--  product_colors : the colours of a product (the big "Match kit" card has Red and White).
--  image / name / description NULL = the ones of the product itself.
--  (White has its own picture and is called "FC Bayern Away Kit".)
--  discount_percent : the price of this colour = price of the product - this percentage
--  (the server calculates it: White is 30% cheaper).
-- ---------------------------------------------------------------------
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

-- ---------------------------------------------------------------------
--  orders : the "commandes". Every user has at most one order with
--  status 'cart' (the basket). "Place order" changes it to 'confirmed'.
--  The administrator (or you, in phpMyAdmin) can change the status.
-- ---------------------------------------------------------------------
CREATE TABLE `orders` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`    INT UNSIGNED NOT NULL,
  `status`     ENUM('cart','confirmed','shipped','delivered','cancelled') NOT NULL DEFAULT 'cart',
  `total`      DECIMAL(10,2) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ordered_at` DATETIME NULL,
  PRIMARY KEY (`id`),
  KEY `idx_orders_user_status` (`user_id`, `status`),
  CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
--  order_items : the lines of an order (which shirt, size, name, number)
--  product_name and unit_price are copied, so an old order never changes
--  when a product is edited or deleted (product_id becomes NULL then).
-- ---------------------------------------------------------------------
CREATE TABLE `order_items` (
  `id`           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id`     INT UNSIGNED NOT NULL,
  `product_id`   INT UNSIGNED NULL,
  `product_name` VARCHAR(120) NOT NULL,
  `size`         VARCHAR(10)  NOT NULL DEFAULT '',
  `print_name`   VARCHAR(12)  NOT NULL DEFAULT '',
  `print_number` TINYINT UNSIGNED NULL,
  `color`        VARCHAR(20)  NOT NULL DEFAULT '',
  `unit_price`   DECIMAL(8,2) NOT NULL,
  `quantity`     TINYINT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `idx_items_order` (`order_id`),
  KEY `idx_items_product` (`product_id`),
  CONSTRAINT `fk_items_order`   FOREIGN KEY (`order_id`)   REFERENCES `orders` (`id`)   ON DELETE CASCADE,
  CONSTRAINT `fk_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
--  contest_entries : the "Win a free jersey" form (one entry per email)
-- ---------------------------------------------------------------------
CREATE TABLE `contest_entries` (
  `id`               INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`          INT UNSIGNED NULL,
  `full_name`        VARCHAR(80)  NOT NULL,
  `email`            VARCHAR(120) NOT NULL,
  `phone`            VARCHAR(30)  NOT NULL,
  `country`          VARCHAR(60)  NOT NULL,
  `jersey_size`      VARCHAR(10)  NOT NULL,
  `favourite_player` VARCHAR(60)  NOT NULL,
  `answer`           VARCHAR(140) NOT NULL,
  `created_at`       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_contest_email` (`email`),
  CONSTRAINT `fk_contest_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
--  matches : the matches shown on the home page and on the tickets page
--  (competition = bundesliga | cup | champions, used by the filter buttons)
-- ---------------------------------------------------------------------
CREATE TABLE `matches` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `competition` VARCHAR(20)  NOT NULL,
  `title`       VARCHAR(40)  NOT NULL,
  `home_name`   VARCHAR(40)  NOT NULL,
  `home_logo`   VARCHAR(255) NOT NULL,
  `away_name`   VARCHAR(40)  NOT NULL,
  `away_logo`   VARCHAR(255) NOT NULL,
  `date_label`  VARCHAR(40)  NOT NULL,
  `venue`       VARCHAR(60)  NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
--  stands : the 4 stands of the stadium with their ticket price
-- ---------------------------------------------------------------------
CREATE TABLE `stands` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `code`        VARCHAR(12)  NOT NULL,
  `name`        VARCHAR(30)  NOT NULL,
  `badge`       VARCHAR(60)  NOT NULL,
  `price`       DECIMAL(8,2) NOT NULL,
  `block_label` VARCHAR(30)  NOT NULL,
  `pitch_image` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_stands_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
--  tickets : one row per booked seat (8 rows x 10 seats in every stand).
--  The UNIQUE key makes it impossible to sell the same seat twice.
--  price is copied from the stand at the moment of the booking.
-- ---------------------------------------------------------------------
CREATE TABLE `tickets` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`    INT UNSIGNED NOT NULL,
  `match_id`   INT UNSIGNED NOT NULL,
  `stand_id`   INT UNSIGNED NOT NULL,
  `row_no`     TINYINT UNSIGNED NOT NULL,
  `seat_no`    TINYINT UNSIGNED NOT NULL,
  `price`      DECIMAL(8,2) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_ticket_seat` (`match_id`, `stand_id`, `row_no`, `seat_no`),
  KEY `idx_tickets_user` (`user_id`),
  CONSTRAINT `fk_tickets_user`  FOREIGN KEY (`user_id`)  REFERENCES `users`   (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tickets_match` FOREIGN KEY (`match_id`) REFERENCES `matches` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tickets_stand` FOREIGN KEY (`stand_id`) REFERENCES `stands`  (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
--  Data: the accounts (administrator + Rayen), the store products and their colours, the matches and the stands
-- ---------------------------------------------------------------------
INSERT INTO users (id, name, email, password_hash, role, photo) VALUES
  (1, 'Administrator', 'admin@bayern.com', '$2y$10$FXI2oK0/Q7frykIhXOL/Ueadg1sT4d7fBQL2OQ76Fpdpo/YzK89AG', 'admin', 'uploads/avatars/admin.png'),
  (2, 'Rayen', 'rayenamari505@gmail.com', '$2y$10$RGSB3cFyOuJMDNZbjE62B.XmYrGMNg1O95MxPrOuV2DF8R4RsE2fq', 'user', 'img/3ef3018f927a2b9d57788d7333f3f90f.jpg');

INSERT INTO `products` (id, name, category, price, image, short_info, description, sizes, printable, featured) VALUES
  (1, 'Grey Long-Sleeve Jersey', 'other', 99.95, 'img/kits/WhatsApp Image 2026-11-14 at 17.06.21.jpeg', 'Grey with black sleeves and the Opel sponsor.', 'Grey with black sleeves and the Opel sponsor. Choose your size and add your own name and number.', 'S,M,L,XL,XXL', 1, 0),
  (2, 'Red Jersey – Telekom', 'red', 89.95, 'img/kits/WhatsApp Image 2026-11-14 at 17.06.54 (1).jpeg', 'Plain red shirt with the Telekom sponsor.', 'Plain red shirt with the Telekom sponsor. Choose your size and add your own name and number.', 'S,M,L,XL,XXL', 1, 0),
  (3, 'Black Jersey – Telekom', 'dark', 89.95, 'img/kits/WhatsApp Image 2026-11-14 at 17.06.54 (2).jpeg', 'Black shirt with the Telekom sponsor.', 'Black shirt with the Telekom sponsor. Choose your size and add your own name and number.', 'S,M,L,XL,XXL', 1, 0),
  (4, 'Red & White Jersey – Telekom', 'red', 89.95, 'img/kits/WhatsApp Image 2026-11-14 at 17.06.54.jpeg', 'Red and white shirt with the Telekom sponsor.', 'Red and white shirt with the Telekom sponsor. Choose your size and add your own name and number.', 'S,M,L,XL,XXL', 1, 0),
  (5, 'Dark Pattern Jersey – Telekom', 'dark', 94.95, 'img/kits/WhatsApp Image 2026-11-14 at 17.07.05.jpeg', 'Dark shirt with a colourful print and the Telekom sponsor.', 'Dark shirt with a colourful print and the Telekom sponsor. Choose your size and add your own name and number.', 'S,M,L,XL,XXL', 1, 0),
  (6, 'Red & Blue Jersey – Opel', 'red', 89.95, 'img/kits/WhatsApp Image 2026-11-14 at 17.07.06 (1).jpeg', 'Red body with blue sleeves and the Opel sponsor.', 'Red body with blue sleeves and the Opel sponsor. Choose your size and add your own name and number.', 'S,M,L,XL,XXL', 1, 0),
  (7, 'Striped Jersey – Opel', 'red', 94.95, 'img/kits/WhatsApp Image 2026-11-14 at 17.07.06 (2).jpeg', 'Red and white stripes with the Opel sponsor.', 'Red and white stripes with the Opel sponsor. Choose your size and add your own name and number.', 'S,M,L,XL,XXL', 1, 0),
  (8, 'White Jersey – Telekom', 'white', 89.95, 'img/kits/WhatsApp Image 2026-11-14 at 17.07.06.jpeg', 'White shirt with the Telekom sponsor.', 'White shirt with the Telekom sponsor. Choose your size and add your own name and number.', 'S,M,L,XL,XXL', 1, 0),
  (9, 'Red Long-Sleeve – Iveco', 'red', 99.95, 'img/kits/WhatsApp Image 2026-11-14 at 17.07.07 (1).jpeg', 'Red long-sleeve shirt with the Iveco sponsor.', 'Red long-sleeve shirt with the Iveco sponsor. Choose your size and add your own name and number.', 'S,M,L,XL,XXL', 1, 0),
  (10, 'White & Grey Jersey – Liga total!', 'white', 89.95, 'img/kits/WhatsApp Image 2026-11-14 at 17.07.07 (2).jpeg', 'Light grey and white shirt with the Liga total! sponsor.', 'Light grey and white shirt with the Liga total! sponsor. Choose your size and add your own name and number.', 'S,M,L,XL,XXL', 1, 0),
  (11, 'Navy Jersey – Telekom', 'dark', 89.95, 'img/kits/WhatsApp Image 2026-11-14 at 17.07.07 (3).jpeg', 'Navy shirt with the Telekom sponsor.', 'Navy shirt with the Telekom sponsor. Choose your size and add your own name and number.', 'S,M,L,XL,XXL', 1, 0),
  (12, 'Navy & Red Jersey – Opel', 'dark', 94.95, 'img/kits/WhatsApp Image 2026-11-14 at 17.07.07.jpeg', 'Navy shirt with red details and the Opel sponsor.', 'Navy shirt with red details and the Opel sponsor. Choose your size and add your own name and number.', 'S,M,L,XL,XXL', 1, 0),
  (13, 'Blue Jersey – Opel', 'other', 94.95, 'img/kits/WhatsApp Image 2026-11-14 at 17.07.08 (1).jpeg', 'Blue shirt with a pattern and the Opel sponsor.', 'Blue shirt with a pattern and the Opel sponsor. Choose your size and add your own name and number.', 'S,M,L,XL,XXL', 1, 0),
  (14, 'Yellow Jersey – Opel', 'other', 94.95, 'img/kits/WhatsApp Image 2026-11-14 at 17.07.08.jpeg', 'Yellow shirt with black and green stripes and the Opel sponsor.', 'Yellow shirt with black and green stripes and the Opel sponsor. Choose your size and add your own name and number.', 'S,M,L,XL,XXL', 1, 0),
  (15, 'FC Bayern Home Kit', 'red', 99.95, 'img/front.jpg', 'The official match shirt in Bayern red.', 'The official match shirt in Bayern red. Choose your size, add your name and number, and wear it on match day.', 'S,M,L,XL,XXL', 1, 1);
INSERT INTO `product_colors` (product_id, code, label, swatch, image, name, description, discount_percent, sort_order) VALUES
  (15, 'red', 'Red', '#dc052d', NULL, NULL, NULL, 0, 1),
  (15, 'white', 'White', '#ffffff', 'img/whitejersey.jpg', 'FC Bayern Away Kit', 'The official away shirt in white. Choose your size, add your name and number, and wear it on match day.', 30, 2);

INSERT INTO `matches` (id, competition, title, home_name, home_logo, away_name, away_logo, date_label, venue) VALUES
  (1, 'bundesliga', 'Bundesliga', 'Bayern', 'FC_Bayern_München_logo_(2017).svg.png', 'Dortmund', 'img/Borussia_Dortmund_logo.svg.png', 'Sat 15 Nov · 18:30', 'Allianz Arena'),
  (2, 'champions', 'Champions League', 'Bayern', 'FC_Bayern_München_logo_(2017).svg.png', 'Paris', 'img/20180604160737!Paris_Saint-Germain_Logo.svg', 'Wed 19 Nov · 21:00', 'Allianz Arena'),
  (3, 'bundesliga', 'Bundesliga', 'Leipzig', 'img/RB_Leipzig_2014_logo.svg.png', 'Bayern', 'FC_Bayern_München_logo_(2017).svg.png', 'Sat 29 Nov · 15:30', 'Leipzig'),
  (4, 'cup', 'DFB-Pokal', 'Bayern', 'FC_Bayern_München_logo_(2017).svg.png', 'Köln', 'img/1._FC_Koeln_Logo_2014–.svg.png', 'Tue 2 Dec · 20:45', 'Allianz Arena'),
  (5, 'bundesliga', 'Bundesliga', 'Bayern', 'FC_Bayern_München_logo_(2017).svg.png', 'Stuttgart', 'img/VfB_Stuttgart_1893_Logo.svg', 'Sat 6 Dec · 18:30', 'Allianz Arena'),
  (6, 'champions', 'Champions League', 'Madrid', 'img/20190512221327!Logo_Real_Madrid.svg', 'Bayern', 'FC_Bayern_München_logo_(2017).svg.png', 'Wed 10 Dec · 21:00', 'Madrid');

INSERT INTO `stands` (id, code, name, badge, price, block_label, pitch_image) VALUES
  (1, 'west', 'WESTSTAND', 'HAUPTTRIBÜNE • VIP & EXECUTIVE', 195.00, 'Block 102–104', 'img/stadium/pitch-west.jpg'),
  (2, 'ost', 'OSTSTAND', 'GEGENTRIBÜNE • PRIME CAT 1', 180.00, 'Block 112–115', 'img/stadium/pitch-ost.jpg'),
  (3, 'sued', 'SÜDKURVE', 'FAN TRIBÜNE • ULTRAS SECTION', 85.00, 'Block 131–134', 'img/stadium/pitch-sued.jpg'),
  (4, 'nord', 'NORDKURVE', 'NORTH STAND • FAMILY & FANS', 95.00, 'Block 121–124', 'img/stadium/pitch-nord.jpg');

SET FOREIGN_KEY_CHECKS = 1;
