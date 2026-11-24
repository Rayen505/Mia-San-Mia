import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '@/views/HomeView.vue'
import StoreView from '@/views/StoreView.vue'
import TicketsView from '@/views/TicketsView.vue'
import TicketMatchView from '@/views/TicketMatchView.vue'
import MyTicketsView from '@/views/MyTicketsView.vue'
import { state } from '@/js/state.js'
import CartView from '@/views/CartView.vue'
import OrdersView from '@/views/OrdersView.vue'
import ProfileView from '@/views/ProfileView.vue'
import AdminView from '@/views/AdminView.vue'

const routes = [
  { path: '/', name: 'home', component: HomeView, meta: { title: 'Home' } },
  { path: '/store', name: 'store', component: StoreView, meta: { title: 'Store' } },
  { path: '/tickets', name: 'tickets', component: TicketsView, meta: { title: 'Tickets' } },
  { path: '/tickets/:id(\\d+)', name: 'ticket-match', component: TicketMatchView, meta: { title: 'Tickets' } },
  { path: '/tickets/:pathMatch(.*)*', redirect: '/tickets' },
  { path: '/my-tickets', name: 'my-tickets', component: MyTicketsView, meta: { title: 'My tickets' } },
  { path: '/cart', name: 'cart', component: CartView, meta: { title: 'My cart' } },
  { path: '/orders', name: 'orders', component: OrdersView, meta: { title: 'My orders' } },
  { path: '/profile', name: 'profile', component: ProfileView, meta: { title: 'My profile' } },
  { path: '/admin', name: 'admin', component: AdminView, meta: { title: 'Administration' } },

  // old links from the HTML version still work
  { path: '/index.html', redirect: '/' },
  { path: '/Store.html', redirect: '/store' },
  { path: '/tickets.html', redirect: '/tickets' },
  { path: '/:pathMatch(.*)*', redirect: '/' },
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) return savedPosition
    // e.g. /store#kit -> scroll to the kit section, below the sticky section nav
    if (to.hash) return { el: to.hash, top: 70, behavior: 'smooth' }
    return { top: 0 }
  },
})

router.afterEach((to) => {
  let title = to.meta.title
  if (to.name === 'ticket-match') {
    // "Tickets · Bayern vs Dortmund"
    const match = state.matches.find((m) => m.id === Number(to.params.id))
    if (match) title += ' · ' + match.home.name + ' vs ' + match.away.name
  }
  document.title = 'FC Bayern · ' + title
})

export default router
