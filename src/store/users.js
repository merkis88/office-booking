import { defineStore } from 'pinia';
import axios from 'axios';

export const useUsersStore = defineStore('users', {
  state: () => ({
    users: [],
    isLoading: false,
    error: null,

    currentPage: 1,
    perPage: 10,
    searchQuery: '',
    filters: {
      status: 'all',
    },
  }),

  getters: {
    filteredUsers(state) {
      let users = state.users;

      if (state.searchQuery) {
        users = users.filter((user) =>
          (user.last_name || '').toLowerCase().includes(state.searchQuery.toLowerCase()),
        );
      }

      if (state.filters.status === 'blocked') {
        users = users.filter((u) => u.is_blocked === true);
      }

      if (state.filters.status === 'active') {
        users = users.filter((u) => u.is_blocked === false);
      }

      return users;
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
      this.isLoading = true;
      this.error = null;

      try {
        const { data } = await axios.get('/api/admin/users');
        this.users = data.data ?? data;
        if (!Array.isArray(this.users)) this.users = [];
      } catch (error) {
        this.error = error.response?.data?.message || 'Ошибка загрузки пользователей';
        this.users = [];
      } finally {
        this.isLoading = false;
      }
    },

    setSearchQuery(query) {
      this.searchQuery = query;
      this.currentPage = 1;
    },

    setFilter(key, value) {
      this.filters[key] = value;
      this.currentPage = 1;
    },

    setPage(page) {
      this.currentPage = page;
    },

    async blockUserByEmail(email, reason = 'Нарушение правил') {
      const { data } = await axios.post('/api/admin/users/block', { email, reason });
      const updatedUser = data.data;
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
    },

    async unblockUserByEmail(email) {
      const { data } = await axios.post('/api/admin/users/unblock', { email });
      const updatedUser = data.data;
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
    },

    async toggleUserStatus(user) {
      if (!user) throw new Error('Пользователь не указан');
      if (!user.email) throw new Error('У пользователя нет email');

      return user.is_blocked
        ? await this.unblockUserByEmail(user.email)
        : await this.blockUserByEmail(user.email);
    },

    async updateUserStatus(user, reason = 'Администратор') {
      return this.toggleUserStatus(user, reason);
    },
  },
});
