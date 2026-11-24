// Talks to the PHP back end (the .phtml files in the "backend" folder).
// Every request goes to /api/<name>.phtml. While you work with "npm run dev",
// Vite forwards /api to your WAMP server (see vite.config.js).

const BASE = import.meta.env.VITE_API_BASE || '/api'

// An error with the message of the server (shown to the user) and the wrong fields
export class ApiError extends Error {
  constructor(message, status = 0, fields = {}) {
    super(message)
    this.status = status // HTTP code: 401 = not logged in, 422 = wrong data, ...
    this.fields = fields // { email: 'This email is already registered.' }
  }
}

// URL of a file saved by the back end (profile photo, product picture): "uploads/avatars/x.jpg"
export const fileUrl = (path) => `${BASE}/${encodeURI(path)}`

// body === undefined -> GET request
// body is a FormData -> POST request that sends a form with files (multipart)
// otherwise          -> POST request with the body as JSON
async function request(name, body) {
  const options = { credentials: 'same-origin', headers: {} }
  if (body instanceof FormData) {
    options.method = 'POST'
    options.headers['X-Requested-With'] = 'bayern' // the back end only accepts forms sent by our own JavaScript
    options.body = body
  } else if (body !== undefined) {
    options.method = 'POST'
    options.headers['Content-Type'] = 'application/json'
    options.body = JSON.stringify(body)
  }

  // "match_seats?match_id=3" -> /api/match_seats.phtml?match_id=3  (the extension goes before the "?")
  const [file, query] = name.split('?')
  const url = `${BASE}/${file}.phtml${query ? '?' + query : ''}`

  let response
  try {
    response = await fetch(url, options)
  } catch {
    throw new ApiError('Cannot reach the server. Is WAMP running?')
  }

  let data
  try {
    data = await response.json()
  } catch {
    throw new ApiError(
      'The server did not answer with JSON. Check that WAMP is running and that the project folder is inside www.',
      response.status
    )
  }

  if (!response.ok) throw new ApiError(data.error || 'Something went wrong.', response.status, data.fields || {})
  return data
}

export const api = {
  me: () => request('me'),

  // matches, stands and ticket seats
  matches: () => request('matches'),
  matchSeats: (matchId) => request('match_seats?match_id=' + encodeURIComponent(matchId)),
  bookTickets: (matchId, seats) => request('ticket_book', { match_id: matchId, seats }), // seats: [{ stand, row, seat }]
  myTickets: () => request('tickets'),
  cancelTicket: (ticketId) => request('ticket_cancel', { ticket_id: ticketId }),

  products: () => request('products'),
  signup: (formData) => request('signup', formData), // name, email, password, photo
  login: (data) => request('login', data),
  logout: () => request('logout', {}),
  cart: () => request('cart'),
  addToCart: (data) => request('cart_add', data),
  updateCartItem: (itemId, quantity) => request('cart_update', { item_id: itemId, quantity }),
  removeCartItem: (itemId) => request('cart_remove', { item_id: itemId }),
  checkout: () => request('checkout', {}),
  orders: () => request('orders'),
  contest: (data) => request('contest', data),

  // profile of the logged in user
  updateProfile: (formData) => request('profile_update', formData), // name, email, photo (optional)
  changePassword: (current, next) => request('password_update', { current_password: current, new_password: next }),
  deleteAccount: (password) => request('account_delete', { password }),
  cancelOrder: (orderId) => request('order_cancel', { order_id: orderId }),

  // administrator: products (CRUD) and orders
  createProduct: (formData) => request('product_create', formData),
  updateProduct: (formData) => request('product_update', formData),
  deleteProduct: (id) => request('product_delete', { id }),
  adminOrders: () => request('admin_orders'),
  setOrderStatus: (orderId, status) => request('admin_order_status', { order_id: orderId, status }),
}
