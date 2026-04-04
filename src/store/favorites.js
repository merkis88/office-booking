import { defineStore } from 'pinia';
import axios from 'axios';

export const useFavoritesStore = defineStore('favorites', {
  state: () => ({
    favoriteIds: [],
    favorites: [],
    isLoading: false,
    error: null,
  }),

  getters: {
    isFavorite: (state) => (placeId) => state.favoriteIds.includes(placeId),
  },

  actions: {
    async addFavorite(placeId) {
      if (!this.favoriteIds.includes(placeId)) {
        this.favoriteIds.push(placeId);
      }
      try {
        await axios.post(`/api/places/${placeId}/store-favorite`);
      } catch (error) {
        this.favoriteIds = this.favoriteIds.filter((id) => id !== placeId);
        throw error;
      }
    },

    async removeFavorite(placeId) {
      const prevIds = [...this.favoriteIds];
      const prevFavorites = [...this.favorites];

      this.favoriteIds = this.favoriteIds.filter((id) => id !== placeId);
      this.favorites = this.favorites.filter((p) => p.id !== placeId);

      try {
        await axios.delete(`/api/places/${placeId}/remove-favorite`);
      } catch (error) {
        this.favoriteIds = prevIds;
        this.favorites = prevFavorites;
        throw error;
      }
    },

    async toggleFavorite(placeId) {
      if (this.isFavorite(placeId)) {
        await this.removeFavorite(placeId);
      } else {
        await this.addFavorite(placeId);
      }
    },

    async fetchFavorites() {
      this.isLoading = true;
      this.error = null;

      try {
        const { data } = await axios.get('/api/places/favorites');
        const places = data.data ?? data;

        const base = axios.defaults.baseURL || '';

        this.favorites = (Array.isArray(places) ? places : []).map((p) => {
          if (!p.photo_url && p.photo) {
            p.photo_url = `${base}/storage/${p.photo}`;
          }
          return p;
        });

        this.favoriteIds = this.favorites.map((p) => p.id);
      } catch (error) {
        this.error = error.response?.data?.message || 'Ошибка загрузки избранного';
      } finally {
        this.isLoading = false;
      }
    },

    setFavorites(placeIds) {
      this.favoriteIds = placeIds;
    },
  },
});
