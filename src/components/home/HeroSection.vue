<template>
  <section class="big-section hero" :class="{ play: playing, settled: settled }">
    <img :src="asset(image)" alt="Bayern team photo" />

    <div class="hero-title">
      <!-- the words appear one after the other (animation-delay set with a style binding) -->
      <span
        v-for="(word, i) in words"
        :key="i"
        class="line"
        :style="{ animationDelay: 0.3 + i * 0.8 + 's' }"
      >{{ word }}</span>

      <p class="hero-quote">
        “{{ quote.text }}”
        <cite>{{ quote.author }}</cite>
      </p>
    </div>
  </section>
</template>

<script>
import { asset } from '@/js/helpers.js'

export default {
  name: 'HeroSection',
  data() {
    return {
      image: 'img/97a11b009241-munich-germany-players-of-fc-bayern-munich-line-up-for-a-team-photograph-before.webp',
      words: ['MIA', 'SAN', 'MIA'],
      quote: {
        text: "We're all a little bit addicted to that feeling of winning.",
        author: 'Thomas Müller',
      },
      playing: false, // words appear one by one in the centre
      settled: false, // then the title moves left, the shadow and the quote appear
    }
  },
  mounted() {
    this.playing = true
    this.timer = setTimeout(() => (this.settled = true), 3200)
  },
  beforeUnmount() {
    clearTimeout(this.timer)
  },
  methods: { asset },
}
</script>
