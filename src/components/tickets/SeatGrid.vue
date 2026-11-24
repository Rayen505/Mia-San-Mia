<template>
  <div class="seat-matrix" role="group" aria-label="Seats">
    <div v-for="row in rows" :key="row" class="seat-row">
      <span class="row-id-label">R{{ row }}</span>
      <div class="seats-in-row">
        <button
          v-for="seat in seatsPerRow"
          :key="seat"
          type="button"
          class="seat-chair"
          :class="{ occupied: isTaken(row, seat), selected: isSelected(row, seat) }"
          :disabled="isTaken(row, seat)"
          :aria-pressed="isSelected(row, seat)"
          :aria-label="label(row, seat)"
          :title="label(row, seat)"
          @click="$emit('toggle', { row, seat })"
        >
          {{ seat }}
        </button>
      </div>
    </div>
  </div>
</template>

<script>
// The seats of one stand: rows x seats. Taken seats cannot be clicked.
export default {
  name: 'SeatGrid',
  props: {
    rows: { type: Number, required: true },
    seatsPerRow: { type: Number, required: true },
    unavailable: { type: Array, default: () => [] }, // ["3-5", ...]  row-seat of the seats that are taken
    selected: { type: Array, default: () => [] }, // ["2-4", ...]   seats chosen by the user in this stand
    price: { type: Number, default: 0 },
  },
  emits: ['toggle'],
  computed: {
    // Sets make the lookups fast: the grid asks for 80 seats at every change
    takenSet() {
      return new Set(this.unavailable)
    },
    selectedSet() {
      return new Set(this.selected)
    },
  },
  methods: {
    isTaken(row, seat) {
      return this.takenSet.has(row + '-' + seat)
    },
    isSelected(row, seat) {
      return this.selectedSet.has(row + '-' + seat)
    },
    label(row, seat) {
      const state = this.isTaken(row, seat) ? 'taken' : this.isSelected(row, seat) ? 'selected' : '€' + this.price
      return 'Row ' + row + ', seat ' + seat + ' (' + state + ')'
    },
  },
}
</script>
