import { defineStore } from 'pinia';
import axios from 'axios';

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: JSON.parse(localStorage.getItem('user')) || null,
    token: localStorage.getItem('token') || null,
    pendingVerificationEmail: null,
    roleID: JSON.parse(localStorage.getItem('role_id')) || null,
  }),

  getters: {
    isAuthenticated: (state) => !!state.token && !!state.user,
    isAdmin: (state) => state.user?.role_id === 1,
    getCurrentUser: (state) => state.user,
    needsEmailVerification: (state) => !!state.pendingVerificationEmail,
  },

  actions: {
    setAuth(token, user) {
      this.token = token;
      this.user = user;
      this.pendingVerificationEmail = null;

      localStorage.setItem('token', token);
      localStorage.setItem('user', JSON.stringify(user));

      axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
    },

    async init() {
      if (this.token) {
        axios.defaults.headers.common['Authorization'] = `Bearer ${this.token}`;

        if (!this.user) {
          await this.fetchCurrentUser();
        }
      }
    },

    async fetchCurrentUser() {
      if (!this.token) return;

      try {
        const { data } = await axios.get('/api/user');
        this.user = data.user || data;
        localStorage.setItem('user', JSON.stringify(this.user));
      } catch (error) {
        this.logout();
      }
    },

    async login(email, password) {
      const { data } = await axios.post('/api/login', { email, password });
      this.setAuth(data.token, data.user);
    },

    async register(registrationData) {
      const { data } = await axios.post('/api/register', registrationData);

      this.pendingVerificationEmail = registrationData.email;
      this.user = data.user;
      localStorage.setItem('user', JSON.stringify(data.user));

      return data;
    },

    async verifyEmail(email, code) {
      const { data } = await axios.post('/api/verify-email', {
        email,
        code,
      });

      if (data.success && data.token) {
        this.setAuth(data.token, data.user);
      }

      return data;
    },

    async resendVerificationCode(email) {
      const { data } = await axios.post('/api/resend-verification', { email });
      return data;
    },

    async forgotPassword(email) {
      const { data } = await axios.post('/api/forgot-password', { email });
      return data;
    },

    async fetchProfile() {
      if (!this.token) return;

      try {
        const { data } = await axios.get('/api/profile/');
        const profileData = data.data ?? data;
        this.user = { ...this.user, ...profileData };
        localStorage.setItem('user', JSON.stringify(this.user));
      } catch (error) {
        this.error = error.response?.data?.message || 'Ошибка загрузки профиля';
      }
    },

    async updateProfile(profileData) {
      const { data } = await axios.patch('/api/profile', profileData);
      const updatedData = data.data ?? data;
      this.user = { ...this.user, ...updatedData };
      localStorage.setItem('user', JSON.stringify(this.user));
      return this.user;
    },

    async uploadProfilePhoto(file) {
      const formData = new FormData();
      formData.append('photo', file);

      const response = await axios.post('/api/profile/photo', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });

      this.user = {
        ...this.user,
        ...response.data.data,
      };

      return response.data.data;
    },

    async changePassword(currentPassword, newPassword, passwordConfirmation) {
      const { data } = await axios.put('/api/user/password', {
        current_password: currentPassword,
        password: newPassword,
        password_confirmation: passwordConfirmation,
      });
      return data;
    },

    clearAuth() {
      this.token = null;
      this.user = null;
      this.pendingVerificationEmail = null;

      localStorage.removeItem('token');
      localStorage.removeItem('user');

      delete axios.defaults.headers.common['Authorization'];
    },

    async logout() {
      try {
        await axios.post('/api/logout');
      } catch (e) {
        // Ignore logout errors
      } finally {
        this.clearAuth();
      }
    },

    async deleteAccount(password) {
      await axios.delete('/api/profile', {
        data: { password },
      });
      this.clearAuth();
    },
  },
});
