import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// ---------------------------------------------------------------------
// Where is the PHP back end?  (WAMP must be running)
// The project folder "bayern-vue" must be inside  C:\wamp64\www\
// then the back end answers at  http://localhost/bayern-vue/backend/
// Change these two lines if your folder has another name.
// ---------------------------------------------------------------------
const WAMP_URL = 'http://localhost'
const BACKEND_PATH = '/bayern-vue/backend'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      // "@/..." always points to the src folder
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
  server: {
    proxy: {
      // the website calls /api/login.phtml  ->  Vite forwards it to WAMP
      '/api': {
        target: WAMP_URL,
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, BACKEND_PATH),
      },
    },
  },
})
