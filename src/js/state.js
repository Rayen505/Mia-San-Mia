import { reactive } from 'vue'
import { api } from './api.js'

const emptyCart = () => ({ id: null, items: [], count: 0, total: 0 })

// Shared state of the website. It is reactive: every component that reads it
// updates automatically. The user and the cart come from the database (PHP).
export const state = reactive({
  ready: false, // true once the server has told us if somebody is logged in
  user: null, // { id, name, email } or null
  cart: emptyCart(), // { items: [...], count, total }
  matches: [], // the matches, read from the database (home page, tickets page)
  matchesLoaded: false,
  matchesError: '',
  toast: { text: '', visible: false },
  authOpen: false,
  authTab: 'login',

  // number shown on the cart icons
  get cartCount() {
    return this.cart.count
  },
})

// ---------- matches ----------
// Loads the matches once. Every page that shows matches calls it (nothing happens if they are already here).
export async function loadMatches(force = false) {
  if (state.matchesLoaded && !force) return
  state.matchesError = ''
  try {
    state.matches = (await api.matches()).matches
    state.matchesLoaded = true
  } catch (error) {
    state.matchesError = error.message
  }
}

// ---------- toast message ----------
let toastTimer

export function showToast(text) {
  state.toast.text = text
  state.toast.visible = true
  clearTimeout(toastTimer)
  toastTimer = setTimeout(() => (state.toast.visible = false), 2200)
}

// ---------- login pop-up ----------
export function openAuth(tab = 'login') {
  state.authTab = tab
  state.authOpen = true
}

export function closeAuth() {
  state.authOpen = false
}

// ---------- session (who is logged in) ----------
function setSession(data) {
  state.user = data.user
  state.cart = data.cart || emptyCart()
}

// Called once when the website opens: is there already a session on the server?
export async function loadSession() {
  try {
    setSession(await api.me())
  } catch {
    // server not reachable: the visitor simply stays logged out
  } finally {
    state.ready = true
  }
}

// These two throw an error (ApiError) if the server refuses: the pop-up shows its message.
export async function login(email, password) {
  setSession(await api.login({ email, password }))
}

// formData: name, email, password and the photo (a file)
export async function signup(formData) {
  setSession(await api.signup(formData))
}

// the profile page changed the user (name, photo...)
export function setUser(user) {
  state.user = user
}

// log out on this side only (the account was deleted, or the session ended)
export function clearSession() {
  state.user = null
  state.cart = emptyCart()
}

export async function logout() {
  try {
    await api.logout()
  } finally {
    clearSession()
  }
}

// ---------- cart (saved in the database) ----------
// Runs a cart action. Returns its result, or null if it failed (a toast explains why).
async function run(action) {
  try {
    return await action()
  } catch (error) {
    if (error.status === 401) {
      // the session ended on the server
      clearSession()
      showToast('Please log in to continue')
      openAuth('login')
    } else {
      showToast(error.message)
    }
    return null
  }
}

export async function addToCart(product, { size, qty, name, number, color }) {
  if (!state.user) {
    showToast('Please log in to order')
    openAuth('login')
    return false
  }
  const data = await run(() =>
    api.addToCart({
      product_id: product.id,
      quantity: qty,
      size,
      color: color || '', // Red / White ... (the server calculates the price of the colour)
      print_name: name,
      print_number: number === '' ? null : number,
    })
  )
  if (!data) return false
  state.cart = data.cart
  return true
}

export async function changeQuantity(itemId, quantity) {
  const data = await run(() => api.updateCartItem(itemId, quantity))
  if (data) state.cart = data.cart
}

export async function removeItem(itemId) {
  const data = await run(() => api.removeCartItem(itemId))
  if (data) state.cart = data.cart
}

// "Place order": the cart becomes an order in the database. Returns the order or null.
export async function placeOrder() {
  const data = await run(() => api.checkout())
  if (!data) return null
  state.cart = data.cart
  return data.order
}
