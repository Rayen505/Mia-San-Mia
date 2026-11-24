// Helpers shared by the two pop-ups (product details and log in / sign up)

const FOCUSABLE =
  'a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled])'

// Keep keyboard focus inside the pop-up while it is open (Tab / Shift+Tab loop)
export function trapFocus(event, container) {
  if (event.key !== 'Tab' || !container) return
  const items = [...container.querySelectorAll(FOCUSABLE)].filter(
    (el) => el.offsetParent !== null
  )
  if (!items.length) return
  const first = items[0]
  const last = items[items.length - 1]
  if (event.shiftKey && document.activeElement === first) {
    event.preventDefault()
    last.focus()
  } else if (!event.shiftKey && document.activeElement === last) {
    event.preventDefault()
    first.focus()
  }
}

// Lock the page scroll; returns the element that opened the pop-up.
// A counter is used because two pop-ups can be open together (e.g. a question over the seat panel).
let locks = 0

export function lockPage() {
  locks++
  document.body.classList.add('modal-open')
  return document.activeElement
}

// Unlock the page scroll (when the last pop-up closes) and give focus back to the element that opened it
export function unlockPage(trigger) {
  locks = Math.max(0, locks - 1)
  if (locks === 0) document.body.classList.remove('modal-open')
  if (trigger && typeof trigger.focus === 'function') trigger.focus()
}
