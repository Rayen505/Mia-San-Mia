<template>
  <section class="shop-page section-pad">
    <h1 class="page-title">My orders</h1>

    <div v-if="!state.ready || loading" class="text-center py-5">
      <span class="spinner-border" role="status"><span class="visually-hidden">Loading…</span></span>
    </div>

    <LoginPrompt v-else-if="!state.user" message="Log in to see your orders." />

    <div v-else-if="error" class="alert alert-danger d-flex flex-wrap align-items-center justify-content-between gap-2" role="alert">
      <span>{{ error }}</span>
      <button type="button" class="btn btn-sm btn-outline-danger" @click="load">Try again</button>
    </div>

    <div v-else-if="orders.length === 0" class="empty-box">
      <p>You have not placed any order yet.</p>
      <RouterLink :to="{ name: 'store', hash: '#store' }" class="btn btn-fcb">Go to the store</RouterLink>
    </div>

    <div v-else class="order-list">
      <article v-for="order in orders" :key="order.id" class="order-card">
        <header>
          <div>
            <h2>Order #{{ order.id }}</h2>
            <span class="order-date">{{ formatDate(order.ordered_at) }}</span>
          </div>
          <!-- the colour of the badge depends on the status saved in the database -->
          <span class="badge rounded-pill text-capitalize" :class="statusClass[order.status]">{{ order.status }}</span>
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
          <span class="d-flex align-items-center gap-3">
            <!-- a confirmed order can still be cancelled -->
            <button v-if="order.status === 'confirmed'" type="button" class="btn btn-sm btn-outline-danger" @click="toCancel = order">Cancel order</button>
            <strong>Total: {{ money(order.total) }}</strong>
          </span>
        </footer>
      </article>
    </div>

    <ConfirmModal
      v-if="toCancel"
      :title="'Cancel order #' + toCancel.id + '?'"
      confirm-text="Yes, cancel it"
      danger
      :busy="cancelling"
      @confirm="cancel"
      @cancel="toCancel = null"
    >
      <p>The order will be marked as cancelled ({{ money(toCancel.total) }}).</p>
    </ConfirmModal>
  </section>
</template>

<script>
import LoginPrompt from '@/components/shared/LoginPrompt.vue'
import ConfirmModal from '@/components/shared/ConfirmModal.vue'
import { api } from '@/js/api.js'
import { state, showToast } from '@/js/state.js'
import { money, formatDate, printLabel } from '@/js/helpers.js'

export default {
  name: 'OrdersView',
  components: { LoginPrompt, ConfirmModal },
  data() {
    return {
      state,
      orders: [],
      toCancel: null, // order waiting for the "are you sure"
      cancelling: false,
      loading: false,
      error: '',
      statusClass: {
        confirmed: 'text-bg-primary',
        shipped: 'text-bg-info',
        delivered: 'text-bg-success',
        cancelled: 'text-bg-secondary',
      },
    }
  },
  watch: {
    // the user is known a moment after the page opens (or changes after a log out)
    'state.user'(user) {
      if (user) this.load()
      else this.orders = []
    },
  },
  mounted() {
    if (this.state.user) this.load()
  },
  methods: {
    money,
    formatDate,
    printLabel,
    // UPDATE: the user cancels one of his orders
    async cancel() {
      this.cancelling = true
      try {
        await api.cancelOrder(this.toCancel.id)
        showToast('Order #' + this.toCancel.id + ' cancelled')
        this.toCancel = null
        await this.load()
      } catch (error) {
        showToast(error.message)
        this.toCancel = null
      } finally {
        this.cancelling = false
      }
    },
    async load() {
      this.loading = true
      this.error = ''
      try {
        this.orders = (await api.orders()).orders
      } catch (error) {
        this.error = error.message
      } finally {
        this.loading = false
      }
    },
  },
}
</script>
