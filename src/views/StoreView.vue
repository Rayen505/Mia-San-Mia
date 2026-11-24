<template>
  <!-- the store is only for logged in users -->
  <div v-if="!state.ready" class="text-center py-5">
    <span class="spinner-border" role="status"><span class="visually-hidden">Loading…</span></span>
  </div>

  <section v-else-if="!state.user" class="shop-page section-pad">
    <LoginPrompt
      title="Join the club to enter the store"
      message="The store is for members only. Create your free account (with your photo) or log in to see the shirts."
    />
  </section>

  <template v-else>
    <SectionNav :sections="sections" :sponsors="sponsors" />
    <KitRack />
    <FeaturedKit :kit="featuredKit" :loading="loading" />
    <StoreSection :products="gridProducts" :loading="loading" :error="error" @retry="loadProducts" />
    <ContestForm />

    <CartFab />
    <NewsTicker :items="news" />
  </template>
</template>

<script>
import SectionNav from '@/components/store/SectionNav.vue'
import KitRack from '@/components/store/KitRack.vue'
import FeaturedKit from '@/components/store/FeaturedKit.vue'
import StoreSection from '@/components/store/StoreSection.vue'
import ContestForm from '@/components/store/ContestForm.vue'
import CartFab from '@/components/store/CartFab.vue'
import NewsTicker from '@/components/layout/NewsTicker.vue'
import LoginPrompt from '@/components/shared/LoginPrompt.vue'
import { api } from '@/js/api.js'
import { state, clearSession } from '@/js/state.js'
import { storeSponsors } from '@/js/data/site.js'
import { storeNews } from '@/js/data/news.js'

export default {
  name: 'StoreView',
  components: { SectionNav, KitRack, FeaturedKit, StoreSection, ContestForm, CartFab, NewsTicker, LoginPrompt },
  data() {
    return {
      state,
      products: [], // all the products, read from the database
      loading: true,
      error: '',
      sponsors: storeSponsors,
      news: storeNews,
      sections: [
        { id: 'overview', label: 'Overview' },
        { id: 'kit', label: 'Match kit' },
        { id: 'store', label: 'Store' },
        { id: 'competition', label: 'Free jersey' },
      ],
    }
  },
  computed: {
    // the big "Match kit" card is the product marked as featured in the database
    featuredKit() {
      return this.products.find((p) => p.featured) || null
    },
    gridProducts() {
      return this.products.filter((p) => !p.featured)
    },
  },
  watch: {
    // the user is known a moment after the page opens, or logs in on this page
    'state.user'(user) {
      if (user) this.loadProducts()
      else this.products = []
    },
  },
  created() {
    if (this.state.user) this.loadProducts()
  },
  methods: {
    async loadProducts() {
      this.loading = true
      this.error = ''
      try {
        this.products = (await api.products()).products
      } catch (error) {
        if (error.status === 401) clearSession() // the session ended: the login box appears
        else this.error = error.message
      } finally {
        this.loading = false
      }
    },
  },
}
</script>
