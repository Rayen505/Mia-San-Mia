<template>
  <section id="kit" class="kit-section section-pad">
    <div v-if="kit" class="kit-card row g-0">
      <div class="col-lg-6 kit-image">
        <!-- the picture changes with the colour -->
        <Transition name="kit-fade" mode="out-in">
          <img :key="current.img" :src="mediaUrl(current.img)" :alt="current.name + (current.label ? ' – ' + current.label : '')" />
        </Transition>
      </div>

      <div class="col-lg-6 kit-info">
        <!-- Red = Home Kit, White = Away Kit: the title and the text follow the colour -->
        <h2>{{ current.name }}</h2>
        <div class="kit-price">
          {{ money(current.price) }}
          <!-- discounted colour: the normal price is crossed out -->
          <span v-if="current.discount" class="old-price">{{ money(kit.price) }}</span>
          <span v-if="current.discount" class="discount-badge">-{{ current.discount }}%</span>
        </div>
        <p class="kit-desc">{{ current.desc }}</p>

        <!-- colour choice (only if the product has several colours) -->
        <div v-if="colors.length > 1" class="color-picker" role="group" aria-label="Colour">
          <span class="color-picker-label">Colour: <strong>{{ current.label }}</strong></span>
          <div class="color-options">
            <button
              v-for="color in colors"
              :key="color.code"
              type="button"
              class="color-option"
              :class="{ active: color.code === colorCode }"
              :aria-pressed="color.code === colorCode"
              @click="colorCode = color.code"
            >
              <span class="color-dot" :style="{ backgroundColor: color.swatch }"></span>
              {{ color.label }}
              <small v-if="color.discount" class="color-sale">-{{ color.discount }}%</small>
            </button>
          </div>
        </div>

        <KitOptions v-model="options" :sizes="kit.sizes" :printable="kit.print" id-prefix="kit" />

        <p class="kit-total">
          Total: <strong>{{ money(total) }}</strong>
          <span v-if="printLabel" class="kit-print">· Printed: {{ printLabel }}</span>
        </p>

        <div class="btn-row">
          <button class="btn btn-fcb" type="button" :disabled="busy" @click="add(false)">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <circle cx="9" cy="20" r="1.5" />
              <circle cx="18" cy="20" r="1.5" />
              <path d="M2 3h3l2.7 12.4a1 1 0 0 0 1 .8h9.1a1 1 0 0 0 1-.8L21 7H6" />
            </svg>
            Add to cart
          </button>
          <button class="btn btn-fcb-outline" type="button" :disabled="busy" @click="add(true)">Buy now</button>
        </div>
      </div>
    </div>

    <!-- the product is still coming from the database -->
    <div v-else-if="loading" class="text-center py-5">
      <span class="spinner-border" role="status"><span class="visually-hidden">Loading…</span></span>
    </div>
  </section>
</template>

<script>
import KitOptions from '@/components/shared/KitOptions.vue'
import { addToCart, showToast } from '@/js/state.js'
import { mediaUrl, money, clamp, newKitOptions } from '@/js/helpers.js'

// code of the first colour of a product ('' if it has no colour)
const firstColor = (kit) => (kit && kit.colors && kit.colors.length ? kit.colors[0].code : '')

export default {
  name: 'FeaturedKit',
  components: { KitOptions },
  props: {
    kit: { type: Object, default: null }, // null until the database has answered (with its colours)
    loading: { type: Boolean, default: false },
  },
  data() {
    return {
      options: newKitOptions(this.kit ? this.kit.sizes : []),
      colorCode: firstColor(this.kit), // chosen colour (Red at the start)
      busy: false, // true while the server saves the order line
    }
  },
  watch: {
    kit(kit) {
      this.options = newKitOptions(kit ? kit.sizes : [])
      this.colorCode = firstColor(kit)
    },
  },
  computed: {
    quantity() {
      return clamp(parseInt(this.options.qty, 10) || 1, 1, 10)
    },
    colors() {
      return this.kit ? this.kit.colors || [] : []
    },
    // the chosen colour: its picture, its price (given by the server) and its discount
    current() {
      const color = this.colors.find((c) => c.code === this.colorCode) || this.colors[0]
      if (color) return color
      const kit = this.kit || {}
      return { code: '', label: '', swatch: '', img: kit.img, name: kit.name, desc: kit.desc, price: kit.price || 0, discount: 0 }
    },
    total() {
      return (Math.round(this.current.price * 100) * this.quantity) / 100
    },
    printLabel() {
      return [this.options.name, this.options.number].filter((v) => v !== '').join(' ')
    },
  },
  methods: {
    mediaUrl,
    money,
    // saves the shirt in the cart (database). "Buy now" then opens the cart to place the order.
    async add(buyNow) {
      if (this.busy) return
      this.busy = true
      const added = await addToCart(this.kit, { ...this.options, qty: this.quantity, color: this.colorCode })
      this.busy = false
      if (!added) return
      if (buyNow) this.$router.push({ name: 'cart' })
      else showToast(this.quantity + ' item(s) added to cart')
    },
  },
}
</script>
