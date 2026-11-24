<template>
  <div class="modal fcb-modal" tabindex="-1" @click.self="close">
    <div class="modal-dialog modal-dialog-centered auth-dialog" @click.self="close">
      <div
        ref="dialog"
        class="modal-content auth-card"
        role="dialog"
        aria-modal="true"
        aria-labelledby="authTitle"
      >
        <button class="modal-close" type="button" aria-label="Close" @click="close">&times;</button>

        <h2 id="authTitle">{{ heading.title }}</h2>
        <p class="auth-sub">{{ heading.sub }}</p>

        <div class="auth-tabs" role="tablist">
          <button
            v-for="t in tabs"
            :key="t.value"
            type="button"
            class="auth-tab"
            role="tab"
            :class="{ active: tab === t.value }"
            :aria-selected="tab === t.value"
            @click="switchTab(t.value)"
          >
            {{ t.label }}
          </button>
        </div>

        <!-- LOG IN -->
        <form
          v-if="tab === 'login'"
          ref="loginForm"
          class="auth-form fcb-form"
          :class="{ 'was-validated': tried }"
          novalidate
          @submit.prevent="submitLogin"
        >
          <div>
            <label class="form-label" for="lEmail">Email</label>
            <input id="lEmail" v-model.trim="login.email" type="email" class="form-control" autocomplete="email" required />
            <div class="invalid-feedback">Please enter a valid email address.</div>
          </div>
          <div>
            <label class="form-label" for="lPass">Password</label>
            <input
              id="lPass"
              v-model="login.password"
              :type="showPassword ? 'text' : 'password'"
              class="form-control"
              autocomplete="current-password"
              required
            />
            <div class="invalid-feedback">Please enter your password.</div>
          </div>
          <div class="form-check fcb-check">
            <input id="lShow" v-model="showPassword" class="form-check-input" type="checkbox" />
            <label class="form-check-label" for="lShow">Show password</label>
          </div>
          <div v-if="error" class="alert alert-danger auth-error" role="alert">{{ error }}</div>
          <button class="btn btn-fcb w-100" type="submit" :disabled="busy">
            <span v-if="busy" class="spinner-border spinner-border-sm" aria-hidden="true"></span>
            {{ busy ? 'Logging in…' : 'Log in' }}
          </button>
          <p class="auth-switch">
            No account yet?
            <button type="button" @click="switchTab('signup')">Sign up</button>
          </p>
        </form>

        <!-- SIGN UP -->
        <form
          v-else
          ref="signupForm"
          class="auth-form fcb-form"
          :class="{ 'was-validated': tried }"
          novalidate
          @submit.prevent="submitSignup"
        >
          <!-- the photo is mandatory -->
          <ImagePicker
            id="sPhoto"
            v-model="photo"
            label="Your photo"
            required
            round
            :error="tried && !photo ? 'Please add your photo.' : ''"
          />
          <div>
            <label class="form-label" for="sName">Full name</label>
            <input id="sName" v-model.trim="signup.name" type="text" class="form-control" autocomplete="name" required />
            <div class="invalid-feedback">Please enter your name.</div>
          </div>
          <div>
            <label class="form-label" for="sEmail">Email</label>
            <input id="sEmail" v-model.trim="signup.email" type="email" class="form-control" autocomplete="email" required />
            <div class="invalid-feedback">Please enter a valid email address.</div>
          </div>
          <div>
            <label class="form-label" for="sPass">Password (8 characters or more)</label>
            <input
              id="sPass"
              v-model="signup.password"
              type="password"
              class="form-control"
              minlength="8"
              autocomplete="new-password"
              required
            />
            <div class="invalid-feedback">At least 8 characters.</div>
          </div>
          <div>
            <label class="form-label" for="sPass2">Confirm password</label>
            <input
              id="sPass2"
              ref="password2"
              v-model="signup.password2"
              type="password"
              class="form-control"
              :class="{ 'is-invalid': passwordMismatch }"
              autocomplete="new-password"
              required
            />
            <div class="invalid-feedback">The two passwords do not match.</div>
          </div>

          <div class="form-check fcb-check">
            <input id="sTerms" v-model="signup.terms" class="form-check-input" type="checkbox" required />
            <label class="form-check-label" for="sTerms">I agree to the terms and the privacy policy.</label>
          </div>

          <div v-if="error" class="alert alert-danger auth-error" role="alert">{{ error }}</div>
          <button class="btn btn-fcb w-100" type="submit" :disabled="busy">
            <span v-if="busy" class="spinner-border spinner-border-sm" aria-hidden="true"></span>
            {{ busy ? 'Creating your account…' : 'Create account' }}
          </button>
          <p class="auth-switch">
            Already have an account?
            <button type="button" @click="switchTab('login')">Log in</button>
          </p>
        </form>
      </div>
    </div>
  </div>
  <div class="modal-backdrop show"></div>
</template>

<script>
import { state, closeAuth, showToast, login, signup } from '@/js/state.js'
import { trapFocus, lockPage, unlockPage } from '@/js/modal.js'
import ImagePicker from './ImagePicker.vue'

export default {
  name: 'AuthModal',
  components: { ImagePicker },
  data() {
    return {
      tab: state.authTab, // 'login' or 'signup'
      tabs: [
        { value: 'login', label: 'Log in' },
        { value: 'signup', label: 'Sign up' },
      ],
      texts: {
        login: { title: 'Log in', sub: 'Welcome back. Log in to your account.' },
        signup: { title: 'Create your account', sub: 'Sign up with your photo, name, email and a password.' },
      },
      login: { email: '', password: '' },
      signup: { name: '', email: '', password: '', password2: '', terms: false },
      photo: null, // the profile photo (a File chosen in the form)
      showPassword: false,
      tried: false, // true after a submit -> Bootstrap shows the errors
      busy: false, // true while the server is answering
      error: '', // message of the server (wrong password, email already used, ...)
    }
  },
  computed: {
    heading() {
      return this.texts[this.tab]
    },
    passwordMismatch() {
      return this.signup.password2 !== '' && this.signup.password !== this.signup.password2
    },
  },
  mounted() {
    this.trigger = lockPage()
    window.addEventListener('keydown', this.onKey)
    this.focusFirstField()
  },
  beforeUnmount() {
    window.removeEventListener('keydown', this.onKey)
    unlockPage(this.trigger)
  },
  methods: {
    close() {
      closeAuth()
    },
    switchTab(tab) {
      this.tab = tab
      this.tried = false
      this.error = ''
      this.focusFirstField()
    },
    focusFirstField() {
      this.$nextTick(() => this.$refs.dialog?.querySelector('form input')?.focus())
    },
    onKey(event) {
      if (event.key === 'Escape') this.close()
      trapFocus(event, this.$refs.dialog)
    },
    async submitLogin() {
      this.error = ''
      if (!this.$refs.loginForm.checkValidity()) {
        this.tried = true
        return
      }
      this.busy = true
      try {
        // checks the email and password in the database
        await login(this.login.email, this.login.password)
        showToast('Welcome back, ' + state.user.name.split(' ')[0] + '!')
        this.close()
      } catch (error) {
        this.error = error.message
      } finally {
        this.busy = false
      }
    },
    async submitSignup() {
      this.error = ''
      if (!this.$refs.signupForm.checkValidity() || !this.photo) {
        this.tried = true
        return
      }
      if (this.passwordMismatch) {
        this.$refs.password2.focus()
        return
      }
      this.busy = true
      try {
        // a form with a file: the server saves the photo and the new user in the database, and logs him in
        const form = new FormData()
        form.append('name', this.signup.name)
        form.append('email', this.signup.email)
        form.append('password', this.signup.password)
        form.append('photo', this.photo)
        await signup(form)
        showToast('Account created. Welcome, ' + state.user.name.split(' ')[0] + '!')
        this.close()
      } catch (error) {
        this.error = error.message
      } finally {
        this.busy = false
      }
    },
  },
}
</script>
