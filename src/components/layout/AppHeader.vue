<template>
  <header>
    <!-- black sponsor bar: only on the home page -->
    <PromoBar v-if="$route.name === 'home'" />

    <nav class="navbar navbar-expand-md main-header" aria-label="Main">
      <div class="container-fluid section-pad">
        <RouterLink class="navbar-brand" :to="{ name: 'home' }">
          <img class="logo" :src="asset(logo)" alt="FC Bayern München" />
        </RouterLink>

        <!-- cart, account and the mobile menu button (always visible) -->
        <div class="header-icons order-md-last">
          <RouterLink :to="{ name: 'cart' }" class="icon-link" aria-label="Cart">
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <circle cx="9" cy="20" r="1.5" />
              <circle cx="18" cy="20" r="1.5" />
              <path d="M2 3h3l2.7 12.4a1 1 0 0 0 1 .8h9.1a1 1 0 0 0 1-.8L21 7H6" />
            </svg>
            <span class="cart-count">{{ state.cartCount }}</span>
          </RouterLink>

          <!-- logged in: his name.  logged out: the login icon -->
          <AccountMenu v-if="state.user" :user="state.user" />
          <button
            v-else
            type="button"
            class="icon-link"
            :class="{ invisible: !state.ready }"
            aria-label="Log in or sign up"
            @click="openAuth('login')"
          >
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <circle cx="12" cy="8" r="4" />
              <path d="M4 21c0-4.4 3.6-8 8-8s8 3.6 8 8" />
            </svg>
          </button>

          <button
            class="navbar-toggler"
            type="button"
            aria-controls="mainMenu"
            :aria-expanded="menuOpen"
            aria-label="Toggle navigation"
            @click="menuOpen = !menuOpen"
          >
            <span class="navbar-toggler-icon"></span>
          </button>
        </div>

        <div id="mainMenu" class="collapse navbar-collapse" :class="{ show: menuOpen }">
          <ul class="navbar-nav main-nav">
            <li v-for="link in links" :key="link.label" class="nav-item">
              <RouterLink :to="link.to" class="nav-link" exact-active-class="current">
                {{ link.label }}
              </RouterLink>
            </li>
          </ul>
        </div>
      </div>
    </nav>
  </header>
</template>

<script>
import PromoBar from './PromoBar.vue'
import AccountMenu from './AccountMenu.vue'
import { state, openAuth } from '@/js/state.js'
import { LOGO, mainLinks } from '@/js/data/site.js'
import { asset } from '@/js/helpers.js'

export default {
  name: 'AppHeader',
  components: { PromoBar, AccountMenu },
  data() {
    return {
      state,
      logo: LOGO,
      links: mainLinks,
      menuOpen: false,
    }
  },
  watch: {
    // close the mobile menu after choosing a page
    $route() {
      this.menuOpen = false
    },
  },
  methods: {
    asset,
    openAuth,
  },
}
</script>
