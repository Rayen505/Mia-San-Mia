<template>
  <section class="big-section promo-section section-pad">
    <div class="promo">
      <img :src="asset(image)" :alt="imageAlt" />
      <div class="promo-text">
        <h2>{{ title }}</h2>
        <RouterLink :to="{ name: 'tickets' }" class="buy-btn">{{ buttonText }}</RouterLink>
      </div>
    </div>
  </section>
</template>

<script>
import { asset } from '@/js/helpers.js'

export default {
  name: 'TicketsPromo',
  props: {
    title: { type: String, required: true },
    image: { type: String, required: true },
    imageAlt: { type: String, default: '' },
    buttonText: { type: String, default: 'Buy Tickets' },
  },
  methods: { asset },
}
</script>
