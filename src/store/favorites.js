import { defineStore } from 'pinia';
import axios from 'axios';

export const useFavoritesStore = defineStore('favorites', {
  state: () => ({
    favoriteIds: [],
    favorites: [],
    isLoading: false,
  }),

  getters: {
    isFavorite: (state) => (placeId) => state.favoriteIds.includes(placeId),
  },

  actions: {
    async addFavorite(placeId) {
      try {
        await axios.post(`/api/places/${placeId}/store-favorite`);
        if (!this.favoriteIds.includes(placeId)) {
          this.favoriteIds.push(placeId);
        }
      } catch (error) {
        console.error('Ошибка добавления в избранное:', error);
        throw error;
      }
    },

    async removeFavorite(placeId) {
      try {
        await axios.delete(`/api/places/${placeId}/delete-favorite`);
        this.favoriteIds = this.favoriteIds.filter((id) => id !== placeId);
        this.favorites = this.favorites.filter((p) => p.id !== placeId);
      } catch (error) {
        console.error('Ошибка удаления из избранного:', error);
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
      try {
        const { data } = await axios.get('/api/profile');
        this.favorites = data.data?.favorite_places || [];
        this.favoriteIds = this.favorites.map((p) => p.id);
      } catch (error) {
        console.error('Ошибка загрузки избранного:', error);
      } finally {
        this.isLoading = false;
      }
    },

    setFavorites(placeIds) {
      this.favoriteIds = placeIds;
    },
  },
});
