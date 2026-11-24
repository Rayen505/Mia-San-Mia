<template>
  <section class="shop-page section-pad">
    <h1 class="page-title">Administration</h1>

    <div v-if="!state.ready" class="text-center py-5">
      <span class="spinner-border" role="status"><span class="visually-hidden">Loading…</span></span>
    </div>

    <LoginPrompt v-else-if="!state.user" message="Log in with the administrator account." />

    <div v-else-if="state.user.role !== 'admin'" class="empty-box">
      <p>This page is only for the administrator.</p>
      <RouterLink :to="{ name: 'home' }" class="btn btn-fcb">Back to the home page</RouterLink>
    </div>

    <template v-else>
      <ul class="nav nav-tabs admin-tabs" role="tablist">
        <li v-for="t in tabs" :key="t.value" class="nav-item" role="presentation">
          <button type="button" class="nav-link" :class="{ active: tab === t.value }" role="tab" :aria-selected="tab === t.value" @click="tab = t.value">
            {{ t.label }}
          </button>
        </li>
      </ul>

      <AdminProducts v-if="tab === 'products'" />
      <AdminOrders v-else />
    </template>
  </section>
</template>

<script>
import LoginPrompt from '@/components/shared/LoginPrompt.vue'
import AdminProducts from '@/components/admin/AdminProducts.vue'
import AdminOrders from '@/components/admin/AdminOrders.vue'
import { state } from '@/js/state.js'

export default {
  name: 'AdminView',
  components: { LoginPrompt, AdminProducts, AdminOrders },
  data() {
    return {
      state,
      tab: 'products',
      tabs: [
        { value: 'products', label: 'Products' },
        { value: 'orders', label: 'Orders' },
      ],
    }
  },
}
</script>
