<template>
  <section id="competition" class="contest section-pad">
    <div class="contest-card">
      <h2>Win a free jersey</h2>
      <p class="contest-intro">
        Fill in the form for a chance to win a free FC Bayern jersey. One entry per person.
      </p>

      <form ref="form" class="fcb-form" :class="{ 'was-validated': tried }" novalidate @submit.prevent="submit">
        <div class="row g-3">
          <div class="col-md-6">
            <label class="form-label" for="cName">Full name</label>
            <input id="cName" v-model.trim="entry.name" type="text" class="form-control" autocomplete="name" required />
            <div class="invalid-feedback">Please enter your name.</div>
          </div>

          <div class="col-md-6">
            <label class="form-label" for="cEmail">Email</label>
            <input id="cEmail" v-model.trim="entry.email" type="email" class="form-control" autocomplete="email" required />
            <div class="invalid-feedback">Please enter a valid email address.</div>
          </div>

          <div class="col-md-6">
            <label class="form-label" for="cPhone">Phone</label>
            <input id="cPhone" v-model.trim="entry.phone" type="tel" class="form-control" autocomplete="tel" required />
            <div class="invalid-feedback">Please enter your phone number.</div>
          </div>

          <div class="col-md-6">
            <label class="form-label" for="cCountry">Country</label>
            <input id="cCountry" v-model.trim="entry.country" type="text" class="form-control" autocomplete="country-name" required />
            <div class="invalid-feedback">Please enter your country.</div>
          </div>

          <div class="col-md-6">
            <label class="form-label" for="cSize">Jersey size</label>
            <select id="cSize" v-model="entry.size" class="form-select" required>
              <option value="">Choose a size</option>
              <option v-for="size in sizes" :key="size" :value="size">{{ size }}</option>
            </select>
            <div class="invalid-feedback">Please choose a size.</div>
          </div>

          <div class="col-md-6">
            <label class="form-label" for="cPlayer">Favourite player</label>
            <input id="cPlayer" v-model.trim="entry.player" type="text" class="form-control" list="playerList" required />
            <datalist id="playerList">
              <option v-for="p in players" :key="p.name" :value="titleCase(p.name)"></option>
            </datalist>
            <div class="invalid-feedback">Please tell us your favourite player.</div>
          </div>

          <div class="col-12">
            <label class="form-label" for="cAnswer">Why do you deserve the jersey?</label>
            <input
              id="cAnswer"
              v-model="entry.answer"
              type="text"
              class="form-control"
              :maxlength="maxAnswer"
              required
            />
            <div class="invalid-feedback">Please write a short answer.</div>
            <div class="char-count" :class="{ 'is-low': charsLeft <= 20 }">{{ charsLeft }} characters left</div>
          </div>
        </div>

        <div class="form-check fcb-check">
          <input id="cTerms" v-model="entry.terms" class="form-check-input" type="checkbox" required />
          <label class="form-check-label" for="cTerms">
            I agree to the competition rules and to be contacted if I win.
          </label>
        </div>

        <div v-if="error" class="alert alert-danger" role="alert">{{ error }}</div>

        <button class="btn btn-fcb" type="submit" :disabled="busy">
          <span v-if="busy" class="spinner-border spinner-border-sm" aria-hidden="true"></span>
          {{ busy ? 'Sending…' : 'Enter the competition' }}
        </button>

        <div v-if="winnerName" class="form-msg" role="status">
          Thank you, {{ winnerName }}! Your entry has been received.
        </div>
      </form>
    </div>
  </section>
</template>

<script>
import { api } from '@/js/api.js'
import { state } from '@/js/state.js'
import { SIZES } from '@/js/data/products.js'
import { players } from '@/js/data/rack.js'
import { titleCase } from '@/js/helpers.js'

const emptyEntry = () => ({
  name: state.user ? state.user.name : '', // filled in from the profile
  email: state.user ? state.user.email : '',
  phone: '',
  country: '',
  size: '',
  player: '',
  answer: '',
  terms: false,
})

export default {
  name: 'ContestForm',
  data() {
    return {
      entry: emptyEntry(),
      sizes: SIZES,
      players,
      maxAnswer: 140,
      tried: false, // true after a submit -> Bootstrap shows the errors
      winnerName: '', // first name shown in the thank-you message
      busy: false, // true while the server saves the entry
      error: '', // message of the server (for example: this email already entered)
    }
  },
  computed: {
    charsLeft() {
      return this.maxAnswer - this.entry.answer.length
    },
  },
  methods: {
    titleCase,
    async submit() {
      const form = this.$refs.form
      this.error = ''
      if (!form.checkValidity()) {
        this.tried = true
        this.winnerName = ''
        form.querySelector(':invalid')?.focus()
        return
      }
      this.busy = true
      try {
        // the entry is saved in the database (table contest_entries)
        const result = await api.contest(this.entry)
        this.winnerName = result.name.split(' ')[0]
        this.entry = emptyEntry()
        this.tried = false
      } catch (error) {
        this.winnerName = ''
        this.error = error.message
      } finally {
        this.busy = false
      }
    },
  },
}
</script>
