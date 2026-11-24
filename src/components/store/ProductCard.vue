<template>
  <button
    type="button"
    class="product-card"
    :aria-label="product.name + ', ' + money(product.price) + '. View details'"
    @click="$emit('select', product)"
  >
    <span class="p-img">
      <span v-if="product.badge" class="badge-tag">{{ product.badge }}</span>
      <img v-if="!imageMissing" :src="mediaUrl(product.img)" alt="" loading="lazy" @error="imageMissing = true" />
      <span v-else class="noimg-label">{{ product.name }}</span>
    </span>

    <span class="p-body">
      <span class="p-cat">{{ categoryLabel }}</span>
      <span class="p-name">{{ product.name }}</span>
      <span class="p-info">{{ product.info }}</span>
      <span class="p-price-row">
        <span class="p-price">{{ money(product.price) }}</span>
        <span v-if="product.oldPrice" class="p-old">{{ money(product.oldPrice) }}</span>
      </span>
      <span class="p-view">View details</span>
    </span>
  </button>
</template>

<script>
import { categories } from '@/js/data/products.js'
import { mediaUrl, money } from '@/js/helpers.js'

export default {
  name: 'ProductCard',
  props: {
    product: { type: Object, required: true },
  },
  emits: ['select'],
  data() {
    return { imageMissing: false }
  },
  computed: {
    categoryLabel() {
      return categories.find((c) => c.value === this.product.cat)?.label
    },
  },
  methods: { mediaUrl, money },
}
</script>
