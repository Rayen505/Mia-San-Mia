<template>
  <section class="matches section-pad">
    <div class="matches-head">
      <h3>Upcoming matches</h3>
      <div class="match-arrows">
        <button type="button" aria-label="Previous matches" :disabled="page === 0" @click="go(-1)">&#10094;</button>
        <button type="button" aria-label="Next matches" :disabled="page === pageCount - 1" @click="go(1)">&#10095;</button>
      </div>
    </div>

    <FilterButtons v-model="filter" :options="competitions" color="red" label="Filter matches" />

    <!-- autoplay stops while the mouse is over the cards -->
    <div class="match-window" @mouseenter="stop" @mouseleave="start">
      <div class="match-track row flex-nowrap gx-4" :class="{ 'no-anim': !animate }" :style="trackStyle">
        <!-- Bootstrap columns: 1 card on phones, 2 on tablets, 3 on computers -->
        <div v-for="match in filteredMatches" :key="match.id" class="col-12 col-md-6 col-lg-4">
          <MatchCard :match="match" />
        </div>
      </div>
      <p v-if="state.matchesLoaded && filteredMatches.length === 0" class="empty-note">No matches in this competition.</p>
    </div>
  </section>
</template>

<script>
import FilterButtons from '@/components/shared/FilterButtons.vue'
import MatchCard from './MatchCard.vue'
import { competitions } from '@/js/data/matches.js'
import { state, loadMatches } from '@/js/state.js'
import { clamp } from '@/js/helpers.js'

const DELAY = 4000 // ms between two automatic slides

export default {
  name: 'MatchesSlider',
  components: { FilterButtons, MatchCard },
  data() {
    return {
      state,
      competitions,
      filter: 'all',
      page: 0,
      direction: 1, // 1 = moving right, -1 = moving back left
      perView: 3,
      animate: true,
    }
  },
  computed: {
    matches() {
      return this.state.matches // read from the database
    },
    filteredMatches() {
      if (this.filter === 'all') return this.matches
      return this.matches.filter((m) => m.comp === this.filter)
    },
    pageCount() {
      return Math.max(1, Math.ceil(this.filteredMatches.length / this.perView))
    },
    trackStyle() {
      // one page = the full width of the row
      return { transform: `translateX(-${this.page * 100}%)` }
    },
  },
  watch: {
    filter() {
      // jump back to the first page without animating
      this.animate = false
      this.page = 0
      this.direction = 1
      requestAnimationFrame(() => requestAnimationFrame(() => (this.animate = true)))
      this.start()
    },
    pageCount(count) {
      if (this.page > count - 1) this.page = count - 1
    },
  },
  created() {
    loadMatches()
  },
  mounted() {
    this.updatePerView()
    window.addEventListener('resize', this.updatePerView)
    this.start()
  },
  beforeUnmount() {
    this.stop()
    window.removeEventListener('resize', this.updatePerView)
  },
  methods: {
    updatePerView() {
      const w = window.innerWidth // same breakpoints as col-md-6 / col-lg-4
      this.perView = w < 768 ? 1 : w < 992 ? 2 : 3
    },
    // automatic slide: right until the end, then back left
    step() {
      const next = this.page + this.direction
      if (next > this.pageCount - 1 || next < 0) this.direction *= -1
      this.page = clamp(this.page + this.direction, 0, this.pageCount - 1)
    },
    go(direction) {
      this.direction = direction
      this.page = clamp(this.page + direction, 0, this.pageCount - 1)
      this.start()
    },
    start() {
      this.stop()
      this.timer = setInterval(this.step, DELAY)
    },
    stop() {
      clearInterval(this.timer)
    },
  },
}
</script>
