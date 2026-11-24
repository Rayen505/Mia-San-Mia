<template>
  <div class="promo-bar">
    <div class="container-fluid section-pad promo-inner">
      <img
        v-for="sponsor in sponsors"
        :key="sponsor.src"
        class="spon d-none d-sm-block"
        :src="asset(sponsor.src)"
        :alt="sponsor.name"
      />
      <p class="promo-text-line">
        Discounts up to {{ discount }}%.
        <RouterLink :to="{ name: 'store', hash: '#store' }" class="promo-link">Shop Now</RouterLink>
      </p>
    </div>
  </div>
</template>

<script>
import { homeSponsors } from '@/js/data/site.js'
import { asset } from '@/js/helpers.js'

export default {
  name: 'PromoBar',
  data() {
    return {
      sponsors: homeSponsors,
      discount: 70,
    }
  },
  methods: { asset },
}
</script>
