<template>
  <div class="filters" role="group" :aria-label="label">
    <button
      v-for="option in options"
      :key="option.value"
      type="button"
      class="filter-btn"
      :class="['filter-btn--' + color, { active: option.value === modelValue }]"
      :aria-pressed="option.value === modelValue"
      @click="$emit('update:modelValue', option.value)"
    >
      {{ option.label }}
    </button>
  </div>
</template>

<script>
// Row of pill buttons. Used with v-model: <FilterButtons v-model="filter" :options="..." />
export default {
  name: 'FilterButtons',
  props: {
    options: { type: Array, required: true }, // [{ value, label }]
    modelValue: { type: String, required: true },
    color: {
      type: String,
      default: 'blue',
      validator: (value) => ['blue', 'red'].includes(value),
    },
    label: { type: String, default: 'Filter' },
  },
  emits: ['update:modelValue'],
}
</script>
