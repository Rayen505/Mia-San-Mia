<template>
  <div class="login-prompt">
    <h2>{{ title }}</h2>
    <p>{{ message }}</p>
    <div class="d-flex flex-wrap justify-content-center gap-2">
      <button type="button" class="btn btn-fcb" @click="openAuth('login')">Log in</button>
      <button type="button" class="btn btn-fcb-outline" @click="openAuth('signup')">Sign up</button>
    </div>
  </div>
</template>

<script>
import { openAuth } from '@/js/state.js'

export default {
  name: 'LoginPrompt',
  props: {
    title: { type: String, default: 'Please log in' },
    message: { type: String, required: true },
  },
  methods: { openAuth },
}
</script>
