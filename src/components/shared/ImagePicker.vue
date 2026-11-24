<template>
  <div class="image-picker">
    <label class="form-label" :for="id">
      {{ label }}<span v-if="required" class="text-danger" aria-hidden="true"> *</span>
    </label>

    <div class="image-picker-row">
      <!-- preview: the file just chosen, or the picture already saved -->
      <img v-if="preview || currentUrl" class="image-picker-preview" :class="{ round }" :src="preview || currentUrl" alt="Preview" />
      <div v-else class="image-picker-preview image-picker-empty" :class="{ round }" aria-hidden="true">No image</div>

      <div class="image-picker-field">
        <input
          :id="id"
          ref="input"
          type="file"
          class="form-control"
          :class="{ 'is-invalid': shownError }"
          accept="image/jpeg,image/png,image/webp"
          @change="onChange"
        />
        <div v-if="shownError" class="invalid-feedback d-block">{{ shownError }}</div>
        <div v-else class="form-text">JPG, PNG or WEBP · 2 MB maximum</div>
      </div>
    </div>
  </div>
</template>

<script>
const MAX_BYTES = 2 * 1024 * 1024
const TYPES = ['image/jpeg', 'image/png', 'image/webp']

// Chooses an image file. Used with v-model: the value is the File (or null if nothing valid).
export default {
  name: 'ImagePicker',
  props: {
    modelValue: { default: null }, // File or null
    id: { type: String, required: true },
    label: { type: String, default: 'Picture' },
    required: { type: Boolean, default: false },
    round: { type: Boolean, default: false }, // round preview (profile photo)
    currentUrl: { type: String, default: '' }, // picture already saved (shown until a new one is chosen)
    error: { type: String, default: '' }, // message from the parent (missing, refused by the server ...)
  },
  emits: ['update:modelValue'],
  data() {
    return { preview: '', localError: '' }
  },
  computed: {
    shownError() {
      return this.localError || this.error
    },
  },
  watch: {
    // the parent cleared the value (form reset)
    modelValue(file) {
      if (!file) {
        this.revoke()
        if (this.$refs.input) this.$refs.input.value = ''
      }
    },
  },
  beforeUnmount() {
    this.revoke()
  },
  methods: {
    revoke() {
      if (this.preview) URL.revokeObjectURL(this.preview)
      this.preview = ''
    },
    onChange(event) {
      const file = event.target.files[0]
      this.localError = ''
      this.revoke()
      if (!file) {
        this.$emit('update:modelValue', null)
        return
      }
      // same rules as the server (the server checks again)
      if (!TYPES.includes(file.type)) this.localError = 'Please choose a JPG, PNG or WEBP image.'
      else if (file.size > MAX_BYTES) this.localError = 'The image is too big (2 MB maximum).'

      if (this.localError) {
        event.target.value = ''
        this.$emit('update:modelValue', null)
        return
      }
      this.preview = URL.createObjectURL(file)
      this.$emit('update:modelValue', file)
    },
  },
}
</script>
