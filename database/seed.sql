-- Data put in the virtual database when it is created: the administrator account and the store products.
-- Administrator login:  admin@bayern.com  /  Admin#2026   (change the password in your profile page!)
-- Customer account:     rayenamari505@gmail.com  /  00000000
INSERT INTO users (id, name, email, password_hash, role, photo) VALUES
  (1, 'Administrator', 'admin@bayern.com', '$2y$10$FXI2oK0/Q7frykIhXOL/Ueadg1sT4d7fBQL2OQ76Fpdpo/YzK89AG', 'admin', 'uploads/avatars/admin.png'),
  (2, 'Rayen', 'rayenamari505@gmail.com', '$2y$10$RGSB3cFyOuJMDNZbjE62B.XmYrGMNg1O95MxPrOuV2DF8R4RsE2fq', 'user', 'img/3ef3018f927a2b9d57788d7333f3f90f.jpg');

INSERT INTO products (id, name, category, price, image, short_info, description, sizes, printable, featured) VALUES
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

INSERT INTO product_colors (product_id, code, label, swatch, image, name, description, discount_percent, sort_order) VALUES
  (15, 'red', 'Red', '#dc052d', NULL, NULL, NULL, 0, 1),
  (15, 'white', 'White', '#ffffff', 'img/whitejersey.jpg', 'FC Bayern Away Kit', 'The official away shirt in white. Choose your size, add your name and number, and wear it on match day.', 30, 2);

INSERT INTO matches (id, competition, title, home_name, home_logo, away_name, away_logo, date_label, venue) VALUES
  (1, 'bundesliga', 'Bundesliga', 'Bayern', 'FC_Bayern_München_logo_(2017).svg.png', 'Dortmund', 'img/Borussia_Dortmund_logo.svg.png', 'Sat 15 Nov · 18:30', 'Allianz Arena'),
  (2, 'champions', 'Champions League', 'Bayern', 'FC_Bayern_München_logo_(2017).svg.png', 'Paris', 'img/20180604160737!Paris_Saint-Germain_Logo.svg', 'Wed 19 Nov · 21:00', 'Allianz Arena'),
  (3, 'bundesliga', 'Bundesliga', 'Leipzig', 'img/RB_Leipzig_2014_logo.svg.png', 'Bayern', 'FC_Bayern_München_logo_(2017).svg.png', 'Sat 29 Nov · 15:30', 'Leipzig'),
  (4, 'cup', 'DFB-Pokal', 'Bayern', 'FC_Bayern_München_logo_(2017).svg.png', 'Köln', 'img/1._FC_Koeln_Logo_2014–.svg.png', 'Tue 2 Dec · 20:45', 'Allianz Arena'),
  (5, 'bundesliga', 'Bundesliga', 'Bayern', 'FC_Bayern_München_logo_(2017).svg.png', 'Stuttgart', 'img/VfB_Stuttgart_1893_Logo.svg', 'Sat 6 Dec · 18:30', 'Allianz Arena'),
  (6, 'champions', 'Champions League', 'Madrid', 'img/20190512221327!Logo_Real_Madrid.svg', 'Bayern', 'FC_Bayern_München_logo_(2017).svg.png', 'Wed 10 Dec · 21:00', 'Madrid');

INSERT INTO stands (id, code, name, badge, price, block_label, pitch_image) VALUES
  (1, 'west', 'WESTSTAND', 'HAUPTTRIBÜNE • VIP & EXECUTIVE', 195.00, 'Block 102–104', 'img/stadium/pitch-west.jpg'),
  (2, 'ost', 'OSTSTAND', 'GEGENTRIBÜNE • PRIME CAT 1', 180.00, 'Block 112–115', 'img/stadium/pitch-ost.jpg'),
  (3, 'sued', 'SÜDKURVE', 'FAN TRIBÜNE • ULTRAS SECTION', 85.00, 'Block 131–134', 'img/stadium/pitch-sued.jpg'),
  (4, 'nord', 'NORDKURVE', 'NORTH STAND • FAMILY & FANS', 95.00, 'Block 121–124', 'img/stadium/pitch-nord.jpg');
