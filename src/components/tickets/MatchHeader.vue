<template>
  <header class="match-header">
    <RouterLink :to="{ name: 'tickets' }" class="match-back" aria-label="Back to all matches" title="Back to all matches">
      <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M15 19l-7-7 7-7" /></svg>
    </RouterLink>

    <div class="match-fixture">
      <div class="match-fixture-teams">
        <div class="match-team">
          <img :src="asset(match.home.logo)" :alt="match.home.name + ' logo'" />
          <span>{{ match.home.name }}</span>
        </div>
        <span class="match-vs">VS</span>
        <div class="match-team">
          <img :src="asset(match.away.logo)" :alt="match.away.name + ' logo'" />
          <span>{{ match.away.name }}</span>
        </div>
      </div>
      <div class="match-competition">{{ match.title }}</div>
    </div>

    <ul class="match-meta">
      <li>
        <svg viewBox="0 0 24 24" aria-hidden="true">
          <path d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
        </svg>
        <span>{{ match.date }}</span>
      </li>
      <li>
        <svg viewBox="0 0 24 24" aria-hidden="true">
          <path d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
          <path d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
        </svg>
        <span>{{ match.venue }}</span>
      </li>
    </ul>
  </header>
</template>

<script>
import { asset } from '@/js/helpers.js'

// Information about the match: teams, competition, date and place.
export default {
  name: 'MatchHeader',
  props: {
    match: { type: Object, required: true }, // { title, home: { name, logo }, away: { name, logo }, date, venue }
  },
  methods: { asset },
}
</script>
