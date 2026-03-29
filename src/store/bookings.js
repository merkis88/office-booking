import { defineStore } from 'pinia';
import { useAuthStore } from './auth';
import axios from 'axios';

const ITEMS_PER_PAGE = 20;

export const useBookingsStore = defineStore('bookings', {
  state: () => ({
    bookings: [],
    currentPage: 1,
    perPage: ITEMS_PER_PAGE,
    total: 0,
    lastPage: 1,
    isLoading: false,
    filters: {
      status: null,
      place_id: null,
      user_id: null,
      from: null,
      to: null,
      sort: '-start_time',
      type: 'all',
    },
    error: null,
  }),

  getters: {
    filteredBookings(state) {
      let result = state.bookings;

      if (state.filters.type && state.filters.type !== 'all') {
        result = result.filter((b) => b.place?.type === state.filters.type);
      }

      return result;
    },

    totalPages() {
      return Math.ceil(this.filteredBookings.length / this.perPage);
    },

    paginatedBookings() {
      const start = (this.currentPage - 1) * this.perPage;
      return this.filteredBookings.slice(start, start + this.perPage);
    },
  },

  actions: {
    async fetchBookings({ admin = false, page = 1 } = {}) {
      const authStore = useAuthStore();
      this.isLoading = true;
      this.error = null;

      try {
        const query = {
          page,
          per_page: this.perPage,
          ...this.filters,
        };

        const params = Object.fromEntries(
          Object.entries(query).filter(([_, v]) => v !== null && v !== undefined && v !== ''),
        );

        let url = admin ? '/api/admin/bookings' : '/api/bookings/my';
        const headers = admin
          ? { Authorization: `Bearer ${authStore.token}`, Accept: 'application/json' }
          : {};

        const { data } = await axios.get(url, { params, headers });

        this.bookings = data.data || [];
        this.currentPage = data.current_page || 1;
        this.perPage = data.per_page || this.perPage;
        this.total = data.total || 0;
        this.lastPage = Math.ceil(this.total / this.perPage);
      } catch (error) {
        console.error('Ошибка загрузки бронирований:', error);
        this.error = error.response?.data?.message || error.message || 'Ошибка запроса';
      } finally {
        this.isLoading = false;
      }
    },

    async createBooking(payload) {
      this.isLoading = true;

      try {
        const { data } = await axios.post('/api/bookings', payload);

        this.bookings.unshift(data);

        return data;
      } finally {
        this.isLoading = false;
      }
    },

    setPage(page, admin = false) {
      if (page >= 1 && page <= this.lastPage) {
        this.currentPage = page;
        this.fetchBookings({ admin, page });
      }
    },

    setFilter(filterKey, value, admin = false) {
      this.filters[filterKey] = value;
      this.currentPage = 1;
      this.fetchBookings({ admin });
    },

    resetFilters(admin = false) {
      this.filters = {
        status: null,
        place_id: null,
        user_id: null,
        from: null,
        to: null,
        sort: '-start_time',
        type: 'all',
      };
      this.currentPage = 1;
      this.fetchBookings({ admin });
    },

    async exportBookings() {
      const authStore = useAuthStore();

      try {
        const params = new URLSearchParams(
          Object.entries(this.filters).filter(
            ([_, v]) => v !== null && v !== undefined && v !== '',
          ),
        );

        const res = await fetch(`/api/admin/bookings/export?${params}`, {
          headers: {
            Authorization: `Bearer ${authStore.token}`,
            Accept: 'text/csv',
          },
        });

        const blob = await res.blob();
        const url = window.URL.createObjectURL(blob);

        const a = document.createElement('a');
        a.href = url;
        a.download = `bookings_${new Date().toISOString()}.csv`;
        document.body.appendChild(a);
        a.click();
        a.remove();
        window.URL.revokeObjectURL(url);
      } catch (error) {
        console.error('Ошибка экспорта бронирований:', error);
      }
    },
  },
});
