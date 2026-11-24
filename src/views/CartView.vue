<template>
  <section class="shop-page section-pad">
    <h1 class="page-title">My cart</h1>

    <div v-if="!state.ready" class="text-center py-5">
      <span class="spinner-border" role="status"><span class="visually-hidden">Loading…</span></span>
    </div>

    <LoginPrompt v-else-if="!state.user" message="Log in to see your cart and place your orders." />

    <!-- the order was placed -->
    <div v-else-if="placed" class="order-done" role="status">
      <h2>Thank you, {{ firstName }}!</h2>
      <p>
        Your order <strong>#{{ placed.id }}</strong> is confirmed. Total: <strong>{{ money(placed.total) }}</strong>
      </p>
      <p class="mb-0 d-flex flex-wrap gap-2 justify-content-center">
        <RouterLink :to="{ name: 'orders' }" class="btn btn-fcb">See my orders</RouterLink>
        <RouterLink :to="{ name: 'store', hash: '#store' }" class="btn btn-fcb-outline">Continue shopping</RouterLink>
      </p>
    </div>

    <div v-else-if="items.length === 0" class="empty-box">
      <p>Your cart is empty.</p>
      <RouterLink :to="{ name: 'store', hash: '#store' }" class="btn btn-fcb">Go to the store</RouterLink>
    </div>

    <div v-else class="row g-4">
      <div class="col-lg-8">
        <ul class="cart-list">
          <li v-for="item in items" :key="item.id" class="cart-line">
            <img v-if="item.img && !broken[item.id]" class="cart-thumb" :src="mediaUrl(item.img)" :alt="item.name" @error="broken[item.id] = true" />
            <div v-else class="cart-thumb cart-thumb--empty">No image</div>

            <div class="cart-info">
              <h2>{{ item.name }}</h2>
              <p>
                Size {{ item.size }}<template v-if="item.color"> · {{ item.color }}</template>
                <span v-if="printLabel(item)" class="cart-print">· Printed: {{ printLabel(item) }}</span>
              </p>
              <p class="cart-unit">{{ money(item.unit_price) }} each</p>
            </div>

            <div class="qty-stepper" role="group" :aria-label="'Quantity of ' + item.name">
              <button type="button" aria-label="Fewer" :disabled="busy || item.quantity <= 1" @click="setQuantity(item, item.quantity - 1)">−</button>
              <span aria-live="polite">{{ item.quantity }}</span>
              <button type="button" aria-label="More" :disabled="busy || item.quantity >= maxQuantity" @click="setQuantity(item, item.quantity + 1)">+</button>
            </div>

            <div class="cart-line-total">{{ money(item.line_total) }}</div>

            <button type="button" class="cart-remove" aria-label="Remove from cart" :disabled="busy" @click="remove(item)">&times;</button>
          </li>
        </ul>
      </div>

      <div class="col-lg-4">
        <aside class="cart-summary">
          <h2>Order summary</h2>
          <dl>
            <dt>Shirts</dt>
            <dd>{{ state.cart.count }}</dd>
            <dt class="total">Total</dt>
            <dd class="total">{{ money(state.cart.total) }}</dd>
          </dl>
          <button type="button" class="btn btn-fcb w-100" :disabled="busy" @click="place">
            <span v-if="busy" class="spinner-border spinner-border-sm" aria-hidden="true"></span>
            Place order
          </button>
          <RouterLink :to="{ name: 'store', hash: '#store' }" class="btn btn-fcb-outline w-100 mt-2">Continue shopping</RouterLink>
          <p class="cart-note">Your cart is saved in your account.</p>
        </aside>
      </div>
    </div>
  </section>
</template>

<script>
import LoginPrompt from '@/components/shared/LoginPrompt.vue'
import { state, changeQuantity, removeItem, placeOrder, showToast } from '@/js/state.js'
import { mediaUrl, money, printLabel } from '@/js/helpers.js'

export default {
  name: 'CartView',
  components: { LoginPrompt },
  data() {
    return {
      state,
      maxQuantity: 10,
      busy: false, // true while the server is answering
      placed: null, // the order, after "Place order"
      broken: {}, // items whose image file is missing
    }
  },
  computed: {
    items() {
      return this.state.cart.items
    },
    firstName() {
      return this.state.user ? this.state.user.name.split(' ')[0] : ''
    },
  },
  methods: {
    mediaUrl,
    money,
    printLabel,
    async setQuantity(item, quantity) {
      this.busy = true
      await changeQuantity(item.id, quantity)
      this.busy = false
    },
    async remove(item) {
      this.busy = true
      await removeItem(item.id)
      this.busy = false
      showToast(item.name + ' removed')
    },
    // the cart becomes an order in the database
    async place() {
      this.busy = true
      this.placed = await placeOrder()
      this.busy = false
    },
  },
}
</script>
