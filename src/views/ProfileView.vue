<template>
  <section class="shop-page section-pad">
    <h1 class="page-title">My profile</h1>

    <div v-if="!state.ready" class="text-center py-5">
      <span class="spinner-border" role="status"><span class="visually-hidden">Loading…</span></span>
    </div>

    <LoginPrompt v-else-if="!state.user" message="Log in to see and change your profile." />

    <div v-else class="row g-4">
      <!-- who am I -->
      <div class="col-lg-4">
        <aside class="profile-card">
          <UserAvatar :user="state.user" :size="120" />
          <h2>{{ state.user.name }}</h2>
          <p class="profile-email">{{ state.user.email }}</p>
          <span class="badge rounded-pill" :class="state.user.role === 'admin' ? 'text-bg-danger' : 'text-bg-primary'">
            {{ state.user.role === 'admin' ? 'Administrator' : 'Member' }}
          </span>
          <p class="profile-since">Member since {{ formatDate(state.user.created_at) }}</p>
        </aside>
      </div>

      <div class="col-lg-8">
        <!-- UPDATE: name, email, photo -->
        <form class="profile-box fcb-form" :class="{ 'was-validated': profileTried }" novalidate @submit.prevent="saveProfile">
          <h2>Edit my profile</h2>
          <div class="row g-3">
            <div class="col-md-6">
              <label class="form-label" for="pName">Full name</label>
              <input id="pName" v-model.trim="profile.name" type="text" class="form-control" :class="{ 'is-invalid': profileErrors.name }" required />
              <div class="invalid-feedback">{{ profileErrors.name || 'Please enter your name.' }}</div>
            </div>
            <div class="col-md-6">
              <label class="form-label" for="pEmail">Email</label>
              <input id="pEmail" v-model.trim="profile.email" type="email" class="form-control" :class="{ 'is-invalid': profileErrors.email }" required />
              <div class="invalid-feedback">{{ profileErrors.email || 'Please enter a valid email address.' }}</div>
            </div>
            <div class="col-12">
              <ImagePicker id="pPhoto" v-model="newPhoto" label="New photo (optional)" round :current-url="mediaUrl(state.user.photo)" :error="profileErrors.photo || ''" />
            </div>
          </div>
          <div v-if="profileError" class="alert alert-danger mt-3 mb-0" role="alert">{{ profileError }}</div>
          <button class="btn btn-fcb mt-3" type="submit" :disabled="busy === 'profile'">
            <span v-if="busy === 'profile'" class="spinner-border spinner-border-sm" aria-hidden="true"></span>
            Save changes
          </button>
        </form>

        <!-- UPDATE: password -->
        <form class="profile-box fcb-form" :class="{ 'was-validated': passwordTried }" novalidate @submit.prevent="savePassword">
          <h2>Change my password</h2>
          <div class="row g-3">
            <div class="col-md-6">
              <label class="form-label" for="pCurrent">Current password</label>
              <input id="pCurrent" v-model="password.current" type="password" class="form-control" :class="{ 'is-invalid': passwordErrors.current_password }" autocomplete="current-password" required />
              <div class="invalid-feedback">{{ passwordErrors.current_password || 'Enter your current password.' }}</div>
            </div>
            <div class="col-md-6">
              <label class="form-label" for="pNew">New password (8 characters or more)</label>
              <input id="pNew" v-model="password.next" type="password" class="form-control" :class="{ 'is-invalid': passwordErrors.new_password }" minlength="8" autocomplete="new-password" required />
              <div class="invalid-feedback">{{ passwordErrors.new_password || 'At least 8 characters.' }}</div>
            </div>
          </div>
          <button class="btn btn-fcb-outline mt-3" type="submit" :disabled="busy === 'password'">
            <span v-if="busy === 'password'" class="spinner-border spinner-border-sm" aria-hidden="true"></span>
            Change password
          </button>
        </form>

        <!-- DELETE -->
        <div class="profile-box profile-danger">
          <h2>Delete my account</h2>
          <p>This deletes your account, your photo and all your orders. It cannot be undone.</p>
          <button type="button" class="btn btn-outline-danger" @click="openDelete">Delete my account</button>
        </div>
      </div>
    </div>

    <ConfirmModal
      v-if="deleting"
      title="Delete your account?"
      confirm-text="Yes, delete my account"
      danger
      :busy="busy === 'delete'"
      :disabled="!deletePassword"
      @confirm="deleteAccount"
      @cancel="deleting = false"
    >
      <p>Your account, your photo and your orders will be deleted for ever.</p>
      <label class="form-label" for="delPass">Enter your password to confirm</label>
      <input id="delPass" v-model="deletePassword" type="password" class="form-control" :class="{ 'is-invalid': deleteError }" autocomplete="current-password" @keyup.enter="deleteAccount" />
      <div class="invalid-feedback">{{ deleteError }}</div>
    </ConfirmModal>
  </section>
</template>

<script>
import LoginPrompt from '@/components/shared/LoginPrompt.vue'
import UserAvatar from '@/components/shared/UserAvatar.vue'
import ImagePicker from '@/components/shared/ImagePicker.vue'
import ConfirmModal from '@/components/shared/ConfirmModal.vue'
import { api } from '@/js/api.js'
import { state, setUser, clearSession, showToast } from '@/js/state.js'
import { mediaUrl, formatDate } from '@/js/helpers.js'

export default {
  name: 'ProfileView',
  components: { LoginPrompt, UserAvatar, ImagePicker, ConfirmModal },
  data() {
    return {
      state,
      profile: { name: '', email: '' },
      newPhoto: null, // File chosen in the form
      profileTried: false,
      profileErrors: {}, // field errors sent by the server
      profileError: '',
      password: { current: '', next: '' },
      passwordTried: false,
      passwordErrors: {},
      deleting: false, // the "are you sure" pop-up is open
      deletePassword: '',
      deleteError: '',
      busy: '', // 'profile' | 'password' | 'delete' : what the server is doing now
    }
  },
  watch: {
    // the user is known a moment after the page opens
    'state.user'(user, before) {
      if (user && !before) this.fillForm()
    },
  },
  created() {
    if (this.state.user) this.fillForm()
  },
  methods: {
    mediaUrl,
    formatDate,
    fillForm() {
      this.profile = { name: this.state.user.name, email: this.state.user.email }
    },

    // UPDATE profile (a form with a file)
    async saveProfile(event) {
      this.profileError = ''
      this.profileErrors = {}
      if (!event.target.checkValidity()) {
        this.profileTried = true
        return
      }
      this.busy = 'profile'
      try {
        const form = new FormData()
        form.append('name', this.profile.name)
        form.append('email', this.profile.email)
        if (this.newPhoto) form.append('photo', this.newPhoto)
        setUser((await api.updateProfile(form)).user)
        this.newPhoto = null
        this.profileTried = false
        showToast('Profile saved')
      } catch (error) {
        this.profileError = error.message
        this.profileErrors = error.fields
      } finally {
        this.busy = ''
      }
    },

    // UPDATE password
    async savePassword(event) {
      this.passwordErrors = {}
      if (!event.target.checkValidity()) {
        this.passwordTried = true
        return
      }
      this.busy = 'password'
      try {
        await api.changePassword(this.password.current, this.password.next)
        this.password = { current: '', next: '' }
        this.passwordTried = false
        showToast('Password changed')
      } catch (error) {
        this.passwordErrors = error.fields
        if (!Object.keys(error.fields).length) showToast(error.message)
      } finally {
        this.busy = ''
      }
    },

    // DELETE the account
    openDelete() {
      this.deletePassword = ''
      this.deleteError = ''
      this.deleting = true
    },
    async deleteAccount() {
      if (!this.deletePassword || this.busy) return
      this.busy = 'delete'
      try {
        await api.deleteAccount(this.deletePassword)
        this.deleting = false
        clearSession()
        showToast('Your account was deleted')
        this.$router.push({ name: 'home' })
      } catch (error) {
        this.deleteError = error.message
      } finally {
        this.busy = ''
      }
    },
  },
}
</script>
