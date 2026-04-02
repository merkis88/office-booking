import { defineStore } from 'pinia';
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
    searchQuery: '',
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

      if (state.searchQuery.trim()) {
        const query = state.searchQuery.toLowerCase();

        result = result.filter((b) => b.user?.last_name?.toLowerCase().includes(query));
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
    setSearchQuery(query) {
      this.searchQuery = query;
      this.currentPage = 1;
    },

    async fetchBookings({ admin = false, page = 1 } = {}) {
      this.isLoading = true;
      this.error = null;

      try {
        const params = Object.fromEntries(
          Object.entries({ page, per_page: this.perPage, ...this.filters })
            .filter(([_, v]) => v != null && v !== ''),
        );

        const url = admin ? '/api/admin/bookings' : '/api/bookings/my';
        const { data } = await axios.get(url, { params });

        this.bookings = data.data || [];
        this.currentPage = data.current_page || 1;
        this.total = data.total || 0;
        this.lastPage = Math.ceil(this.total / this.perPage);
      } catch (error) {
        this.error = error.response?.data?.message || 'Ошибка загрузки бронирований';
      } finally {
        this.isLoading = false;
      }
    },

    async createBooking(payload) {
      const { data } = await axios.post('/api/bookings', payload);
      const booking = data.data ?? data;
      this.bookings.unshift(booking);
      return booking;
    },

    async cancelBooking(bookingId) {
      const { data } = await axios.post(`/api/bookings/${bookingId}/cancel`);
      const index = this.bookings.findIndex(b => b.id === bookingId);
      if (index !== -1) {
        this.bookings[index] = data.data;
      }
      return data.data;
    },

    async rescheduleBooking(bookingId, { start_time, end_time }) {
      const { data } = await axios.post(`/api/bookings/${bookingId}/reschedule`, {
        start_time,
        end_time,
      });
      const index = this.bookings.findIndex(b => b.id === bookingId);
      if (index !== -1) {
        this.bookings[index] = data.data;
      }
      return data.data;
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
      try {
        const params = new URLSearchParams(
          Object.entries(this.filters).filter(
            ([_, v]) => v !== null && v !== undefined && v !== '',
          ),
        );

        const res = await fetch(`/api/admin/bookings/export?${params}`, {
          headers: {
            Authorization: axios.defaults.headers.common['Authorization'],
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
        this.error = error.message || 'Ошибка экспорта бронирований';
      }
    },
  },
});
