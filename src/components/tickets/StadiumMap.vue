<template>
  <div class="stadium-card">
    <!-- small map in the corner: the stand under the mouse (or the chosen one) turns orange -->
    <div class="minimap" aria-hidden="true">
      <svg viewBox="0 0 100 80">
        <ellipse cx="50" cy="40" rx="44" ry="34" fill="#f8fafc" stroke="#cbd5e1" stroke-width="3" />
        <rect x="30" y="24" width="40" height="32" rx="4" fill="#22c55e" />
        <path v-for="stand in stands" :key="stand.code" :d="shapes[stand.code].radar" :fill="stand.code === lit ? '#f59e0b' : '#94a3b8'" />
      </svg>
    </div>

    <img class="stadium-photo" :src="asset('img/stadium/stadium-map.jpg')" alt="The stadium seen from above" />

    <!-- one clickable shape per stand, drawn over the photo -->
    <svg class="stadium-svg" :viewBox="'0 0 ' + width + ' ' + height" role="group" aria-label="Stands of the stadium">
      <polygon
        v-for="stand in stands"
        :key="stand.code"
        :points="shapes[stand.code].points"
        class="stand-shape"
        :class="{ selected: stand.code === active }"
        tabindex="0"
        role="button"
        :aria-label="stand.name + ', ' + money(stand.price) + ' per seat'"
        :aria-pressed="stand.code === active"
        @click="$emit('select', stand.code)"
        @keydown.enter.prevent="$emit('select', stand.code)"
        @keydown.space.prevent="$emit('select', stand.code)"
        @mouseenter="hover = stand.code"
        @mouseleave="hover = ''"
        @focus="hover = stand.code"
        @blur="hover = ''"
      />
    </svg>

    <!-- name labels (also clickable, and easy to tap on a phone) -->
    <button
      v-for="stand in stands"
      :key="stand.code"
      type="button"
      class="stand-tag"
      :class="['tag-' + stand.code, { selected: stand.code === active }]"
      :aria-pressed="stand.code === active"
      @click="$emit('select', stand.code)"
      @mouseenter="hover = stand.code"
      @mouseleave="hover = ''"
    >
      {{ stand.name }}
    </button>
  </div>
</template>

<script>
import { MAP_WIDTH, MAP_HEIGHT, standShapes } from '@/js/data/stadium.js'
import { asset, money } from '@/js/helpers.js'

export default {
  name: 'StadiumMap',
  props: {
    stands: { type: Array, required: true }, // from the database: { code, name, price, ... }
    active: { type: String, default: '' }, // code of the chosen stand
  },
  emits: ['select'],
  data() {
    return {
      shapes: standShapes,
      width: MAP_WIDTH,
      height: MAP_HEIGHT,
      hover: '',
    }
  },
  computed: {
    // the stand shown in orange on the small map
    lit() {
      return this.hover || this.active
    },
  },
  methods: { asset, money },
}
</script>
