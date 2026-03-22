import { defineStore } from 'pinia';
import { useAuthStore } from './auth';

export const useAdminBookingsStore = defineStore('adminBookings', {
  state: () => ({
    bookings: [],
    currentPage: 1,
    lastPage: 1,
    perPage: 20,
    total: 0,
    isLoading: false,

    filters: {
      status: null,
      place_id: null,
      user_id: null,
      created_by: null,
      from: null,
      to: null,
      sort: '-start_time',
    },
  }),

  actions: {
    async fetchBookings(page = 1) {
      const authStore = useAuthStore();

      this.isLoading = true;

      try {
        const rawParams = {
          page,
          per_page: this.perPage,
          ...this.filters,
        };

        const filteredParams = Object.fromEntries(
          Object.entries(rawParams).filter(([_, v]) => v !== null && v !== undefined && v !== ''),
        );

        const params = new URLSearchParams(filteredParams);

        const res = await fetch(`/api/admin/bookings?${params}`, {
          headers: {
            Authorization: `Bearer ${authStore.token}`,
            Accept: 'application/json',
          },
        });

        const data = await res.json();

        this.bookings = data.data;
        this.currentPage = data.current_page;
        this.perPage = data.per_page;
        this.total = data.total;
        this.lastPage = Math.ceil(data.total / data.per_page);
      } catch (e) {
        console.error(e);
      } finally {
        this.isLoading = false;
      }
    },

    setPage(page) {
      this.fetchBookings(page);
    },
  },
});
