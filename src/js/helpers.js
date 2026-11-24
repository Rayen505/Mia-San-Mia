// Small helpers used by many components

import { fileUrl } from './api.js'

// Files in the /public folder (images) -> URL that works in dev and after "npm run build"
export const asset = (path) => import.meta.env.BASE_URL + encodeURI(path)

// 99.95 -> "€99.95"
export const money = (n) => '€' + n.toFixed(2)

export const clamp = (n, min, max) => Math.min(max, Math.max(min, n))

// "MUSIALA" -> "Musiala"
export const titleCase = (word) => word.charAt(0) + word.slice(1).toLowerCase()

// Default values of the "size / quantity / name / number" form of a shirt
export const newKitOptions = (sizes = []) => ({
  size: sizes[1] || sizes[0] || '',
  qty: 1,
  name: '',
  number: '',
})

// "2026-11-17 18:33:56" (date saved by the server) -> "17 Nov 2026, 18:33"
export const formatDate = (text) => {
  if (!text) return ''
  const date = new Date(text.replace(' ', 'T'))
  return isNaN(date) ? text : date.toLocaleString('en-GB', { dateStyle: 'medium', timeStyle: 'short' })
}

// printed name + number of a shirt line, e.g. "MUSIALA 10" ('' if nothing is printed)
export const printLabel = (item) =>
  [item.print_name, item.print_number].filter((v) => v !== '' && v !== null && v !== undefined).join(' ')

// Picture of a product or a user. Pictures uploaded through the website are saved by the
// back end ("uploads/..."), the other pictures are files of the /public folder.
export const mediaUrl = (path) => {
  if (!path) return ''
  return path.startsWith('uploads/') ? fileUrl(path) : asset(path)
}
