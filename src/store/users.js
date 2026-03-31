import { defineStore } from 'pinia';
import axios from 'axios';
import { useAuthStore } from './auth';

export const useUsersStore = defineStore('users', {
  state: () => ({
    users: [],
    loading: false,

    currentPage: 1,
    perPage: 10,
    searchQuery: '',
    filters: {
      status: 'all',
    },
  }),

  getters: {
    filteredUsers(state) {
      if (!state.searchQuery) return state.users;

      return state.users.filter((user) =>
        (user.last_name || '').toLowerCase().includes(state.searchQuery.toLowerCase()),
      );
    },

    paginatedUsers(state) {
      const start = (state.currentPage - 1) * state.perPage;
      return this.filteredUsers.slice(start, start + state.perPage);
    },

    totalPages(state) {
      return Math.max(1, Math.ceil(this.filteredUsers.length / state.perPage));
    },
  },

  actions: {
    async fetchUsers() {
      this.loading = true;

      try {
        const authStore = useAuthStore();

        const response = await axios.get('/api/admin/users', {
          headers: { Authorization: `Bearer ${authStore.token}` },
        });

        this.users = Array.isArray(response.data.data) ? response.data.data : [];
      } catch (error) {
        console.error('Ошибка получения пользователей:', error);
        this.users = [];
      } finally {
        this.loading = false;
      }
    },

    setSearchQuery(query) {
      this.searchQuery = query;
      this.currentPage = 1;
    },

    setFilter(type, value) {
      this.filters[type] = value;
      this.currentPage = 1;
    },

    setPage(page) {
      this.currentPage = page;
    },

    async blockUserByEmail(email, reason = 'Нарушение правил') {
      try {
        const authStore = useAuthStore();

        const response = await axios.post(
          '/api/admin/users/block',
          { email, reason },
          { headers: { Authorization: `Bearer ${authStore.token}` } },
        );

        const updatedUser = response.data.data;

        if (updatedUser) {
          const index = this.users.findIndex((u) => u.email === email);

          if (index !== -1) {
            this.users[index] = {
              ...this.users[index],
              ...updatedUser,
              is_blocked: true,
            };
          }
        }

        return updatedUser;
      } catch (error) {
        if (error.response?.status === 422) {
          const message =
            error.response.data?.message || 'Пользователь уже заблокирован или ошибка запроса';

          console.warn('Block warning:', message);
          throw new Error(message);
        }

        console.error('Ошибка блокировки пользователя:', error);
        throw error;
      }
    },

    async unblockUserByEmail(email) {
      try {
        const authStore = useAuthStore();

        const response = await axios.post(
          '/api/admin/users/unblock',
          { email },
          { headers: { Authorization: `Bearer ${authStore.token}` } },
        );

        const updatedUser = response.data.data;

        if (updatedUser) {
          const index = this.users.findIndex((u) => u.email === email);

          if (index !== -1) {
            this.users[index] = {
              ...this.users[index],
              ...updatedUser,
              is_blocked: false,
            };
          }
        }

        return updatedUser;
      } catch (error) {
        if (error.response?.status === 422) {
          const message =
            error.response.data?.message || 'Пользователь не был заблокирован или ошибка запроса';

          console.warn('Unblock warning:', message);
          throw new Error(message);
        }

        console.error('Ошибка разблокировки пользователя:', error);
        throw error;
      }
    },

    async toggleUserStatus(user) {
      if (!user) throw new Error('Пользователь не указан');

      if (!user.email) throw new Error('У пользователя нет email');

      try {
        return user.is_blocked
          ? await this.unblockUserByEmail(user.email)
          : await this.blockUserByEmail(user.email);
      } catch (error) {
        throw error;
      }
    },

    async updateUserStatus(user, reason = 'Администратор') {
      return this.toggleUserStatus(user, reason);
    },
  },
});
