import { defineStore } from 'pinia';
import axios from 'axios';

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    token: localStorage.getItem('token') || null,
  }),

  getters: {
    isAuthenticated: (state) => !!state.token,
  },

  actions: {
    async login(email, password) {
      const { data } = await axios.post('/api/login', { email, password });

      this.token = data.token;
      this.user = data.user;
      localStorage.setItem('token', data.token);

      axios.defaults.headers.common['Authorization'] = `Bearer ${data.token}`;
    },

    async logout() {
      try {
        await axios.post('/api/logout');
      } catch (e) {
      } finally {
        this.token = null;
        this.user = null;
        localStorage.removeItem('token');
        delete axios.defaults.headers.common['Authorization'];
      }
    },
  },
});
