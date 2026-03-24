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

        async deletePlace(placeId) {
            try {
                await axios.delete(`/api/admin/places/${placeId}`);
                const index = this.places.findIndex((p) => p.id === placeId);
                if (index !== -1) {
                    this.places.splice(index, 1);
                }
                if (this.paginatedPlaces.length === 0 && this.currentPage > 1) {
                    this.currentPage--;
                }
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
                formData.append('name', placeData.name);
                formData.append('type', placeData.type);
                formData.append('capacity', placeData.capacity);
                formData.append('number_place', placeData.number_place);
                formData.append('price', placeData.price);
                formData.append('description', placeData.description);

                if (placeData.photo) {
                    formData.append('photo', placeData.photo);
                }

                const { data } = await axios.post('/api/admin/places', formData, {
                    headers: { 'Content-Type': 'multipart/form-data' },
                });

                const newPlace = data.data || data;
                this.places.push(newPlace);

                return { success: true, data: newPlace };
            } catch (error) {
                console.error('Ошибка создания помещения:', error);
                const serverErrors = error.response?.data?.errors || null;
                const message = error.response?.data?.message || 'Не удалось создать помещение';
                this.error = message;
                return { success: false, error: message, errors: serverErrors };
            } finally {
                this.isLoading = false;
            }
        },

        async fetchPlace(placeId) {
            this.isLoading = true;
            this.error = null;

            try {
                const { data } = await axios.get(`/api/places/${placeId}`);
                return { success: true, data: data.data || data };
            } catch (error) {
                console.error('Ошибка загрузки помещения:', error);
                const message = error.response?.data?.message || 'Не удалось загрузить помещение';
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

                Object.keys(updatedData).forEach((key) => {
                    if (key === 'photo') {
                        // skip - добавим ниже
                    } else {
                        formData.append(key, updatedData[key]);
                    }
                });

                if (updatedData.photo) {
                    formData.append('photo', updatedData.photo);
                }

                const { data } = await axios.post(`/api/admin/places/${placeId}`, formData, {
                    headers: { 'Content-Type': 'multipart/form-data' },
                });

                const index = this.places.findIndex((p) => p.id === Number(placeId));
                if (index !== -1) {
                    this.places[index] = data.data || data;
                }

                return { success: true, data: data.data || data };
            } catch (error) {
                const errors = error.response?.data?.errors || {};
                const message = error.response?.data?.message || 'Ошибка обновления';
                this.error = message;
                return { success: false, error: message, errors };
            } finally {
                this.isLoading = false;
            }
        },

        // ✅ НОВЫЙ метод - загрузка архивных помещений
        async fetchArchivedPlaces() {
            this.isLoading = true;
            this.error = null;

            try {
                const { data } = await axios.get('/api/admin/places', {
                    params: { archived: 1 },
                });

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
