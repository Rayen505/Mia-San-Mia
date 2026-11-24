import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

// Bootstrap first, then our own styles so they can override it
import 'bootstrap/dist/css/bootstrap.min.css'
import './assets/css/main.css'
import './assets/css/layout.css'
import './assets/css/modals.css'
import './assets/css/home.css'
import './assets/css/store.css'
import './assets/css/rack.css'
import './assets/css/tickets.css'
import './assets/css/cart.css'
import './assets/css/admin.css'
import './assets/css/seats.css'

createApp(App).use(router).mount('#app')
