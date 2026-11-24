<template>
  <div>
    <div class="admin-toolbar">
      <h2>Customer orders <span class="admin-count">({{ orders.length }})</span></h2>
    </div>

    <div v-if="loading" class="text-center py-5">
      <span class="spinner-border" role="status"><span class="visually-hidden">Loading…</span></span>
    </div>
    <div v-else-if="error" class="alert alert-danger d-flex flex-wrap align-items-center justify-content-between gap-2" role="alert">
      <span>{{ error }}</span>
      <button type="button" class="btn btn-sm btn-outline-danger" @click="load">Try again</button>
    </div>
    <div v-else-if="orders.length === 0" class="empty-box">
      <p class="mb-0">No order yet.</p>
    </div>

    <div v-else class="order-list admin-orders">
      <article v-for="order in orders" :key="order.id" class="order-card">
        <header>
          <div class="d-flex align-items-center gap-2">
            <UserAvatar :user="order.customer" :size="40" />
            <div>
              <h3 class="order-customer">{{ order.customer.name }}</h3>
              <span class="order-date">{{ order.customer.email }} · Order #{{ order.id }} · {{ formatDate(order.ordered_at) }}</span>
            </div>
          </div>

          <!-- UPDATE the status: saved in the database as soon as it changes -->
          <div class="status-box">
            <label class="visually-hidden" :for="'status' + order.id">Status of order {{ order.id }}</label>
            <select :id="'status' + order.id" class="form-select form-select-sm" :class="statusClass[order.status]" :value="order.status" @change="changeStatus(order, $event.target.value)">
              <option v-for="status in statuses" :key="status" :value="status">{{ status }}</option>
            </select>
          </div>
        </header>

        <ul class="order-items">
          <li v-for="item in order.items" :key="item.id">
            <span>
              <strong>{{ item.quantity }} ×</strong> {{ item.name }}
              <small>· Size {{ item.size }}<template v-if="item.color"> · {{ item.color }}</template><template v-if="printLabel(item)"> · Printed: {{ printLabel(item) }}</template></small>
            </span>
            <span>{{ money(item.line_total) }}</span>
          </li>
        </ul>

        <footer>
          <span>{{ order.count }} shirt(s)</span>
          <strong>Total: {{ money(order.total) }}</strong>
        </footer>
      </article>
    </div>
  </div>
</template>

<script>
import UserAvatar from '@/components/shared/UserAvatar.vue'
import { api } from '@/js/api.js'
import { showToast } from '@/js/state.js'
import { money, formatDate, printLabel } from '@/js/helpers.js'

export default {
  name: 'AdminOrders',
  components: { UserAvatar },
  data() {
    return {
      orders: [],
      loading: true,
      error: '',
      statuses: ['confirmed', 'shipped', 'delivered', 'cancelled'],
      statusClass: {
        confirmed: 'status-confirmed',
        shipped: 'status-shipped',
        delivered: 'status-delivered',
        cancelled: 'status-cancelled',
      },
    }
  },
  created() {
    this.load()
  },
  methods: {
    money,
    formatDate,
    printLabel,
    async load() {
      this.loading = true
      this.error = ''
      try {
        this.orders = (await api.adminOrders()).orders
      } catch (error) {
        this.error = error.message
      } finally {
        this.loading = false
      }
    },
    async changeStatus(order, status) {
      try {
        await api.setOrderStatus(order.id, status)
        order.status = status
        showToast('Order #' + order.id + ' is now ' + status)
      } catch (error) {
        showToast(error.message)
        await this.load() // put the list back as it is in the database
      }
    },
  },
}
</script>
