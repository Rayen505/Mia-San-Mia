<template>
  <img
    v-if="user && user.photo && !failed"
    class="avatar"
    :src="mediaUrl(user.photo)"
    :alt="'Photo of ' + user.name"
    :style="sizeStyle"
    @error="failed = true"
  />
  <!-- no photo (or the file is missing): the first letter of the name -->
  <span v-else class="avatar avatar--letter" :style="sizeStyle" aria-hidden="true">{{ letter }}</span>
</template>

<script>
import { mediaUrl } from '@/js/helpers.js'

export default {
  name: 'UserAvatar',
  props: {
    user: { type: Object, default: null }, // { name, photo }
    size: { type: Number, default: 32 }, // pixels
  },
  data() {
    return { failed: false }
  },
  computed: {
    letter() {
      return this.user && this.user.name ? this.user.name.charAt(0).toUpperCase() : '?'
    },
    sizeStyle() {
      return { width: this.size + 'px', height: this.size + 'px', fontSize: this.size * 0.45 + 'px' }
    },
  },
  watch: {
    'user.photo'() {
      this.failed = false // a new photo: try to load it
    },
  },
  methods: { mediaUrl },
}
</script>
