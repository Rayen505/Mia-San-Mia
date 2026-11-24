<template>
  <div class="app-toast" :class="{ show: state.toast.visible }" role="status" aria-live="polite">
    {{ state.toast.text }}
  </div>
</template>

<script>
import { state } from '@/js/state.js'

export default {
  name: 'ToastMessage',
  data() {
    return { state }
  },
}
</script>
