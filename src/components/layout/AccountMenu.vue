<template>
  <div ref="root" class="account-menu">
    <!-- the name of the logged in user, in place of the login icon -->
    <button
      type="button"
      class="account-btn"
      aria-haspopup="true"
      :aria-expanded="open"
      :title="user.name"
      @click="open = !open"
    >
      <UserAvatar :user="user" :size="32" />
      <span class="account-name">{{ user.name }}</span>
      <svg class="account-caret" viewBox="0 0 24 24" aria-hidden="true">
        <path d="M6 9l6 6 6-6" />
      </svg>
    </button>

    <ul v-if="open" class="dropdown-menu show account-dropdown" @click="open = false">
      <li class="account-who">
        <strong>{{ user.name }}</strong>
        <span>{{ user.email }}</span>
        <span v-if="user.role === 'admin'" class="badge text-bg-danger align-self-start mt-1">Administrator</span>
      </li>
      <li>
        <RouterLink class="dropdown-item" :to="{ name: 'profile' }">My profile</RouterLink>
      </li>
      <li>
        <RouterLink class="dropdown-item" :to="{ name: 'cart' }">
          My cart
          <span class="badge rounded-pill text-bg-danger ms-1">{{ state.cartCount }}</span>
        </RouterLink>
      </li>
      <li>
        <RouterLink class="dropdown-item" :to="{ name: 'orders' }">My orders</RouterLink>
      </li>
      <li>
        <RouterLink class="dropdown-item" :to="{ name: 'my-tickets' }">My tickets</RouterLink>
      </li>
      <li v-if="user.role === 'admin'">
        <RouterLink class="dropdown-item" :to="{ name: 'admin' }">Administration</RouterLink>
      </li>
      <li><hr class="dropdown-divider" /></li>
      <li>
        <button type="button" class="dropdown-item" @click="logOut">Log out</button>
      </li>
    </ul>
  </div>
</template>

<script>
import UserAvatar from '@/components/shared/UserAvatar.vue'
import { state, logout, showToast } from '@/js/state.js'

export default {
  name: 'AccountMenu',
  components: { UserAvatar },
  props: {
    user: { type: Object, required: true }, // { id, name, email }
  },
  data() {
    return { state, open: false }
  },
  mounted() {
    document.addEventListener('click', this.onClickOutside)
    document.addEventListener('keydown', this.onKey)
  },
  beforeUnmount() {
    document.removeEventListener('click', this.onClickOutside)
    document.removeEventListener('keydown', this.onKey)
  },
  methods: {
    onClickOutside(event) {
      if (this.open && !this.$refs.root.contains(event.target)) this.open = false
    },
    onKey(event) {
      if (event.key === 'Escape') this.open = false
    },
    async logOut() {
      await logout()
      showToast('You are logged out')
      // pages that need an account go back to the home page
      if (['cart', 'orders', 'my-tickets', 'profile', 'admin', 'store'].includes(this.$route.name)) this.$router.push({ name: 'home' })
    },
  },
}
</script>
