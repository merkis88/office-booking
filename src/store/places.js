import { defineStore } from 'pinia';
import axios from 'axios';

export const usePlacesStore = defineStore('places', {
  state: () => ({
    places: [],
    isLoading: false,
    error: null,
    filters: null, // ✅ Сохраняем фильтры с backend
  }),

  actions: {
    async fetchPlaces(filters = {}) {
      this.isLoading = true;
      this.error = null;

      try {
        const params = {};

        // ✅ Тип помещения - обязательный параметр
        if (filters.type) {
          params.type = filters.type;
        }

        // ✅ Цена - только если указана пользователем
        if (filters.minPrice !== undefined && filters.minPrice !== null) {
          params.min_price = filters.minPrice;
        }

        if (filters.maxPrice !== undefined && filters.maxPrice !== null) {
          params.max_price = filters.maxPrice;
        }

        // ✅ Дата - только если выбрана пользователем
        // Если дата не указана, backend вернет помещения на сегодняшний день
        if (filters.date) {
          params.date = filters.date;
        }

        console.log('Запрос с параметрами:', params);

        const { data } = await axios.get('/api/places', { params });

        console.log('Места загружены:', data);

        // ✅ Сохраняем места и фильтры
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
