<template>
  <section
    id="overview"
    ref="section"
    class="big-section rack-section"
    :class="{ 'rk-drag': dragging }"
    @pointerdown="onPress"
    @wheel.passive="onWheel"
  >
    <div class="rk-rail"></div>
    <div class="rk-h1">Fc Bayern</div>

    <div class="rk-scene" :style="{ perspectiveOrigin: origin }">
      <div class="rk-rig">
        <div
          v-for="(kit, i) in kits"
          :key="kit.img"
          class="rk-it"
          :class="{ on: i === current }"
          :style="itemStyles[i]"
          @click="onItemClick(i)"
        >
          <svg class="rk-hk" viewBox="0 0 44 58" aria-hidden="true">
            <path d="M22 2c-6 0-9 4-9 8 0 3 2 5 5 5" fill="none" stroke="#9a9aa0" stroke-width="3.5" stroke-linecap="round" />
            <path d="M22 15v8L2 50c-1 3 1 6 4 6h32c3 0 5-3 4-6L22 23" fill="none" stroke="#6b6b72" stroke-width="3.5" stroke-linejoin="round" />
          </svg>
          <img :src="asset(kit.img)" :alt="kit.name + ' ' + kit.season" />
        </div>
      </div>
    </div>

    <div class="rk-info">
      <div class="rk-nm">{{ currentKit.season }} · {{ currentKit.name }}</div>
      <div class="rk-ps">{{ currentKit.label }} · Click to inspect</div>
    </div>

    <!-- inspect view: big shirt you can turn around (moved to <body> with Teleport) -->
    <Teleport to="body">
      <div v-show="overlayVisible" class="rk-ov" :class="{ show: overlayShown }" @pointerdown="onFlipPress">
        <button class="rk-x" type="button" aria-label="Close" @click="closeOverlay">✕</button>

        <div class="rk-stage" :class="{ 'is-open': overlayShown }">
          <div class="rk-fl" :style="{ transform: flipTransform }">
            <div class="rk-fc">
              <img :src="asset(selected.img)" alt="" />
            </div>
            <div class="rk-fc rk-bk">
              <img :src="asset(selected.img)" alt="" />
              <div class="rk-pt" :style="{ backgroundImage: `url('${asset(selected.img)}')` }"></div>
              <div class="rk-bn">{{ player.name }}</div>
              <div class="rk-bnum">{{ player.number }}</div>
            </div>
          </div>
        </div>

        <div class="rk-oi">
          <h2>{{ selected.season }} · {{ selected.name }}</h2>
          <p>{{ selected.label }}</p>
          <div class="rk-bt">
            <button class="rk-btn rk-o" type="button" @click="showFront">Front</button>
            <button class="rk-btn rk-o" type="button" @click="showBack">Back</button>
            <button class="rk-btn rk-o" type="button" @click="changePlayer(-1)">‹ Player</button>
            <button class="rk-btn rk-o" type="button" @click="changePlayer(1)">Player ›</button>
            <button class="rk-btn" type="button" @click="seeAvailability">See Availability</button>
          </div>
        </div>
      </div>
    </Teleport>
  </section>
</template>

<script>
import { rackKits, players, DEFAULT_PLAYER } from '@/js/data/rack.js'
import { RackMotion, FlipMotion } from '@/js/rackMotion.js'
import { asset } from '@/js/helpers.js'

export default {
  name: 'KitRack',
  data() {
    return {
      kits: rackKits,
      players,
      itemStyles: [], // one style object per shirt, recalculated every frame
      origin: '50% 40%',
      current: 0, // shirt in the middle of the rack
      dragging: false,
      inView: true,
      // inspect view
      selectedIndex: 0,
      playerIndex: DEFAULT_PLAYER,
      overlayVisible: false,
      overlayShown: false,
      flipTransform: '',
    }
  },
  computed: {
    currentKit() {
      return this.kits[this.current]
    },
    selected() {
      return this.kits[this.selectedIndex]
    },
    player() {
      return this.players[this.playerIndex]
    },
  },
  created() {
    // animation state does not need to be reactive
    this.rack = new RackMotion(this.kits.length, Math.min(300, window.innerWidth * 0.6))
    this.flip = new FlipMotion()
  },
  mounted() {
    this.observer = new IntersectionObserver((entries) => {
      this.inView = entries[0].isIntersecting
    })
    this.observer.observe(this.$refs.section)

    window.addEventListener('pointermove', this.onMove)
    window.addEventListener('pointerup', this.onRelease)
    window.addEventListener('pointercancel', this.onCancel)
    window.addEventListener('keydown', this.onKey)

    this.raf = requestAnimationFrame(this.tick)
  },
  beforeUnmount() {
    cancelAnimationFrame(this.raf)
    clearTimeout(this.closeTimer)
    this.observer.disconnect()
    window.removeEventListener('pointermove', this.onMove)
    window.removeEventListener('pointerup', this.onRelease)
    window.removeEventListener('pointercancel', this.onCancel)
    window.removeEventListener('keydown', this.onKey)
    document.body.style.overflow = ''
  },
  methods: {
    asset,

    // ---------- animation loop ----------
    tick(time) {
      if (this.overlayVisible) {
        this.flipTransform = this.flip.frame()
      } else if (this.inView) {
        const frame = this.rack.frame(time)
        this.itemStyles = frame.styles
        this.current = frame.current
        this.origin = frame.origin
      }
      this.raf = requestAnimationFrame(this.tick)
    },

    // ---------- rack: drag, wheel, keyboard ----------
    onPress(event) {
      if (this.overlayVisible || event.target.closest('button')) return
      this.rack.press(event.clientX)
      this.dragging = true
    },
    onMove(event) {
      if (this.overlayVisible) {
        this.flip.move(event.clientX, event.clientY)
        return
      }
      const box = this.$refs.section.getBoundingClientRect()
      this.rack.look((event.clientX - box.left) / box.width - 0.5, (event.clientY - box.top) / box.height - 0.5)
      this.rack.move(event.clientX)
    },
    onRelease(event) {
      this.flip.release()
      if (!this.dragging) return
      this.wasClick = this.rack.release(event.clientX)
      this.dragging = false
    },
    onCancel() {
      this.rack.cancel()
      this.dragging = false
    },
    onWheel(event) {
      if (this.overlayVisible) return
      if (Math.abs(event.deltaX) > Math.abs(event.deltaY)) this.rack.push(-event.deltaX * 0.12)
    },
    onKey(event) {
      if (this.overlayVisible) {
        if (event.key === 'Escape') this.closeOverlay()
        return
      }
      if (!this.inView) return
      if (event.key === 'ArrowRight') this.rack.push(-14)
      if (event.key === 'ArrowLeft') this.rack.push(14)
    },
    onItemClick(index) {
      if (this.wasClick) this.openOverlay(index)
    },

    // ---------- inspect view ----------
    openOverlay(index) {
      clearTimeout(this.closeTimer)
      this.selectedIndex = index
      this.flip.reset()
      this.flipTransform = this.flip.frame()
      this.overlayVisible = true
      document.body.style.overflow = 'hidden'
      // wait two frames so the fade / zoom-in transition runs
      requestAnimationFrame(() => requestAnimationFrame(() => (this.overlayShown = true)))
    },
    closeOverlay() {
      this.overlayShown = false
      document.body.style.overflow = ''
      this.closeTimer = setTimeout(() => (this.overlayVisible = false), 350)
    },
    onFlipPress(event) {
      if (event.target.closest('button')) return
      this.flip.press(event.clientX, event.clientY)
    },
    showFront() {
      this.flip.showFront()
    },
    showBack() {
      this.flip.showBack()
    },
    changePlayer(step) {
      const n = this.players.length
      this.playerIndex = (this.playerIndex + step + n) % n
      this.flip.showBack()
    },
    seeAvailability() {
      this.closeOverlay()
      document.getElementById('store')?.scrollIntoView({ behavior: 'smooth' })
    },
  },
}
</script>
