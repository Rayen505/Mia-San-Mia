# FC Bayern – dynamic website (Vue.js 3 + PHP + MySQL)

Mini-projets *Atelier Framework côté client* and *Atelier Développement Web* (DSI2, 2026/2027).

- **Front end:** Vue.js 3, Vue Router, Bootstrap 5 (`src/`)
- **Back end:** PHP in `.phtml` files (`backend/`)
- **Database:** a *virtual* database that works right now (SQLite file), and the real **MySQL / phpMyAdmin** database of WAMP (`database/bayern.sql`). You switch with one word.

## Requirements of the specification

| Requirement | Where it is done |
|---|---|
| Dynamic site, data read from a database | the store, orders, profiles are all read from the database |
| HTML5, CSS3, JavaScript, Bootstrap | `src/` (Vue components + `src/assets/css/`) |
| PHP and SQL | `backend/*.phtml` and `database/bayern.sql` |
| **CRUD** (insert, display, update, delete) | see the CRUD table below |
| **Authentication** | sign up, log in, log out, sessions, roles (`user` / `admin`) |
| **User photo is mandatory at sign up** | the sign up form has a required photo (JPG/PNG/WEBP, 2 MB), saved in `backend/uploads/avatars/` |
| **Log in before browsing the list of publications** | the store (list of products) is hidden behind a "join the club" screen until the visitor has an account and is logged in. The server also refuses `products.phtml` without a session. |
| Responsive design | Bootstrap grid, navbar, tables, forms (tested on phone size) |
| Deliver the pages + a `.sql` file | `database/bayern.sql` is in the archive |

**"Publications" = the products (shirts) of the store.**

### CRUD map

| | What | File |
|---|---|---|
| **C**reate | sign up (user + photo) | `signup.phtml` |
| | add a product (administrator, with picture) | `product_create.phtml` |
| | add to cart / place an order | `cart_add.phtml`, `checkout.phtml` |
| | book seats for a match (tickets) | `ticket_book.phtml` |
| | contest entry | `contest.phtml` |
| **R**ead | list of products | `products.phtml` |
| | my profile, my cart, my orders | `me.phtml`, `cart.phtml`, `orders.phtml` |
| | matches, stands, free seats of a match | `matches.phtml`, `match_seats.phtml` |
| | my tickets | `tickets.phtml` |
| | all customer orders (administrator) | `admin_orders.phtml` |
| **U**pdate | edit a product (administrator) | `product_update.phtml` |
| | edit my name, email, photo / change my password | `profile_update.phtml`, `password_update.phtml` |
| | change a quantity in the cart | `cart_update.phtml` |
| | order status (administrator) / cancel my order | `admin_order_status.phtml`, `order_cancel.phtml` |
| **D**elete | delete a product (administrator) | `product_delete.phtml` |
| | cancel a ticket (the seat is free again) | `ticket_cancel.phtml` |
| | remove an item from the cart | `cart_remove.phtml` |
| | delete my account | `account_delete.phtml` |

---

## 1. Where to put the project

1. Install **WAMP** and start it (the tray icon must be **green**).
2. Put the whole `bayern-vue` folder inside WAMP's `www` folder:

   ```
   C:\wamp64\www\bayern-vue\
   ```
3. Copy your photos into `public/` (they are not in the archive):

   ```
   public/
   ├── FC_Bayern_München_logo_(2017).svg.png   ← your logo
   └── img/                                     ← everything from your old img/ folder
       ├── rack/   (already here, do not delete)
       ├── front.jpg   whitejersey.jpg   3ef3018f927a2b9d57788d7333f3f90f.jpg   aa_haupttribuene.jpg   …
       └── kits/   (the old kit pictures)
   ```

## 2. Run it

Open a terminal **inside the `bayern-vue` folder**:

```bash
npm install
npm run dev
```

Open http://localhost:5173. Leave WAMP running: the website talks to the back end through Apache.

> If your folder is not called `bayern-vue`, change `BACKEND_PATH` at the top of `vite.config.js`.

**Quick check of the back end:** open http://localhost/bayern-vue/backend/me.phtml – you must see `{"user":null,"cart":null}`. The first call creates the virtual database file `database/bayern.sqlite`.

## 3. Accounts

| Account | Login | Password |
|---|---|---|
| **Administrator** (manages products and orders) | `admin@bayern.com` | `Admin#2026` |
| **Customer: Rayen** (photo `img/3ef3018f927a2b9d57788d7333f3f90f.jpg`) | `rayenamari505@gmail.com` | `00000000` |
| Another customer | create one with **Sign up** (photo required) | – |

The account of Rayen is already in the database (`bayern.sql`, and the virtual database). It is a normal customer: it can use the store, the cart and the tickets, but not the administration.
It has a very simple password because it is a demo account: change it in **My profile** (or delete the account) before the website is shown to other people.

Change the administrator password in the **My profile** page.
To make another person administrator: phpMyAdmin → `bayern` → `users` → **Edit** the row → set `role` to `admin`.

---

## 4. The two databases

| | Virtual database (default) | WAMP / phpMyAdmin database |
|---|---|---|
| `driver` in `backend/includes/config.phtml` | `'sqlite'` | `'mysql'` |
| Needs | nothing – a file is created for you | import `database/bayern.sql` |
| Tables | same 9 tables | same 9 tables |

### Create the database in phpMyAdmin

1. Start WAMP (green icon) and open http://localhost/phpmyadmin (user `root`, empty password).
2. **Create the database** – either way works:
   - **Option A (1 step):** click the **Import** tab at the top *(no database selected)* → **Choose file** → `bayern-vue/database/bayern.sql` → **Import**. The file creates the database `bayern` for you.
   - **Option B (by hand):** click **New** (left panel) → Database name `bayern`, collation `utf8mb4_unicode_ci` → **Create**. Click `bayern` → **Import** tab → choose `bayern.sql` → **Import**.
3. Check: in the left panel open `bayern`. You must see 9 tables (`users`, `products`, `product_colors`, `orders`, `order_items`, `contest_entries`, `matches`, `stands`, `tickets`), `products` has 15 rows, `matches` has 6 rows, `stands` has 4 rows and `users` has 2 rows (the administrator and Rayen).
4. **Link the website to it:** open `backend/includes/config.phtml` and change **only this line**
   ```php
   'driver' => 'sqlite',
   ```
   to
   ```php
   'driver' => 'mysql',
   ```
   (user `root` and an empty password are the WAMP defaults. If you set a MySQL password, write it in the `'mysql'` block.)
5. Reload the website, sign up, then in phpMyAdmin open `bayern` → `users` → **Browse**: your account is there.

> **Warning:** importing `bayern.sql` again **resets the whole database** (users, orders and products go back to the start). Uploaded pictures stay in `backend/uploads/`.
>
> **You already have a database with data (users, orders, tickets) and only want the news?** Do not import `bayern.sql`. Import `database/migration_update.sql` instead (phpMyAdmin → click `bayern` → **Import**). It adds the colours (Red = Home Kit, White = Away Kit), the account of Rayen and keeps everything else. It can be imported again without problem.
> The virtual database is also rebuilt automatically if you update the project from an older version.

---

## 5. How it works

- **Sign up** → a new row in `users` and the photo is saved in `backend/uploads/avatars/`. The user is logged in at once; his **photo and name appear in the header** in place of the login icon.
- **Colours of the big "Match kit" card = Home Kit / Away Kit.** The card has a **Red / White** choice. **Red** is the **FC Bayern Home Kit**: the shirt picture (`img/front.jpg`) at the normal price. **White** moves the card to the **FC Bayern Away Kit**: the picture becomes `img/whitejersey.jpg`, the title and the description change, and the price drops by **30%** (the normal price is crossed out, with a "-30%" badge). The colours are in the table `product_colors` (code, label, colour dot, picture, **name**, **description**, discount in %). A colour with an empty name / description uses the ones of the product. **The server calculates the price of each colour** (`99.95 - 30% = 69.97`), checks the colour when you add to the cart, and calculates the price again when you place the order. The cart, the orders and the administrator's order list show the colour of each line, and the line is called **FC Bayern Away Kit** for the white shirt. To change the discount, edit `discount_percent` of the row in phpMyAdmin.
- **The store and the tickets need an account.** A visitor who opens **Store** sees "Join the club to enter the store", and one who opens **Tickets** (the list or a match page) sees "Log in to book your tickets" with the **Log in** and **Sign up** buttons. After logging in the page opens by itself. The server refuses too: `match_seats.phtml` answers `401` to a visitor. Only the list of matches on the **Home** page stays public.
- **Tickets** (logged in users). The **Tickets** page lists the matches (table `matches`) with the competition filters. Selecting a match opens its page, `/tickets/<id>`:
  - **Match information** at the top: teams, competition, date, venue.
  - **Stadium map** (photo of the arena): click one of the 4 stands (the shape on the map or its label).
  - **Seat panel**: photo of the pitch seen from that stand (click it to see it big), 8 rows x 10 seats, the price of the stand (table `stands`), your chosen seats and the total. On a computer the panel is next to the map, on a phone or tablet it covers the screen.
  - **Continue to Checkout**: a last question shows the seats and the total. The seats are saved in the table `tickets`; nobody can book the same seat twice (UNIQUE key) and the price always comes from the database. Maximum 8 seats per booking.
  - **My tickets** (account menu): your tickets by match, with a **Cancel** button that frees the seat.
  - About 3 seats out of 10 are shown as *already sold* (demo data, same rule on the server), the others can be booked. The West and East stands use the same pitch photo (it was like that in the original page).
- **Orders go straight to the database.** The cart is an order with status `cart` (tables `orders` + `order_items`). *Place order* changes it to `confirmed`; the customer can cancel it while it is `confirmed`; the administrator changes the status (`shipped`, `delivered`…).
- **Administrator** (menu → *Administration*): table of products with **Add / Edit / Delete** (with picture upload) and the list of all customer orders. Deleting a product removes it from the carts; old orders keep their lines.
- The **price always comes from the database**, never from the browser.

### Uploaded pictures

- JPG, PNG or WEBP, **2 MB maximum**, checked in the browser **and** on the server (the server opens the file to be sure it is a real picture).
- Saved with a random name in `backend/uploads/avatars/` and `backend/uploads/products/`. Scripts can never run from this folder (`.htaccess`).
- If an upload fails on your WAMP: `upload_max_filesize` in `php.ini` must be at least `2M` (the default).

### Security already done

Prepared statements (no SQL injection), hashed passwords (`password_hash`), session cookie `HttpOnly` + `SameSite`, forms with files only accepted from our own JavaScript, every user can only touch his own cart / orders / account, administrator pages checked **on the server** (`403` for a normal user), the last administrator cannot be deleted, and the same error for "wrong password" and "unknown email".

### If something does not work

| What you see | What to do |
|---|---|
| "The server did not answer with JSON…" | WAMP is not green, or the folder is not `www\bayern-vue` (or fix `BACKEND_PATH` in `vite.config.js`). |
| The browser shows **PHP code** when you open a `.phtml` file | Apache does not run `.phtml`. Check that `backend/.htaccess` is read (WAMP default is `AllowOverride All`) or add `AddType application/x-httpd-php .phtml` to `httpd.conf`, then restart WAMP. **Do not use the project until this is fixed** (your settings would be readable). |
| "Cannot open the virtual database…" | WAMP tray → PHP → PHP extensions → tick `pdo_sqlite`. |
| I change rows in phpMyAdmin but the website does not change (or the website saves data that phpMyAdmin does not show) | The website and phpMyAdmin use **two different databases**. Open `http://localhost/bayern-vue/backend/status.phtml`: it tells you which database the website uses and how many rows each table has. If it says *VIRTUAL database*, change `'driver'` to `'mysql'` in `backend/includes/config.phtml` (see section 4). If it says `mysql`, compare the numbers with phpMyAdmin (same database name `bayern`? same server?), then reload the page with `F5`. |
| "Cannot connect to MySQL…" | WAMP not green, database `bayern` not imported, or wrong user / password in `config.phtml`. |
| "Cannot save the image…" | The folder `backend/uploads` must be writable (it is, by default, on WAMP). |
| 403 when opening `includes/…` or `database/…` | Normal: those folders are protected on purpose. |

When the project is finished, set `'debug' => false` in `config.phtml`. PHP 7.3 or newer is needed (tested here with PHP 8.3).

---

## 6. Project structure

```
bayern-vue/
├── index.html              the only HTML page; Vue mounts in <div id="app">
├── vite.config.js          also forwards /api to WAMP (the back end)
├── backend/                PHP back end (.phtml)
│   ├── *.phtml             one file per action (see the CRUD map)
│   ├── includes/           config.phtml, database.phtml, helpers.phtml, shop.phtml, tickets.phtml, uploads.phtml
│   └── uploads/            pictures (avatars/, products/)
├── database/
│   ├── bayern.sql          MySQL database for phpMyAdmin
│   ├── migration_update.sql  adds colours (Home/Away Kit) + the account of Rayen to a database you already have (keeps your data)
│   ├── sqlite_schema.sql   tables of the virtual database (created automatically)
│   ├── seed.sql            administrator + Rayen + products of the virtual database
│   └── bayern.sqlite       the virtual database itself (appears after the first request)
├── public/                 images (img/stadium/ = stadium map + pitch photos, img/rack/ = kits)
└── src/
    ├── main.js  App.vue  router/index.js
    ├── views/              Home, Store, Tickets, TicketMatch (seat selection), MyTickets, Cart, Orders, Profile, Admin
    ├── components/
    │   ├── layout/         AppHeader, AccountMenu, PromoBar, AppFooter, NewsTicker, ToastMessage
    │   ├── shared/         FilterButtons, KitOptions, AuthModal, LoginPrompt, UserAvatar, ImagePicker, ConfirmModal
    │   ├── home/           HeroSection, MatchesSlider, MatchCard, TicketsPromo
    │   ├── tickets/        MatchHeader, StadiumMap, SeatPanel, SeatGrid, PitchViewModal
    │   ├── store/          SectionNav, KitRack, FeaturedKit, StoreSection, ProductCard, ProductModal, ContestForm, CartFab
    │   └── admin/          AdminProducts, ProductForm, AdminOrders
    ├── js/                 plain JavaScript: api.js, state.js, helpers.js, modal.js, rackMotion.js, data/ (stadium.js = shapes of the map)
    └── assets/css/         all the styles (main, layout, modals, home, store, rack, tickets, cart, admin, seats)
```

Production build: `npm run build` (files in `dist/`).

---

## 7. Where each concept of the Vue specification is used

| Concept | Examples |
|---|---|
| **Data binding** `{{ }}` | names, prices, totals, order numbers everywhere |
| **Attribute binding** `:attr` | `:src` of photos and product pictures, `:disabled="busy"`, `:aria-expanded`, `:value` of the status select |
| **Conditional rendering** | **`v-if="state.user"` → photo + name, `v-else` → login icon** (`AppHeader.vue`); the store wall (`StoreView.vue`); admin-only page (`AdminView.vue`); modals with `v-if` |
| **List rendering** `v-for` | products, admin table rows, cart lines, orders, sizes checkboxes, **rows and seats of a stand** (`SeatGrid.vue`, nested `v-for`), stand shapes on the map |
| **Event handling** | `@click`, `@submit.prevent`, `@change` (file, status), `@error` (missing image) |
| **Class binding** `:class` | order status badge colours, active tabs and filters, `is-invalid` / `was-validated` |
| **Style binding** `:style` | avatar size (`UserAvatar.vue`), slider and 3D rack transforms |
| **Computed properties** | `featuredKit`, `gridProducts`, `filteredProducts`, `total`, `passwordMismatch`, `charsLeft` |
| **Components & props** | `UserAvatar :user :size`, `ImagePicker v-model`, `ConfirmModal` with a **slot**, `ProductForm :product`, `ProductCard :product` |
| **Forms** | `v-model` (text, number, select, checkbox **array**, switch), file upload with `FormData`, Bootstrap validation, server errors shown in the form |
| **Lifecycle, watchers, async** | `created()` loads data, `async/await` + `fetch` in `js/api.js`, `watch: { 'state.user' }` in `StoreView.vue` and `OrdersView.vue` |
| **Router** | `RouterLink`, `$router.push`, pages `/store /tickets /my-tickets /cart /orders /profile /admin`, **dynamic route** `/tickets/:id` with `$route.params.id` |
| **Seat page** (`TicketMatchView.vue`) | `:class` for seat states (available / selected / occupied), computed `total` and `Set` lookups, props down + events up between `StadiumMap`, `SeatPanel` and `SeatGrid`, `watch` on the route and on the user (the checkout continues after the login), `matchMedia` for the phone layout |

Bootstrap: navbar with hamburger menu, grid, forms, modals, tables (`table-responsive`), tabs, badges, alerts, spinners, dropdown, utilities.
