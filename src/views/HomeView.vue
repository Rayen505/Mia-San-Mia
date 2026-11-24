<template>
  <HeroSection />
  <MatchesSlider />
  <TicketsPromo
    title="Get Your Tickets NOW!"
    image="img/aa_haupttribuene.jpg"
    image-alt="Allianz Arena main stand"
  />
  <NewsTicker :items="news" />
</template>

<script>
import HeroSection from '@/components/home/HeroSection.vue'
import MatchesSlider from '@/components/home/MatchesSlider.vue'
import TicketsPromo from '@/components/home/TicketsPromo.vue'
import NewsTicker from '@/components/layout/NewsTicker.vue'
import { news } from '@/js/data/news.js'

export default {
  name: 'HomeView',
  components: { HeroSection, MatchesSlider, TicketsPromo, NewsTicker },
  data() {
    return { news }
  },
}
</script>
