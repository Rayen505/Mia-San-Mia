<template>
  <section class="shop-page section-pad">
    <h1 class="page-title">My tickets</h1>

    <div v-if="!state.ready || loading" class="text-center py-5">
      <span class="spinner-border" role="status"><span class="visually-hidden">Loading…</span></span>
    </div>

    <LoginPrompt v-else-if="!state.user" message="Log in to see the tickets you booked." />

    <div v-else-if="error" class="alert alert-danger d-flex flex-wrap align-items-center justify-content-between gap-2" role="alert">
      <span>{{ error }}</span>
      <button type="button" class="btn btn-sm btn-outline-danger" @click="load">Try again</button>
    </div>

    <div v-else-if="groups.length === 0" class="empty-box">
      <p>You have not booked any ticket yet.</p>
      <RouterLink :to="{ name: 'tickets' }" class="btn btn-fcb">Choose a match</RouterLink>
    </div>

    <div v-else class="order-list">
      <!-- one card per match -->
      <article v-for="group in groups" :key="group.match.id" class="order-card">
        <header>
          <div class="ticket-match">
            <img :src="asset(group.match.home.logo)" :alt="group.match.home.name" />
            <strong>{{ group.match.home.name }}</strong>
            <span class="ticket-vs">vs</span>
            <img :src="asset(group.match.away.logo)" :alt="group.match.away.name" />
            <strong>{{ group.match.away.name }}</strong>
          </div>
          <span class="order-date">{{ group.match.title }} · {{ group.match.date }} · {{ group.match.venue }}</span>
        </header>

        <ul class="order-items">
          <li v-for="ticket in group.tickets" :key="ticket.id">
            <span class="ticket-seat">
              <strong>{{ ticket.stand.name }}</strong>
              <small>· Row {{ ticket.row }} · Seat {{ ticket.seat }}</small>
            </span>
            <span class="d-flex align-items-center gap-3">
              {{ money(ticket.price) }}
              <button type="button" class="btn btn-sm btn-outline-danger" @click="toCancel = ticket">Cancel</button>
            </span>
          </li>
        </ul>

        <footer>
          <span>{{ group.tickets.length }} ticket(s)</span>
          <strong>Total: {{ money(group.total) }}</strong>
        </footer>
      </article>
    </div>

    <ConfirmModal
      v-if="toCancel"
      title="Cancel this ticket?"
      confirm-text="Yes, cancel it"
      danger
      :busy="cancelling"
      @confirm="cancel"
      @cancel="toCancel = null"
    >
      <p class="mb-0">
        {{ toCancel.stand.name }} · Row {{ toCancel.row }} · Seat {{ toCancel.seat }} ({{ money(toCancel.price) }}).
        The seat will be free again.
      </p>
    </ConfirmModal>
  </section>
</template>

<script>
import LoginPrompt from '@/components/shared/LoginPrompt.vue'
import ConfirmModal from '@/components/shared/ConfirmModal.vue'
import { api } from '@/js/api.js'
import { state, showToast } from '@/js/state.js'
import { asset, money } from '@/js/helpers.js'

// The tickets of the logged in user (READ) and the possibility to cancel one (DELETE)
export default {
  name: 'MyTicketsView',
  components: { LoginPrompt, ConfirmModal },
  data() {
    return {
      state,
      tickets: [],
      loading: false,
      error: '',
      toCancel: null, // ticket waiting for the "are you sure"
      cancelling: false,
    }
  },
  computed: {
    // tickets grouped by match: [{ match, tickets, total }]
    groups() {
      const byMatch = new Map()
      this.tickets.forEach((t) => {
        if (!byMatch.has(t.match.id)) byMatch.set(t.match.id, { match: t.match, tickets: [], total: 0 })
        const group = byMatch.get(t.match.id)
        group.tickets.push(t)
        group.total = Math.round((group.total + t.price) * 100) / 100
      })
      return [...byMatch.values()]
    },
  },
  watch: {
    // the user is known a moment after the page opens
    'state.user'(user) {
      if (user) this.load()
      else this.tickets = []
    },
  },
  mounted() {
    if (this.state.user) this.load()
  },
  methods: {
    asset,
    money,
    async load() {
      this.loading = true
      this.error = ''
      try {
        this.tickets = (await api.myTickets()).tickets
      } catch (error) {
        this.error = error.message
      } finally {
        this.loading = false
      }
    },
    async cancel() {
      this.cancelling = true
      try {
        await api.cancelTicket(this.toCancel.id)
        showToast('Ticket cancelled')
        this.toCancel = null
        await this.load()
      } catch (error) {
        showToast(error.message)
        this.toCancel = null
      } finally {
        this.cancelling = false
      }
    },
  },
}
</script>
