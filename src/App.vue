<template>
  <AppHeader />

  <main>
    <!-- the page of the current route (Home, Store or Tickets) -->
    <RouterView />
  </main>

  <AppFooter />

  <!-- log in / sign up pop-up, available from the header on every page -->
  <AuthModal v-if="state.authOpen" />
  <ToastMessage />
</template>

<script>
import AppHeader from './components/layout/AppHeader.vue'
import AppFooter from './components/layout/AppFooter.vue'
import ToastMessage from './components/layout/ToastMessage.vue'
import AuthModal from './components/shared/AuthModal.vue'
import { state, loadSession } from './js/state.js'

export default {
  name: 'App',
  components: { AppHeader, AppFooter, ToastMessage, AuthModal },
  data() {
    return { state }
  },
  created() {
    // ask the server (database) if somebody is already logged in
    loadSession()
  },
}
</script>
