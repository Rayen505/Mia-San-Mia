<template>
  <footer class="site-footer section-pad">
    <p>&copy; {{ year }} My Bayern page</p>
  </footer>
</template>

<script>
export default {
  name: 'AppFooter',
  data() {
    return { year: new Date().getFullYear() }
  },
}
</script>
