<template>
  <div class="modal fcb-modal" tabindex="-1" @click.self="$emit('cancel')">
    <div class="modal-dialog modal-dialog-centered confirm-dialog" @click.self="$emit('cancel')">
      <div ref="dialog" class="modal-content confirm-card" role="alertdialog" aria-modal="true" aria-labelledby="confirmTitle">
        <h2 id="confirmTitle">{{ title }}</h2>

        <!-- the text of the question (and, if needed, a field) comes from the page that uses this pop-up -->
        <div class="confirm-body"><slot /></div>

        <div class="confirm-actions">
          <button ref="cancelBtn" type="button" class="btn btn-fcb-outline" @click="$emit('cancel')">Cancel</button>
          <button type="button" class="btn" :class="danger ? 'btn-danger' : 'btn-fcb'" :disabled="busy || disabled" @click="$emit('confirm')">
            <span v-if="busy" class="spinner-border spinner-border-sm" aria-hidden="true"></span>
            {{ confirmText }}
          </button>
        </div>
      </div>
    </div>
  </div>
  <div class="modal-backdrop show"></div>
</template>

<script>
import { trapFocus, lockPage, unlockPage } from '@/js/modal.js'

// "Are you sure?" pop-up. <ConfirmModal title="..." confirm-text="Delete" danger @confirm="..." @cancel="...">text</ConfirmModal>
export default {
  name: 'ConfirmModal',
  props: {
    title: { type: String, required: true },
    confirmText: { type: String, default: 'Confirm' },
    danger: { type: Boolean, default: false }, // red button
    busy: { type: Boolean, default: false }, // waiting for the server
    disabled: { type: Boolean, default: false }, // confirm not possible yet
  },
  emits: ['confirm', 'cancel'],
  mounted() {
    this.trigger = lockPage()
    window.addEventListener('keydown', this.onKey)
    this.$refs.cancelBtn.focus()
  },
  beforeUnmount() {
    window.removeEventListener('keydown', this.onKey)
    unlockPage(this.trigger)
  },
  methods: {
    onKey(event) {
      if (event.key === 'Escape') this.$emit('cancel')
      trapFocus(event, this.$refs.dialog)
    },
  },
}
</script>
