<template>
  <!-- the tickets are only for logged in users -->
  <div v-if="!state.ready" class="text-center py-5">
    <span class="spinner-border" role="status"><span class="visually-hidden">Loading…</span></span>
  </div>

  <section v-else-if="!state.user" class="shop-page section-pad">
    <LoginPrompt
      title="Log in to book your tickets"
      message="Tickets are for members only. Log in or create your free account (with your photo) to choose a match and pick your seats."
    />
  </section>

  <section v-else class="shop-page section-pad">
    <h1 class="page-title">Tickets</h1>
    <p class="tickets-intro">Choose a match to pick your seats.</p>

    <FilterButtons v-model="filter" :options="competitions" color="red" label="Filter matches" />

    <!-- matches are loading / the server did not answer -->
    <div v-if="!state.matchesLoaded && !state.matchesError" class="text-center py-5">
      <span class="spinner-border" role="status"><span class="visually-hidden">Loading the matches…</span></span>
    </div>
    <div v-else-if="state.matchesError" class="alert alert-danger d-flex flex-wrap align-items-center justify-content-between gap-2" role="alert">
      <span>{{ state.matchesError }}</span>
      <button type="button" class="btn btn-sm btn-outline-danger" @click="loadMatches(true)">Try again</button>
    </div>

    <!-- Bootstrap columns: 1 card on phones, 2 on tablets, 3 on computers -->
    <div v-else class="row g-4">
      <div v-for="match in filteredMatches" :key="match.id" class="col-12 col-md-6 col-lg-4">
        <!-- selecting a match opens its own page: /tickets/<id> -->
        <RouterLink
          :to="{ name: 'ticket-match', params: { id: match.id } }"
          class="match-link"
          :aria-label="match.home.name + ' versus ' + match.away.name + ', ' + match.date + '. Choose seats'"
        >
          <MatchCard :match="match" cta="Choose seats" />
        </RouterLink>
      </div>
    </div>

    <p v-if="state.matchesLoaded && filteredMatches.length === 0" class="empty-note">No matches in this competition.</p>
  </section>
</template>

<script>
import FilterButtons from '@/components/shared/FilterButtons.vue'
import MatchCard from '@/components/home/MatchCard.vue'
import LoginPrompt from '@/components/shared/LoginPrompt.vue'
import { competitions } from '@/js/data/matches.js'
import { state, loadMatches } from '@/js/state.js'

export default {
  name: 'TicketsView',
  components: { FilterButtons, MatchCard, LoginPrompt },
  data() {
    return {
      state,
      competitions,
      filter: 'all',
    }
  },
  computed: {
    filteredMatches() {
      if (this.filter === 'all') return this.state.matches
      return this.state.matches.filter((m) => m.comp === this.filter)
    },
  },
  created() {
    loadMatches()
  },
  methods: { loadMatches },
}
</script>
