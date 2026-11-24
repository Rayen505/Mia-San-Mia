<template>
  <div>
    <div class="admin-toolbar">
      <h2>Products <span class="admin-count">({{ products.length }})</span></h2>
      <button type="button" class="btn btn-fcb" @click="openForm(null)">+ Add product</button>
    </div>

    <div v-if="loading" class="text-center py-5">
      <span class="spinner-border" role="status"><span class="visually-hidden">Loading…</span></span>
    </div>
    <div v-else-if="error" class="alert alert-danger d-flex flex-wrap align-items-center justify-content-between gap-2" role="alert">
      <span>{{ error }}</span>
      <button type="button" class="btn btn-sm btn-outline-danger" @click="load">Try again</button>
    </div>

    <div v-else class="table-responsive admin-table-box">
      <table class="table align-middle admin-table">
        <thead>
          <tr>
            <th scope="col">Picture</th>
            <th scope="col">Name</th>
            <th scope="col">Category</th>
            <th scope="col" class="text-end">Price</th>
            <th scope="col">Options</th>
            <th scope="col" class="text-end">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="product in products" :key="product.id">
            <td>
              <img class="admin-thumb" :src="mediaUrl(product.img)" alt="" @error="$event.target.style.visibility = 'hidden'" />
            </td>
            <td>
              <strong>{{ product.name }}</strong>
              <div class="admin-info">{{ product.info }}</div>
            </td>
            <td class="text-capitalize">{{ product.cat }}</td>
            <td class="text-end">{{ money(product.price) }}</td>
            <td>
              <span v-if="product.featured" class="badge text-bg-danger me-1">Match kit</span>
              <span v-if="product.print" class="badge text-bg-light border">Printable</span>
              <span class="admin-sizes">{{ product.sizes.join(' ') || 'no sizes' }}</span>
            </td>
            <td class="text-end text-nowrap">
              <button type="button" class="btn btn-sm btn-outline-primary me-1" @click="openForm(product)">Edit</button>
              <button type="button" class="btn btn-sm btn-outline-danger" @click="toDelete = product">Delete</button>
            </td>
          </tr>
          <tr v-if="products.length === 0">
            <td colspan="6" class="text-center text-muted py-4">No product yet. Add the first one!</td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- add / edit -->
    <ProductForm v-if="formOpen" :key="editing ? editing.id : 'new'" :product="editing" @close="formOpen = false" @saved="saved" />

    <!-- delete -->
    <ConfirmModal
      v-if="toDelete"
      title="Delete this product?"
      confirm-text="Delete"
      danger
      :busy="deleting"
      @confirm="remove"
      @cancel="toDelete = null"
    >
      <p>
        <strong>{{ toDelete.name }}</strong> will be removed from the store and from the carts that contain it.
        Orders already placed keep their lines.
      </p>
    </ConfirmModal>
  </div>
</template>

<script>
import ProductForm from './ProductForm.vue'
import ConfirmModal from '@/components/shared/ConfirmModal.vue'
import { api } from '@/js/api.js'
import { showToast } from '@/js/state.js'
import { money, mediaUrl } from '@/js/helpers.js'

// The administrator manages the products: CREATE, READ, UPDATE, DELETE
export default {
  name: 'AdminProducts',
  components: { ProductForm, ConfirmModal },
  data() {
    return {
      products: [],
      loading: true,
      error: '',
      formOpen: false,
      editing: null, // product being edited (null = new product)
      toDelete: null, // product waiting for the "are you sure"
      deleting: false,
    }
  },
  created() {
    this.load()
  },
  methods: {
    money,
    mediaUrl,
    // READ
    async load() {
      this.loading = true
      this.error = ''
      try {
        this.products = (await api.products()).products
      } catch (error) {
        this.error = error.message
      } finally {
        this.loading = false
      }
    },
    openForm(product) {
      this.editing = product
      this.formOpen = true
    },
    // after CREATE or UPDATE
    async saved(product) {
      this.formOpen = false
      showToast(this.editing ? 'Product updated' : 'Product added')
      await this.load()
    },
    // DELETE
    async remove() {
      this.deleting = true
      try {
        await api.deleteProduct(this.toDelete.id)
        showToast(this.toDelete.name + ' deleted')
        this.toDelete = null
        await this.load()
      } catch (error) {
        showToast(error.message)
      } finally {
        this.deleting = false
      }
    },
  },
}
</script>
