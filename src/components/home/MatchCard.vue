<template>
  <article class="match-card">
    <div class="match-comp">{{ match.title }}</div>

    <div class="match-teams">
      <div class="team">
        <img class="team-badge" :src="asset(match.home.logo)" :alt="match.home.name + ' logo'" />
        {{ match.home.name }}
      </div>
      <div class="vs">VS</div>
      <div class="team">
        <img class="team-badge" :src="asset(match.away.logo)" :alt="match.away.name + ' logo'" />
        {{ match.away.name }}
      </div>
    </div>

    <div class="match-date">{{ match.date }}</div>
    <div class="match-venue">{{ match.venue }}</div>

    <!-- optional button-like text at the bottom (used on the tickets page) -->
    <div v-if="cta" class="match-cta">{{ cta }}</div>
  </article>
</template>

<script>
import { asset } from '@/js/helpers.js'

export default {
  name: 'MatchCard',
  props: {
    match: { type: Object, required: true },
    cta: { type: String, default: '' },
  },
  methods: { asset },
}
</script>
