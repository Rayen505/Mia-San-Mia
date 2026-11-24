<template>
  <div class="modal fcb-modal" tabindex="-1" @click.self="$emit('close')">
    <div class="modal-dialog modal-dialog-centered product-dialog" @click.self="$emit('close')">
      <div ref="dialog" class="modal-content kit-card" role="dialog" aria-modal="true" aria-labelledby="mTitle">
        <button ref="closeBtn" class="modal-close" type="button" aria-label="Close" @click="$emit('close')">&times;</button>

        <div class="row g-0">
          <div class="col-lg-6 kit-image">
            <img v-if="!imageMissing" :src="mediaUrl(product.img)" :alt="product.name" @error="imageMissing = true" />
            <span v-else class="noimg-label">{{ product.name }}</span>
          </div>

          <div class="col-lg-6 kit-info">
            <h2 id="mTitle">{{ product.name }}</h2>
            <div class="kit-price">
              {{ money(product.price) }}
              <span v-if="product.oldPrice" class="old-price">{{ money(product.oldPrice) }}</span>
            </div>
            <p class="kit-desc">{{ product.desc }}</p>

            <KitOptions v-model="options" :sizes="product.sizes" :printable="product.print" id-prefix="modal" />

            <p class="kit-total">
              Total: <strong>{{ money(total) }}</strong>
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
      </div>
    </div>
  </div>
  <div class="modal-backdrop show"></div>
</template>

<script>
import KitOptions from '@/components/shared/KitOptions.vue'
import { addToCart, showToast } from '@/js/state.js'
import { trapFocus, lockPage, unlockPage } from '@/js/modal.js'
import { mediaUrl, money, clamp, newKitOptions } from '@/js/helpers.js'

export default {
  name: 'ProductModal',
  components: { KitOptions },
  props: {
    product: { type: Object, required: true },
  },
  emits: ['close'],
  data() {
    return {
      options: newKitOptions(this.product.sizes),
      imageMissing: false,
      busy: false, // true while the server saves the order line
    }
  },
  computed: {
    quantity() {
      return clamp(parseInt(this.options.qty, 10) || 1, 1, 10)
    },
    total() {
      return this.product.price * this.quantity
    },
  },
  mounted() {
    this.trigger = lockPage()
    window.addEventListener('keydown', this.onKey)
    this.$refs.closeBtn.focus()
  },
  beforeUnmount() {
    window.removeEventListener('keydown', this.onKey)
    unlockPage(this.trigger)
  },
  methods: {
    mediaUrl,
    money,
    onKey(event) {
      if (event.key === 'Escape') this.$emit('close')
      trapFocus(event, this.$refs.dialog)
    },
    async add(buyNow) {
      if (this.busy) return
      this.busy = true
      const added = await addToCart(this.product, { ...this.options, qty: this.quantity })
      this.busy = false
      if (!added) return
      if (buyNow) {
        this.$emit('close')
        this.$router.push({ name: 'cart' })
      } else {
        showToast(this.quantity + ' item(s) added to cart')
      }
    },
  },
}
</script>
