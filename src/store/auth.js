import { defineStore } from 'pinia';
import axios from 'axios';

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: JSON.parse(localStorage.getItem('user')) || null,
    token: localStorage.getItem('token') || null,
    pendingVerificationEmail: null,
  }),

  getters: {
    isAuthenticated: (state) => !!state.token && !!state.user,
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
        console.error('Ошибка загрузки пользователя:', error);
        this.logout();
      }
    },

    async login(email, password) {
      const { data } = await axios.post('/api/login', { email, password });
      this.setAuth(data.token, data.user);
    },

    async register(registrationData) {
      try {
        const { data } = await axios.post('/api/register', registrationData);

        console.log('Ответ от сервера:', data);

        this.pendingVerificationEmail = registrationData.email;
        this.user = data.user;
        localStorage.setItem('user', JSON.stringify(data.user));

        return {
          success: true,
          requires_verification: true,
          user: data.user,
          message: data.message,
        };
      } catch (error) {
        console.error('Ошибка в authStore.register:', error);
        throw error;
      }
    },

    async verifyEmail(email, code) {
      try {
        const { data } = await axios.post('/api/verify-email', {
          email,
          code,
        });

        if (data.success && data.token) {
          this.setAuth(data.token, data.user);
        }

        return data;
      } catch (error) {
        console.error('Ошибка верификации:', error);
        throw error;
      }
    },

    async resendVerificationCode(email) {
      try {
        const { data } = await axios.post('/api/resend-verification', { email });
        return data;
      } catch (error) {
        console.error('Ошибка повторной отправки:', error);
        throw error;
      }
    },

    async forgotPassword(email) {
      try {
        const { data } = await axios.post('/api/forgot-password', { email });
        return data;
      } catch (error) {
        console.error('Ошибка отправки временного пароля:', error);
        throw error;
      }
    },

    async changePassword(currentPassword, newPassword, passwordConfirmation) {
      try {
        const { data } = await axios.put('/api/user/password', {
          current_password: currentPassword,
          password: newPassword,
          password_confirmation: passwordConfirmation,
        });
        return data;
      } catch (error) {
        console.error('Ошибка смены пароля:', error);
        throw error;
      }
    },

    async logout() {
      try {
        await axios.post('/api/logout');
      } catch (e) {
        console.error('Ошибка при выходе:', e);
      } finally {
        this.token = null;
        this.user = null;
        this.pendingVerificationEmail = null;

        localStorage.removeItem('token');
        localStorage.removeItem('user');

        delete axios.defaults.headers.common['Authorization'];
      }
    },
  },
});
