<template>
  <!-- the tickets are only for logged in users -->
  <section class="seat-page section-pad">
    <div v-if="!state.ready" class="text-center py-5">
      <span class="spinner-border" role="status"><span class="visually-hidden">Loading…</span></span>
    </div>

    <LoginPrompt
      v-else-if="!state.user"
      title="Log in to choose your seats"
      message="Tickets are for members only. Log in or create your free account (with your photo) to pick your seats."
    />

    <div v-else-if="loading" class="text-center py-5">
      <span class="spinner-border" role="status"><span class="visually-hidden">Loading the match…</span></span>
    </div>

    <div v-else-if="error" class="alert alert-danger d-flex flex-wrap align-items-center justify-content-between gap-2" role="alert">
      <span>{{ error }}</span>
      <button type="button" class="btn btn-sm btn-outline-danger" @click="load">Try again</button>
    </div>

    <template v-else-if="match">
      <!-- match information -->
      <MatchHeader :match="match" />

      <!-- after a booking -->
      <div v-if="booked" class="alert alert-success booked-banner" role="status">
        <span>
          <strong>Booking confirmed!</strong> {{ booked.count }} seat{{ booked.count > 1 ? 's' : '' }} · {{ money(booked.total) }}.
        </span>
        <RouterLink :to="{ name: 'my-tickets' }" class="btn btn-sm btn-success">See my tickets</RouterLink>
        <button type="button" class="btn-close" aria-label="Close this message" @click="booked = null"></button>
      </div>

      <div class="seat-workspace">
        <!-- the stadium: click a stand -->
        <div class="seat-map-col">
          <p class="map-hint"><span class="pulse-dot"></span>Click on any stand to choose your seats</p>
          <StadiumMap :stands="stands" :active="activeCode" @select="activeCode = $event" />
        </div>

        <!-- seats of the chosen stand -->
        <SeatPanel
          v-if="activeStand"
          :key="activeStand.code"
          :stand="activeStand"
          :unavailable="unavailable[activeStand.code] || []"
          :chosen="chosen"
          :total="total"
          :rows="rows"
          :seats-per-row="seatsPerRow"
          :max-seats="maxSeats"
          :overlay="narrow"
          :busy="booking"
          @close="activeCode = ''"
          @toggle="toggleSeat"
          @remove="removeSeat"
          @pitch="pitchOpen = true"
          @checkout="checkout"
        />
      </div>

      <!-- big photo of the pitch -->
      <PitchViewModal v-if="pitchOpen && activeStand" :stand="activeStand" @close="pitchOpen = false" />

      <!-- last question before saving the tickets in the database -->
      <ConfirmModal
        v-if="confirming"
        title="Confirm your booking"
        confirm-text="Confirm booking"
        :busy="booking"
        @confirm="book"
        @cancel="confirming = false"
      >
        <p class="mb-2">
          <strong>{{ match.home.name }} vs {{ match.away.name }}</strong><br />
          {{ match.date }} · {{ match.venue }}
        </p>
        <ul class="booking-list">
          <li v-for="item in chosen" :key="item.stand + '-' + item.row + '-' + item.seat">
            <span>{{ item.standName }} · Row {{ item.row }} · Seat {{ item.seat }}</span>
            <span>{{ money(item.price) }}</span>
          </li>
        </ul>
        <p class="booking-total mb-0">Total: <strong>{{ money(total) }}</strong></p>
      </ConfirmModal>
    </template>
  </section>
</template>

<script>
import MatchHeader from '@/components/tickets/MatchHeader.vue'
import StadiumMap from '@/components/tickets/StadiumMap.vue'
import SeatPanel from '@/components/tickets/SeatPanel.vue'
import PitchViewModal from '@/components/tickets/PitchViewModal.vue'
import ConfirmModal from '@/components/shared/ConfirmModal.vue'
import LoginPrompt from '@/components/shared/LoginPrompt.vue'
import { api } from '@/js/api.js'
import { state, showToast, clearSession } from '@/js/state.js'
import { lockPage, unlockPage } from '@/js/modal.js'
import { money } from '@/js/helpers.js'

// Page of one match: information + choice of the seats. Seats are saved in the database (table tickets).
export default {
  name: 'TicketMatchView',
  components: { MatchHeader, StadiumMap, SeatPanel, PitchViewModal, ConfirmModal, LoginPrompt },
  data() {
    return {
      state,
      match: null,
      stands: [], // the 4 stands with their price (from the database)
      unavailable: {}, // { sued: ["3-5", ...] } seats that cannot be chosen
      rows: 8,
      seatsPerRow: 10,
      maxSeats: 8,
      loading: true,
      error: '',
      activeCode: '', // chosen stand ('' = none)
      selected: [], // seats chosen by the user: [{ stand, row, seat }]
      pitchOpen: false,
      confirming: false, // the "confirm your booking" pop-up is open
      booking: false, // the server is saving the tickets
      booked: null, // result of the last booking
      narrow: false, // phone or tablet: the seat panel covers the screen
      pageLocked: false,
    }
  },
  computed: {
    standsByCode() {
      const map = {}
      this.stands.forEach((s) => (map[s.code] = s))
      return map
    },
    activeStand() {
      return this.standsByCode[this.activeCode] || null
    },
    // the chosen seats with the name and the price of their stand
    chosen() {
      return this.selected.map((s) => ({
        ...s,
        standName: this.standsByCode[s.stand].name,
        price: this.standsByCode[s.stand].price,
      }))
    },
    total() {
      const cents = this.chosen.reduce((sum, s) => sum + Math.round(s.price * 100), 0)
      return cents / 100
    },
    // the full screen panel blocks the page behind it
    locked() {
      return this.narrow && !!this.activeStand
    },
  },
  watch: {
    '$route.params.id'(id) {
      if (id && this.$route.name === 'ticket-match' && this.state.user) this.load() // another match, same page
    },
    locked(now) {
      if (now && !this.pageLocked) {
        this.pageLocked = true
        this.lockTrigger = lockPage()
      } else if (!now) {
        this.release()
      }
    },
    // the user is known a moment after the page opens, logs in on this page, or logs out
    'state.user'(user) {
      if (user) {
        this.load()
      } else {
        this.match = null
        this.selected = []
        this.activeCode = ''
        this.confirming = false
        this.pitchOpen = false
        this.booked = null
      }
    },
  },
  created() {
    if (this.state.user) this.load()
  },
  mounted() {
    this.query = window.matchMedia('(max-width: 991.98px)')
    this.narrow = this.query.matches
    this.query.addEventListener('change', this.onResize)
    window.addEventListener('keydown', this.onKey)
  },
  beforeUnmount() {
    this.query.removeEventListener('change', this.onResize)
    window.removeEventListener('keydown', this.onKey)
    this.release()
  },
  methods: {
    money,
    release() {
      if (this.pageLocked) {
        this.pageLocked = false
        unlockPage(this.lockTrigger)
      }
    },
    onResize(event) {
      this.narrow = event.matches
    },
    onKey(event) {
      // Escape closes the seat panel (the pop-ups close themselves first)
      if (event.key === 'Escape' && this.activeStand && !this.pitchOpen && !this.confirming) this.activeCode = ''
    },

    async load() {
      this.loading = true
      this.error = ''
      this.activeCode = ''
      this.selected = []
      this.booked = null
      try {
        const data = await api.matchSeats(this.$route.params.id)
        this.match = data.match
        this.stands = data.stands
        this.unavailable = data.unavailable
        this.rows = data.rows
        this.seatsPerRow = data.seats_per_row
        this.maxSeats = data.max_seats
        document.title = 'FC Bayern · Tickets · ' + data.match.home.name + ' vs ' + data.match.away.name
      } catch (error) {
        if (error.status === 404) this.$router.replace({ name: 'tickets' }) // this match does not exist
        else if (error.status === 401) clearSession() // the session ended: the log in message appears
        else this.error = error.message
      } finally {
        this.loading = false
      }
    },

    // seats taken since the page opened (by this user or by somebody else)
    async refreshSeats() {
      try {
        this.unavailable = (await api.matchSeats(this.match.id)).unavailable
      } catch {
        // not important: the page keeps the list it has
      }
    },

    // click on a seat of the stand that is open: choose it or remove it
    toggleSeat({ row, seat }) {
      const code = this.activeCode
      const index = this.selected.findIndex((s) => s.stand === code && s.row === row && s.seat === seat)
      if (index >= 0) {
        this.selected.splice(index, 1)
      } else if (this.selected.length >= this.maxSeats) {
        showToast('You can choose up to ' + this.maxSeats + ' seats')
      } else {
        this.selected.push({ stand: code, row, seat })
      }
    },
    removeSeat(item) {
      const index = this.selected.findIndex((s) => s.stand === item.stand && s.row === item.row && s.seat === item.seat)
      if (index >= 0) this.selected.splice(index, 1)
    },

    // "Continue to Checkout": the seats are saved in the account of the user (he is logged in to be on this page)
    checkout() {
      this.confirming = true
    },

    // saves the tickets in the database
    async book() {
      this.booking = true
      try {
        const seats = this.selected.map(({ stand, row, seat }) => ({ stand, row, seat }))
        this.booked = await api.bookTickets(this.match.id, seats)
        this.selected = []
        this.confirming = false
        this.activeCode = ''
        await this.refreshSeats()
        showToast('Seats booked!')
      } catch (error) {
        this.confirming = false
        if (error.status === 401) {
          clearSession() // the session ended on the server: the log in message appears
          showToast('Please log in again')
        } else {
          showToast(error.message)
          if (error.status === 409) {
            // somebody was faster: update the map and drop the seats that are gone
            await this.refreshSeats()
            this.selected = this.selected.filter((s) => !(this.unavailable[s.stand] || []).includes(s.row + '-' + s.seat))
          }
        }
      } finally {
        this.booking = false
      }
    },
  },
}
</script>
