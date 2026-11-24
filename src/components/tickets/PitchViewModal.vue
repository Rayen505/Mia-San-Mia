<template>
  <div class="modal fcb-modal" tabindex="-1" @click.self="$emit('close')">
    <div class="modal-dialog modal-dialog-centered pitch-dialog" @click.self="$emit('close')">
      <div ref="dialog" class="modal-content pitch-card" role="dialog" aria-modal="true" aria-labelledby="pitchTitle">
        <div class="pitch-photo-box">
          <img :src="asset(stand.pitch)" :alt="'View of the pitch from the ' + stand.name" />
        </div>
        <div class="pitch-info">
          <div>
            <h2 id="pitchTitle">Pitch View: {{ stand.name }} • {{ stand.block }}</h2>
            <p>Unobstructed pitch-level view overlooking the field from this stand</p>
          </div>
          <button ref="closeBtn" type="button" class="pitch-close" @click="$emit('close')">Close View ✕</button>
        </div>
      </div>
    </div>
  </div>
  <div class="modal-backdrop show"></div>
</template>

<script>
import { trapFocus, lockPage, unlockPage } from '@/js/modal.js'
import { asset } from '@/js/helpers.js'

// The big photo of the pitch seen from a stand.
export default {
  name: 'PitchViewModal',
  props: {
    stand: { type: Object, required: true }, // { name, block, pitch }
  },
  emits: ['close'],
  mounted() {
    this.trigger = lockPage()
    window.addEventListener('keydown', this.onKey)
    this.$refs.closeBtn.focus()
  },
  beforeUnmount() {
    window.removeEventListener('keydown', this.onKey)
    unlockPage(this.trigger)
  },
  methods: {
    asset,
    onKey(event) {
      if (event.key === 'Escape') {
        event.stopPropagation()
        this.$emit('close')
      }
      trapFocus(event, this.$refs.dialog)
    },
  },
}
</script>
