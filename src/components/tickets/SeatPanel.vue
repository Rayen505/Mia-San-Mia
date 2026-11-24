<template>
  <aside class="seat-panel" :class="{ 'seat-panel--overlay': overlay }" :aria-label="'Seats of ' + stand.name">
    <!-- name of the stand -->
    <div class="seat-panel-head">
      <div>
        <span class="seat-panel-badge">{{ stand.badge }}</span>
        <h2 class="seat-panel-title">{{ stand.name }}</h2>
      </div>
      <button ref="closeBtn" type="button" class="seat-panel-close" aria-label="Close the seat selection" @click="$emit('close')">✕</button>
    </div>

    <div class="seat-panel-body">
      <!-- view of the pitch from this stand: click to see it big -->
      <button type="button" class="pitch-view-card" @click="$emit('pitch')">
        <img :src="asset(stand.pitch)" :alt="'View of the pitch from the ' + stand.name" />
        <span class="pitch-view-overlay">
          <span class="pitch-view-title">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
              <path d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
            </svg>
            Pitch View From Seat
          </span>
          <span class="pitch-view-badge">Click to Expand ↗</span>
        </span>
      </button>

      <!-- the seats -->
      <div class="seat-grid-container">
        <div class="pitch-direction-banner">▲ PITCH / FIELD DIRECTION ▲</div>

        <SeatGrid
          :rows="rows"
          :seats-per-row="seatsPerRow"
          :unavailable="unavailable"
          :selected="selectedKeys"
          :price="stand.price"
          @toggle="$emit('toggle', $event)"
        />

        <div class="seat-legend-row">
          <span class="legend-item"><span class="legend-box avail"></span>Available ({{ money(stand.price) }})</span>
          <span class="legend-item"><span class="legend-box sel"></span>Selected</span>
          <span class="legend-item"><span class="legend-box occ"></span>Occupied</span>
        </div>
      </div>
    </div>

    <!-- chosen seats, total and the button -->
    <div class="seat-panel-foot">
      <div class="seat-chips">
        <p v-if="chosen.length === 0" class="seat-chips-empty">No seats selected yet. Click on the red seats above (up to {{ maxSeats }}).</p>
        <span v-for="item in chosen" :key="item.stand + '-' + item.row + '-' + item.seat" class="seat-chip">
          {{ item.standName }} • R{{ item.row }}-S{{ item.seat }} ({{ money(item.price) }})
          <button type="button" class="chip-remove" :aria-label="'Remove ' + item.standName + ' row ' + item.row + ' seat ' + item.seat" @click="$emit('remove', item)">✕</button>
        </span>
      </div>

      <div class="seat-total-row">
        <span class="seat-total-count">{{ chosen.length === 0 ? '0 Seats' : chosen.length + (chosen.length > 1 ? ' Seats Selected' : ' Seat Selected') }}</span>
        <strong class="seat-total-amount">{{ money(total) }}</strong>
      </div>

      <button type="button" class="seat-checkout-btn" :disabled="chosen.length === 0 || busy" @click="$emit('checkout')">
        <span v-if="busy" class="spinner-border spinner-border-sm" aria-hidden="true"></span>
        <span>Continue to Checkout</span>
        <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M14 5l7 7m0 0l-7 7m7-7H3" /></svg>
      </button>
    </div>
  </aside>
</template>

<script>
import SeatGrid from './SeatGrid.vue'
import { asset, money } from '@/js/helpers.js'

// The panel that opens when a stand is chosen: pitch view, seats, chosen seats and total.
export default {
  name: 'SeatPanel',
  components: { SeatGrid },
  props: {
    stand: { type: Object, required: true }, // { code, name, badge, price, pitch }
    unavailable: { type: Array, default: () => [] }, // taken seats of this stand
    chosen: { type: Array, default: () => [] }, // ALL the seats chosen by the user, in every stand (with name and price)
    total: { type: Number, default: 0 },
    rows: { type: Number, required: true },
    seatsPerRow: { type: Number, required: true },
    maxSeats: { type: Number, default: 8 },
    overlay: { type: Boolean, default: false }, // full screen on phones and tablets
    busy: { type: Boolean, default: false },
  },
  emits: ['close', 'toggle', 'remove', 'checkout', 'pitch'],
  computed: {
    // seats chosen in THIS stand, as "row-seat"
    selectedKeys() {
      return this.chosen.filter((s) => s.stand === this.stand.code).map((s) => s.row + '-' + s.seat)
    },
  },
  mounted() {
    if (this.overlay) this.$refs.closeBtn.focus()
  },
  methods: { asset, money },
}
</script>
