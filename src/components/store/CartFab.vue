<template>
  <button class="cart-fab" type="button" aria-label="Cart" @click="$router.push({ name: 'cart' })">
    <svg viewBox="0 0 24 24" aria-hidden="true">
      <circle cx="9" cy="20" r="1.5" />
      <circle cx="18" cy="20" r="1.5" />
      <path d="M2 3h3l2.7 12.4a1 1 0 0 0 1 .8h9.1a1 1 0 0 0 1-.8L21 7H6" />
    </svg>
    <span class="cart-count">{{ state.cartCount }}</span>
  </button>
</template>

<script>
import { state } from '@/js/state.js'

export default {
  name: 'CartFab',
  data() {
    return { state }
  },
}
</script>
