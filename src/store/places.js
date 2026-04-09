import { defineStore } from 'pinia';
import axios from 'axios';

const ITEMS_PER_PAGE = 4;

export const PLACE_TYPE_LABELS = {
  office: 'Офис',
  coworking: 'Коворкинг',
  meeting: 'Переговорная',
};

export const PLACE_TYPE_TITLES = {
  office: 'Офисы',
  coworking: 'Коворкинги',
  meeting: 'Переговорные комнаты',
};

export const getPlaceTypeLabel = (type) => PLACE_TYPE_LABELS[type] || type;

export const getPlaceTypeTitle = (type) => PLACE_TYPE_TITLES[type] || type;

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

      return places
        .map((place) => {
          const slots = place.available_slots || [];
          const filteredSlots = slots.filter((slot) => slot.start >= nextHour);

          return {
            ...place,
            available_slots: filteredSlots,
          };
        })
        .filter((place) => place.available_slots.length > 0);
    },

    async fetchPlaces(filters = {}) {
      this.isLoading = true;
      this.error = null;

      try {
        const params = {};
        if (filters.type) params.type = filters.type;
        if (filters.minPrice != null) params.min_price = filters.minPrice;
        if (filters.maxPrice != null) params.max_price = filters.maxPrice;
        if (filters.date) params.date = filters.date;

        const { data } = await axios.get('/api/places', { params });
        let placesData = data.data ?? data;

        if (filters.date) {
          placesData = this.filterSlotsByCurrentTime(placesData, filters.date);
        }

        this.places = placesData;
        this.filters = data.filters || null;
      } catch (error) {
        this.error = error.response?.data?.message || 'Не удалось загрузить помещения';
        this.places = [];
      } finally {
        this.isLoading = false;
      }
    },

    async fetchPlace(placeId) {
      this.isLoading = true;
      this.error = null;

      try {
        const { data } = await axios.get(`/api/places/${placeId}`);
        return data.data ?? data;
      } catch (error) {
        this.error = error.response?.data?.message || 'Не удалось загрузить помещение';
        throw error;
      } finally {
        this.isLoading = false;
      }
    },

    async deletePlace(placeId) {
      await axios.delete(`/api/admin/places/${placeId}`);
      this.places = this.places.filter((p) => p.id !== placeId);
      if (this.paginatedPlaces.length === 0 && this.currentPage > 1) this.currentPage--;
    },

    async createPlace(placeData) {
      const formData = new FormData();
      Object.entries(placeData).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          formData.append(key, typeof value === 'boolean' ? (value ? 1 : 0) : value);
        }
      });

      const { data } = await axios.post('/api/admin/places', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      });

      const newPlace = data.data ?? data;
      this.places.push(newPlace);
      return newPlace;
    },

    async updatePlace(placeId, updatedData) {
      const formData = new FormData();
      formData.append('_method', 'PUT');
      Object.entries(updatedData).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          formData.append(key, typeof value === 'boolean' ? (value ? 1 : 0) : value);
        }
      });

      const { data } = await axios.post(`/api/admin/places/${placeId}`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      });

      const updated = data.data ?? data;
      const index = this.places.findIndex((p) => p.id === Number(placeId));
      if (index !== -1) this.places[index] = updated;
      return updated;
    },

    async archivePlace(placeId, force = false) {
      try {
        const url = force
          ? `/api/admin/places/${placeId}/archive?force=1`
          : `/api/admin/places/${placeId}/archive`;

        await axios.post(url);

        this.places = this.places.filter((place) => place.id !== placeId);

        return { success: true };
      } catch (error) {
        console.error('Ошибка архивации помещения:', error);

        if (error.response?.status === 422) {
          return {
            success: false,
            hasBookings: true,
            error: error.response?.data?.message || 'У помещения есть активные бронирования',
          };
        }

        if (error.response?.status === 409 || error.response?.data?.has_bookings) {
          return {
            success: false,
            hasBookings: true,
            error: error.response?.data?.message || 'У помещения есть активные бронирования',
          };
        }

        return {
          success: false,
          hasBookings: false,
          error: error.response?.data?.message || 'Не удалось архивировать помещение',
        };
      }
    },

    async restorePlace(placeId) {
      const { data } = await axios.post(`/api/admin/places/${placeId}/restore`);
      this.places = this.places.filter((p) => p.id !== placeId);
      return data.data ?? data;
    },

    async fetchArchivedPlaces() {
      this.isLoading = true;
      this.error = null;

      try {
        const { data } = await axios.get('/api/admin/places', { params: { archived: 1 } });
        this.places = data.data ?? data;
      } catch (error) {
        this.error = error.response?.data?.message || 'Не удалось загрузить архивные помещения';
        this.places = [];
      } finally {
        this.isLoading = false;
      }
    },
  },
});
