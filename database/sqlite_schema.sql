-- Virtual database (SQLite). Created automatically by backend/includes/database.phtml
-- the first time the website calls the back end. You never have to run this file yourself.
-- It has the same tables as bayern.sql (the MySQL / phpMyAdmin version).

DROP TABLE IF EXISTS tickets;
DROP TABLE IF EXISTS contest_entries;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS product_colors;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS stands;
DROP TABLE IF EXISTS matches;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  name          VARCHAR(60)  NOT NULL,
  email         VARCHAR(120) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role          VARCHAR(10)  NOT NULL DEFAULT 'user' CHECK (role IN ('user','admin')),
  photo         VARCHAR(255) NOT NULL,
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  name        VARCHAR(120) NOT NULL,
  category    VARCHAR(20)  NOT NULL,
  price       DECIMAL(8,2) NOT NULL,
  image       VARCHAR(255) NOT NULL,
  short_info  VARCHAR(255) NOT NULL,
  description TEXT         NOT NULL,
  sizes       VARCHAR(60)  NOT NULL DEFAULT 'S,M,L,XL,XXL',
  printable   TINYINT      NOT NULL DEFAULT 1,
  featured    TINYINT      NOT NULL DEFAULT 0
);

CREATE TABLE product_colors (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id       INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  code             VARCHAR(20)  NOT NULL,
  label            VARCHAR(30)  NOT NULL,
  swatch           VARCHAR(9)   NOT NULL DEFAULT '#cccccc',
  image            VARCHAR(255) NULL,
  name             VARCHAR(120) NULL,
  description      TEXT         NULL,
  discount_percent TINYINT      NOT NULL DEFAULT 0 CHECK (discount_percent BETWEEN 0 AND 90),
  sort_order       TINYINT      NOT NULL DEFAULT 0,
  UNIQUE (product_id, code)
);

CREATE TABLE orders (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status     VARCHAR(12) NOT NULL DEFAULT 'cart'
             CHECK (status IN ('cart','confirmed','shipped','delivered','cancelled')),
  total      DECIMAL(10,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ordered_at DATETIME  NULL
);
CREATE INDEX idx_orders_user_status ON orders (user_id, status);

CREATE TABLE order_items (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id     INTEGER NOT NULL REFERENCES orders(id)   ON DELETE CASCADE,
  product_id   INTEGER NULL     REFERENCES products(id) ON DELETE SET NULL,
  product_name VARCHAR(120) NOT NULL,
  size         VARCHAR(10)  NOT NULL DEFAULT '',
  print_name   VARCHAR(12)  NOT NULL DEFAULT '',
  print_number TINYINT      NULL,
  color        VARCHAR(20)  NOT NULL DEFAULT '',
  unit_price   DECIMAL(8,2) NOT NULL,
  quantity     TINYINT      NOT NULL DEFAULT 1
);
CREATE INDEX idx_items_order ON order_items (order_id);

CREATE TABLE contest_entries (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id          INTEGER NULL REFERENCES users(id) ON DELETE SET NULL,
  full_name        VARCHAR(80)  NOT NULL,
  email            VARCHAR(120) NOT NULL UNIQUE,
  phone            VARCHAR(30)  NOT NULL,
  country          VARCHAR(60)  NOT NULL,
  jersey_size      VARCHAR(10)  NOT NULL,
  favourite_player VARCHAR(60)  NOT NULL,
  answer           VARCHAR(140) NOT NULL,
  created_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE matches (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  competition VARCHAR(20)  NOT NULL,
  title       VARCHAR(40)  NOT NULL,
  home_name   VARCHAR(40)  NOT NULL,
  home_logo   VARCHAR(255) NOT NULL,
  away_name   VARCHAR(40)  NOT NULL,
  away_logo   VARCHAR(255) NOT NULL,
  date_label  VARCHAR(40)  NOT NULL,
  venue       VARCHAR(60)  NOT NULL
);

CREATE TABLE stands (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  code        VARCHAR(12)  NOT NULL UNIQUE,
  name        VARCHAR(30)  NOT NULL,
  badge       VARCHAR(60)  NOT NULL,
  price       DECIMAL(8,2) NOT NULL,
  block_label VARCHAR(30)  NOT NULL,
  pitch_image VARCHAR(255) NOT NULL
);

CREATE TABLE tickets (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id    INTEGER NOT NULL REFERENCES users(id)   ON DELETE CASCADE,
  match_id   INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  stand_id   INTEGER NOT NULL REFERENCES stands(id)  ON DELETE RESTRICT,
  row_no     TINYINT NOT NULL,
  seat_no    TINYINT NOT NULL,
  price      DECIMAL(8,2) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (match_id, stand_id, row_no, seat_no)
);
CREATE INDEX idx_tickets_user ON tickets (user_id);

-- version of this schema (the back end re-creates the virtual database if the number is older)
PRAGMA user_version = 6;
