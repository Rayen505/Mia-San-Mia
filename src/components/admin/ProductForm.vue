<template>
  <div class="modal fcb-modal" tabindex="-1" @click.self="$emit('close')">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable product-form-dialog" @click.self="$emit('close')">
      <div ref="dialog" class="modal-content product-form-card" role="dialog" aria-modal="true" aria-labelledby="pfTitle">
        <button class="modal-close" type="button" aria-label="Close" @click="$emit('close')">&times;</button>

        <form class="fcb-form" :class="{ 'was-validated': tried }" novalidate @submit.prevent="submit">
          <h2 id="pfTitle">{{ product ? 'Edit product' : 'Add a product' }}</h2>

          <div class="row g-3">
            <div class="col-md-8">
              <label class="form-label" for="pfName">Name</label>
              <input id="pfName" v-model.trim="form.name" type="text" class="form-control" :class="{ 'is-invalid': errors.name }" maxlength="120" required />
              <div class="invalid-feedback">{{ errors.name || 'Please enter a name.' }}</div>
            </div>
            <div class="col-md-4">
              <label class="form-label" for="pfPrice">Price (€)</label>
              <input id="pfPrice" v-model="form.price" type="number" step="0.01" min="0.01" max="9999.99" class="form-control" :class="{ 'is-invalid': errors.price }" required />
              <div class="invalid-feedback">{{ errors.price || 'Enter a price.' }}</div>
            </div>

            <div class="col-md-6">
              <label class="form-label" for="pfCat">Category (colour)</label>
              <select id="pfCat" v-model="form.category" class="form-select" :class="{ 'is-invalid': errors.category }" required>
                <option v-for="c in categoryOptions" :key="c.value" :value="c.value">{{ c.label }}</option>
              </select>
              <div class="invalid-feedback">{{ errors.category || 'Choose a category.' }}</div>
            </div>
            <div class="col-md-6">
              <label class="form-label d-block">Sizes</label>
              <!-- v-model on several checkboxes: form.sizes is an array -->
              <div class="size-checks" :class="{ 'is-invalid': errors.sizes }">
                <div v-for="size in allSizes" :key="size" class="form-check form-check-inline">
                  <input :id="'pfSize' + size" v-model="form.sizes" class="form-check-input" type="checkbox" :value="size" />
                  <label class="form-check-label" :for="'pfSize' + size">{{ size }}</label>
                </div>
              </div>
              <div v-if="errors.sizes" class="invalid-feedback d-block">{{ errors.sizes }}</div>
            </div>

            <div class="col-12">
              <label class="form-label" for="pfInfo">Short line (shown on the card)</label>
              <input id="pfInfo" v-model.trim="form.short_info" type="text" class="form-control" :class="{ 'is-invalid': errors.short_info }" maxlength="255" required />
              <div class="invalid-feedback">{{ errors.short_info || 'Write a short line.' }}</div>
            </div>
            <div class="col-12">
              <label class="form-label" for="pfDesc">Description</label>
              <textarea id="pfDesc" v-model.trim="form.description" rows="3" class="form-control product-textarea" :class="{ 'is-invalid': errors.description }" maxlength="2000" required></textarea>
              <div class="invalid-feedback">{{ errors.description || 'Write a description.' }}</div>
            </div>

            <div class="col-12">
              <ImagePicker
                id="pfImage"
                v-model="imageFile"
                label="Product picture"
                :required="!product"
                :current-url="product ? mediaUrl(product.img) : ''"
                :error="errors.image || (tried && !product && !imageFile ? 'Please choose a picture.' : '')"
              />
            </div>

            <div class="col-sm-6">
              <div class="form-check form-switch">
                <input id="pfPrint" v-model="form.printable" class="form-check-input" type="checkbox" role="switch" />
                <label class="form-check-label" for="pfPrint">Name and number can be printed</label>
              </div>
            </div>
            <div class="col-sm-6">
              <div class="form-check form-switch">
                <input id="pfFeatured" v-model="form.featured" class="form-check-input" type="checkbox" role="switch" />
                <label class="form-check-label" for="pfFeatured">Show as the big "Match kit" card</label>
              </div>
            </div>
          </div>

          <div v-if="error" class="alert alert-danger mt-3 mb-0" role="alert">{{ error }}</div>

          <div class="d-flex flex-wrap gap-2 justify-content-end mt-4">
            <button type="button" class="btn btn-fcb-outline" @click="$emit('close')">Cancel</button>
            <button type="submit" class="btn btn-fcb" :disabled="busy">
              <span v-if="busy" class="spinner-border spinner-border-sm" aria-hidden="true"></span>
              {{ product ? 'Save changes' : 'Add product' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
  <div class="modal-backdrop show"></div>
</template>

<script>
import ImagePicker from '@/components/shared/ImagePicker.vue'
import { api } from '@/js/api.js'
import { SIZES, categories } from '@/js/data/products.js'
import { mediaUrl } from '@/js/helpers.js'
import { trapFocus, lockPage, unlockPage } from '@/js/modal.js'

// Form to ADD a product (product = null) or EDIT one (product = the product).
export default {
  name: 'ProductForm',
  components: { ImagePicker },
  props: {
    product: { type: Object, default: null },
  },
  emits: ['close', 'saved'],
  data() {
    const p = this.product
    return {
      allSizes: SIZES,
      categoryOptions: categories.filter((c) => c.value !== 'all'),
      form: {
        name: p ? p.name : '',
        price: p ? p.price : '',
        category: p ? p.cat : 'red',
        sizes: p ? [...p.sizes] : [...SIZES],
        short_info: p ? p.info : '',
        description: p ? p.desc : '',
        printable: p ? p.print : true,
        featured: p ? p.featured : false,
      },
      imageFile: null, // new picture (optional when editing)
      tried: false, // true after a submit -> Bootstrap shows the errors
      errors: {}, // field errors sent by the server
      error: '',
      busy: false,
    }
  },
  mounted() {
    this.trigger = lockPage()
    window.addEventListener('keydown', this.onKey)
    this.$refs.dialog.querySelector('input')?.focus()
  },
  beforeUnmount() {
    window.removeEventListener('keydown', this.onKey)
    unlockPage(this.trigger)
  },
  methods: {
    mediaUrl,
    onKey(event) {
      if (event.key === 'Escape') this.$emit('close')
      trapFocus(event, this.$refs.dialog)
    },
    async submit(event) {
      this.error = ''
      this.errors = {}
      if (!event.target.checkValidity() || (!this.product && !this.imageFile)) {
        this.tried = true
        return
      }
      this.busy = true
      try {
        // a form with a file (the picture)
        const data = new FormData()
        if (this.product) data.append('id', this.product.id)
        data.append('name', this.form.name)
        data.append('price', this.form.price)
        data.append('category', this.form.category)
        data.append('sizes', this.form.sizes.join(','))
        data.append('short_info', this.form.short_info)
        data.append('description', this.form.description)
        data.append('printable', this.form.printable ? '1' : '0')
        data.append('featured', this.form.featured ? '1' : '0')
        if (this.imageFile) data.append('image', this.imageFile)

        const result = this.product ? await api.updateProduct(data) : await api.createProduct(data)
        this.$emit('saved', result.product)
      } catch (error) {
        this.error = error.message
        this.errors = error.fields
      } finally {
        this.busy = false
      }
    },
  },
}
</script>
