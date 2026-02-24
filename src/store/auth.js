import { defineStore } from 'pinia';
import axios from 'axios';

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    token: localStorage.getItem('token') || null,
  }),

  getters: {
    isAuthenticated: (state) => !!state.token,
    getCurrentUser: (state) => state.user,
  },

  actions: {
    setAuth(token, user) {
      this.token = token;
      this.user = user;
      localStorage.setItem('token', token);
      axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
    },

    async login(email, password) {
      const { data } = await axios.post('/api/login', { email, password });
      this.setAuth(data.token, data.user);
    },

    async register(registrationData) {
      const { data } = await axios.post('/api/register', registrationData);

      this.setAuth(data.token, data.user);
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
