// Animation maths for the hanging-kit rack (store page, "Overview").
// No Vue in here: KitRack.vue calls these methods and puts the results
// into its :style bindings.

import { clamp } from './helpers.js'

// The row of shirts: drag, inertia, snap to the nearest shirt, 3D look
export class RackMotion {
  constructor(count, gap) {
    this.count = count
    this.gap = gap // px between two shirts
    this.total = count * gap
    this.offset = 0 // how far the rack has been pulled
    this.velocity = 0
    this.swing = 0 // smoothed velocity -> shirts swing when the rack moves
    this.target = { x: 0, y: 0 } // pointer position in the section (-0.5 … 0.5)
    this.tilt = { x: 0, y: 0 } // smoothed pointer position
    this.dragging = false
    this.startX = 0
    this.lastX = 0
    this.lastTime = 0
  }

  press(x) {
    this.dragging = true
    this.velocity = 0
    this.startX = this.lastX = x
    this.lastTime = performance.now()
  }

  move(x) {
    if (!this.dragging) return
    const dx = x - this.lastX
    this.offset += dx
    this.velocity = clamp(this.velocity * 0.4 + dx * 0.6, -60, 60)
    this.lastX = x
    this.lastTime = performance.now()
  }

  // returns true when the pointer hardly moved: it was a click, not a drag
  release(x) {
    if (!this.dragging) return false
    this.dragging = false
    if (performance.now() - this.lastTime > 90) this.velocity = 0
    return Math.abs(x - this.startX) < 6
  }

  cancel() {
    this.dragging = false
  }

  look(x, y) {
    this.target.x = x
    this.target.y = y
  }

  push(amount) {
    this.velocity += amount
  }

  // called on every animation frame
  frame(time) {
    if (!this.dragging) {
      this.offset += this.velocity
      this.velocity *= 0.92
      if (Math.abs(this.velocity) < 0.6) {
        const snap = Math.round(this.offset / this.gap) * this.gap
        this.offset += (snap - this.offset) * 0.09
      }
    }
    this.swing += (this.velocity - this.swing) * 0.1
    this.tilt.x += (this.target.x - this.tilt.x) * 0.06
    this.tilt.y += (this.target.y - this.tilt.y) * 0.06

    const T = this.total
    const styles = []
    let current = 0
    let closest = Infinity

    for (let i = 0; i < this.count; i++) {
      const x = ((((i * this.gap + this.offset) % T) + T * 1.5) % T) - T / 2
      const dist = Math.abs(x / this.gap) // 0 = shirt in the middle
      if (dist < closest) {
        closest = dist
        current = i
      }
      const turn = clamp((x / this.gap) * 34, -75, 75) - this.tilt.x * 14
      const swing = Math.sin(time / 700 + i) * 1.4 + this.swing * 0.35
      styles.push({
        transform: `translateX(${x}px) translateZ(${-dist * 70}px) rotateY(${turn}deg) rotateZ(${swing}deg)`,
        opacity: Math.max(0, 1 - dist * 0.22),
        filter: `brightness(${1 - Math.min(dist, 2) * 0.1})`,
      })
    }

    return {
      styles,
      current,
      origin: `${50 + this.tilt.x * 10}% ${40 + this.tilt.y * 10}%`,
    }
  }
}

// The big shirt in the "inspect" view: turn it with the mouse, front / back
export class FlipMotion {
  constructor() {
    this.reset()
  }

  reset() {
    this.ry = -360 // starts one full turn away -> spins in
    this.rx = 0
    this.target = 0
    this.dragging = false
  }

  showFront() {
    this.target = Math.round(this.ry / 360) * 360
  }

  showBack() {
    this.target = Math.round((this.ry - 180) / 360) * 360 + 180
  }

  press(x, y) {
    this.dragging = true
    this.lastX = x
    this.lastY = y
  }

  move(x, y) {
    if (!this.dragging) return
    this.ry += (x - this.lastX) * 0.7
    this.rx = clamp(this.rx + (y - this.lastY) * 0.2, -18, 18)
    this.lastX = x
    this.lastY = y
  }

  release() {
    if (!this.dragging) return
    this.dragging = false
    this.target = Math.round(this.ry / 180) * 180
  }

  frame() {
    if (!this.dragging) {
      this.ry += (this.target - this.ry) * 0.09
      this.rx *= 0.9
    }
    return `rotateX(${this.rx}deg) rotateY(${this.ry}deg)`
  }
}
