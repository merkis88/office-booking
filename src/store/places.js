import { defineStore } from 'pinia';
import axios from 'axios';

export const usePlacesStore = defineStore('places', {
  state: () => ({
    places: [],
    isLoading: false,
    error: null,
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

        console.log('Запрос с параметрами:', params);

        const { data } = await axios.get('/api/places', { params });

        console.log('Места загружены:', data);

        this.places = data.data || data;
      } catch (error) {
        console.error('Ошибка загрузки мест:', error);
        this.error = 'Не удалось загрузить места';
        this.places = [];
      } finally {
        this.isLoading = false;
      }
    },

    async fetchPlace(id) {
      try {
        const { data } = await axios.get(`/api/places/${id}`);
        return data.data || data;
      } catch (error) {
        console.error('Ошибка загрузки места:', error);
        throw error;
      }
    },
  },
});
