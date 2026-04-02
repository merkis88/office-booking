import { defineStore } from 'pinia';
import axios from 'axios';

const ITEMS_PER_PAGE = 4;

export const usePlacesStore = defineStore('places', {
  state: () => ({
    places: [],
    isLoading: false,
    error: null,
    filters: null,
    searchQuery: '',
    selectedFilter: 'all',
    currentPage: 1,
  }),

  getters: {
    filteredPlaces(state) {
      let result = state.places;

      if (state.selectedFilter !== 'all') {
        result = result.filter((place) => place.type === state.selectedFilter);
      }

      if (state.searchQuery.trim()) {
        const query = state.searchQuery.toLowerCase();
        result = result.filter(
          (place) =>
            (place.name && place.name.toLowerCase().includes(query)) ||
            (place.number_place && place.number_place.toString().includes(query)),
        );
      }

      return result;
    },

    totalPages() {
      return Math.ceil(this.filteredPlaces.length / ITEMS_PER_PAGE);
    },

    paginatedPlaces() {
      const start = (this.currentPage - 1) * ITEMS_PER_PAGE;
      return this.filteredPlaces.slice(start, start + ITEMS_PER_PAGE);
    },
  },

  actions: {
    setSearchQuery(query) {
      this.searchQuery = query;
      this.currentPage = 1;
    },

    setFilter(filterType) {
      this.selectedFilter = filterType;
      this.currentPage = 1;
    },

    goToPage(page) {
      if (page >= 1 && page <= this.totalPages) {
        this.currentPage = page;
      }
    },

    isToday(dateString) {
      const today = new Date();
      const yyyy = today.getFullYear();
      const mm = String(today.getMonth() + 1).padStart(2, '0');
      const dd = String(today.getDate()).padStart(2, '0');
      return dateString === `${yyyy}-${mm}-${dd}`;
    },

    getNextHour() {
      const now = new Date();
      now.setMinutes(0, 0, 0);
      now.setHours(now.getHours() + 1);
      return `${String(now.getHours()).padStart(2, '0')}:00`;
    },

    filterSlotsByCurrentTime(places, selectedDate) {
      if (!selectedDate || !this.isToday(selectedDate)) {
        return places;
      }

      const nextHour = this.getNextHour();

      return places.map((place) => {
        const slots = place.available_slots || [];
        const filteredSlots = slots.filter((slot) => slot.start >= nextHour);
        return {
          ...place,
          available_slots: filteredSlots,
        };
      });
    },

    async fetchPlaces(filters = {}) {
      this.isLoading = true;
      this.error = null;

      try {
        const params = {};
        if (filters.type) params.type = filters.type;
        if (filters.minPrice !== undefined && filters.minPrice !== null)
          params.min_price = filters.minPrice;
        if (filters.maxPrice !== undefined && filters.maxPrice !== null)
          params.max_price = filters.maxPrice;
        if (filters.date) params.date = filters.date;

        const { data } = await axios.get('/api/places', { params });
        let placesData = data.data || data;

        if (filters.date) {
          placesData = this.filterSlotsByCurrentTime(placesData, filters.date);
        }

        this.places = placesData;
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

    async deletePlace(placeId) {
      try {
        await axios.delete(`/api/admin/places/${placeId}`);
        this.places = this.places.filter((p) => p.id !== placeId);
        if (this.paginatedPlaces.length === 0 && this.currentPage > 1) this.currentPage--;
        return { success: true };
      } catch (error) {
        console.error('Ошибка удаления помещения:', error);
        return { success: false, error: 'Не удалось удалить помещение' };
      }
    },

    async createPlace(placeData) {
      this.isLoading = true;
      this.error = null;
      try {
        const formData = new FormData();
        Object.entries(placeData).forEach(([key, value]) => {
          if (value !== undefined && value !== null) formData.append(key, value);
        });

        const { data } = await axios.post('/api/admin/places', formData, {
          headers: { 'Content-Type': 'multipart/form-data' },
        });

        const newPlace = data.data || data;
        this.places.push(newPlace);
        return { success: true, data: newPlace };
      } catch (error) {
        console.error('Ошибка создания помещения:', error);
        const message = error.response?.data?.message || 'Не удалось создать помещение';
        this.error = message;
        return { success: false, error: message };
      } finally {
        this.isLoading = false;
      }
    },

    async updatePlace(placeId, updatedData) {
      this.isLoading = true;
      this.error = null;
      try {
        const formData = new FormData();
        formData.append('_method', 'PUT');
        Object.entries(updatedData).forEach(([key, value]) => {
          if (value !== undefined && value !== null) formData.append(key, value);
        });

        const { data } = await axios.post(`/api/admin/places/${placeId}`, formData, {
          headers: { 'Content-Type': 'multipart/form-data' },
        });

        const index = this.places.findIndex((p) => p.id === Number(placeId));
        if (index !== -1) this.places[index] = data.data || data;
        return { success: true, data: data.data || data };
      } catch (error) {
        const message = error.response?.data?.message || 'Ошибка обновления';
        this.error = message;
        return { success: false, error: message };
      } finally {
        this.isLoading = false;
      }
    },

    async archivePlace(placeId) {
      this.isLoading = true;
      this.error = null;
      try {
        const { data } = await axios.post(`/api/admin/places/${placeId}/archive`);
        this.places = this.places.filter((p) => p.id !== placeId);
        return { success: true, data };
      } catch (error) {
        const message = error.response?.data?.message || 'Не удалось архивировать помещение';
        this.error = message;
        return { success: false, error: message };
      } finally {
        this.isLoading = false;
      }
    },

    async restorePlace(placeId) {
      this.isLoading = true;
      this.error = null;
      try {
        const { data } = await axios.post(`/api/admin/places/${placeId}/restore`);
        this.places = this.places.filter((p) => p.id !== placeId);
        return { success: true, data };
      } catch (error) {
        const message = error.response?.data?.message || 'Не удалось восстановить помещение';
        this.error = message;
        return { success: false, error: message };
      } finally {
        this.isLoading = false;
      }
    },

    async fetchArchivedPlaces() {
      this.isLoading = true;
      this.error = null;
      try {
        const { data } = await axios.get('/api/admin/places', { params: { archived: 1 } });
        this.places = data.data || data;
        return { success: true, data: this.places };
      } catch (error) {
        console.error('Ошибка загрузки архивных помещений:', error);
        this.error = 'Не удалось загрузить архивные помещения';
        this.places = [];
        return { success: false, error: this.error };
      } finally {
        this.isLoading = false;
      }
    },
  },
});
