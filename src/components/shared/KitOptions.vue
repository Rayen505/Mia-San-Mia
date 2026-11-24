<template>
  <div class="row g-3 fcb-form">
    <div v-if="sizes.length" class="col-sm-6">
      <label class="form-label" :for="idPrefix + '-size'">Size</label>
      <select :id="idPrefix + '-size'" v-model="size" class="form-select">
        <option v-for="s in sizes" :key="s" :value="s">{{ s }}</option>
      </select>
    </div>

    <div class="col-sm-6">
      <label class="form-label" :for="idPrefix + '-qty'">Quantity</label>
      <input :id="idPrefix + '-qty'" v-model.number="qty" type="number" class="form-control" min="1" max="10" />
    </div>

    <template v-if="printable">
      <div class="col-sm-6">
        <label class="form-label" :for="idPrefix + '-name'">Name on shirt</label>
        <input
          :id="idPrefix + '-name'"
          v-model.trim="name"
          type="text"
          class="form-control"
          maxlength="12"
          placeholder="e.g. NEUER"
        />
      </div>
      <div class="col-sm-6">
        <label class="form-label" :for="idPrefix + '-num'">Number</label>
        <input
          :id="idPrefix + '-num'"
          v-model.number="number"
          type="number"
          class="form-control"
          min="0"
          max="99"
          placeholder="1"
        />
      </div>
    </template>
  </div>
</template>

<script>
// Size / quantity / name / number fields of a shirt.
// Used with v-model on an object: <KitOptions v-model="options" ... />
export default {
  name: 'KitOptions',
  props: {
    modelValue: { type: Object, required: true }, // { size, qty, name, number }
    sizes: { type: Array, default: () => [] },
    printable: { type: Boolean, default: false },
    idPrefix: { type: String, required: true }, // keeps the ids unique on the page
  },
  emits: ['update:modelValue'],
  computed: {
    // writable computed properties: read from the prop, write by emitting a new object
    size: {
      get() { return this.modelValue.size },
      set(value) { this.update('size', value) },
    },
    qty: {
      get() { return this.modelValue.qty },
      set(value) { this.update('qty', value) },
    },
    name: {
      get() { return this.modelValue.name },
      set(value) { this.update('name', value.toUpperCase()) },
    },
    number: {
      get() { return this.modelValue.number },
      set(value) { this.update('number', value) },
    },
  },
  methods: {
    update(key, value) {
      this.$emit('update:modelValue', { ...this.modelValue, [key]: value })
    },
  },
}
</script>
