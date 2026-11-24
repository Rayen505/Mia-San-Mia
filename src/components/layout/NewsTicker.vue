<template>
  <div class="ticker">
    <div class="ticker-label">{{ label }}</div>
    <div class="ticker-window">
      <div class="ticker-track">
        <span v-for="(item, i) in loopItems" :key="i" :aria-hidden="i >= items.length">{{ item }}</span>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'NewsTicker',
  props: {
    items: { type: Array, required: true },
    label: { type: String, default: 'BREAKING (not really)' },
  },
  computed: {
    // the list twice: moving the track by half of its width loops with no gap
    loopItems() {
      return [...this.items, ...this.items]
    },
  },
}
</script>
