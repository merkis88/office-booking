import { defineStore } from 'pinia';
import axios from 'axios';

export const useBookingsStore = defineStore('bookings', {
  state: () => ({
    bookings: [],
    currentPage: 1,
    perPage: 20,
    total: 0,
    lastPage: 1,
    isLoading: false,
    filters: {
      status: null,
      place_id: null,
      from: null,
      to: null,
      sort: '-start_time',
    },
  }),

  actions: {
    async fetchMyBookings(params = {}) {
      this.isLoading = true;

      try {
        const query = {
          page: this.currentPage,
          per_page: this.perPage,
          ...this.filters,
          ...params,
        };

        const { data } = await axios.get('/api/bookings/my', {
          params: query,
        });

        this.bookings = data.data;
        this.currentPage = data.current_page;
        this.perPage = data.per_page;
        this.total = data.total;
        this.lastPage = Math.ceil(data.total / data.per_page);
      } catch (error) {
        console.error('Ошибка загрузки бронирований:', error);
      } finally {
        this.isLoading = false;
      }
    },

    setPage(page) {
      this.currentPage = page;
      this.fetchMyBookings();
    },

    setFilter(filterKey, value) {
      this.filters[filterKey] = value;
      this.currentPage = 1;
      this.fetchMyBookings();
    },
  },
});
