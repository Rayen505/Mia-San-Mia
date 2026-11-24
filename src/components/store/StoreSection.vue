<template>
  <section id="store" class="store section-pad" :style="{ backgroundImage: `url('${asset(background)}')` }">
    <div class="store-head">
      <h2>Store</h2>
      <p class="store-count">{{ countLabel }}</p>
    </div>

    <!-- products are loading / the server did not answer -->
    <div v-if="loading" class="text-center py-5">
      <span class="spinner-border" role="status"><span class="visually-hidden">Loading the products…</span></span>
    </div>
    <div v-else-if="error" class="alert alert-danger d-flex flex-wrap align-items-center justify-content-between gap-2" role="alert">
      <span>{{ error }}</span>
      <button type="button" class="btn btn-sm btn-outline-danger" @click="$emit('retry')">Try again</button>
    </div>

    <template v-else>
    <FilterButtons v-model="filter" :options="categories" color="blue" label="Filter by colour" />

    <!-- Bootstrap grid: 1 / 2 / 3 / 4 products per row depending on the screen -->
    <div class="row g-4 row-cols-1 row-cols-sm-2 row-cols-lg-3 row-cols-xl-4">
      <div v-for="product in filteredProducts" :key="product.id" class="col">
        <ProductCard :product="product" @select="selected = $event" />
      </div>
    </div>
    </template>

    <ProductModal v-if="selected" :key="selected.id" :product="selected" @close="selected = null" />
  </section>
</template>

<script>
import FilterButtons from '@/components/shared/FilterButtons.vue'
import ProductCard from './ProductCard.vue'
import ProductModal from './ProductModal.vue'
import { categories } from '@/js/data/products.js'
import { asset } from '@/js/helpers.js'

export default {
  name: 'StoreSection',
  components: { FilterButtons, ProductCard, ProductModal },
  props: {
    products: { type: Array, default: () => [] }, // from the database
    loading: { type: Boolean, default: false },
    error: { type: String, default: '' },
  },
  emits: ['retry'],
  data() {
    return {
      categories,
      filter: 'all',
      selected: null, // product shown in the pop-up
      background: 'img/allianz-arena-best-seats-scaled.jpg',
    }
  },
  computed: {
    filteredProducts() {
      if (this.filter === 'all') return this.products
      return this.products.filter((p) => p.cat === this.filter)
    },
    countLabel() {
      const n = this.filteredProducts.length
      return n + (n === 1 ? ' product' : ' products')
    },
  },
  methods: { asset },
}
</script>
