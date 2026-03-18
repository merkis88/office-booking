import { defineStore } from 'pinia';
import axios from 'axios';

export const usePlacesStore = defineStore('places', {
  state: () => ({
    places: [],
    isLoading: false,
    error: null,
    filters: null,
  }),

  actions: {
    async fetchPlaces(filters = {}) {
      this.isLoading = true;
      this.error = null;

      try {
        const params = {};

        if (filters.type) {
          params.type = filters.type;
        }

        if (filters.minPrice !== undefined && filters.minPrice !== null) {
          params.min_price = filters.minPrice;
        }

        if (filters.maxPrice !== undefined && filters.maxPrice !== null) {
          params.max_price = filters.maxPrice;
        }

        if (filters.date) {
          params.date = filters.date;
        }

        const { data } = await axios.get('/api/places', { params });

        this.places = data.data || data;
        this.filters = data.filters || null;

        return { success: true, data: this.places };
      } catch (error) {
        console.error('Ошибка загрузки мест:', error);
        this.error = 'Не удалось загрузить места';
        this.places = [];
        return { success: false, error: this.error };
      } finally {
        this.isLoading = false;
      }
    },


  },
});
