<template>
  <nav class="section-nav section-pad" aria-label="Page sections">
    <div class="nav-logos d-none d-lg-flex">
      <img v-for="sponsor in sponsors" :key="sponsor.src" class="spon" :src="asset(sponsor.src)" :alt="sponsor.name" />
    </div>

    <div class="nav-links">
      <a
        v-for="section in sections"
        :key="section.id"
        :href="'#' + section.id"
        :class="{ active: section.id === activeId }"
        @click.prevent="scrollTo(section.id)"
      >
        {{ section.label }}
      </a>
    </div>

    <div class="d-none d-lg-block"></div>
  </nav>
</template>

<script>
import { asset } from '@/js/helpers.js'

export default {
  name: 'SectionNav',
  props: {
    sections: { type: Array, required: true }, // [{ id, label }]
    sponsors: { type: Array, default: () => [] },
  },
  data() {
    return { activeId: this.sections[0]?.id }
  },
  mounted() {
    // highlight the link of the section that is on screen
    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) this.activeId = entry.target.id
        })
      },
      { rootMargin: '-40% 0px -55% 0px' }
    )
    this.$nextTick(() => {
      this.sections.forEach((s) => {
        const el = document.getElementById(s.id)
        if (el) this.observer.observe(el)
      })
    })
  },
  beforeUnmount() {
    this.observer.disconnect()
  },
  methods: {
    asset,
    scrollTo(id) {
      document.getElementById(id)?.scrollIntoView({ behavior: 'smooth' })
    },
  },
}
</script>
