import { defineStore } from 'pinia';
import axios from 'axios';

export const useReviewsStore = defineStore('reviews', {
  state: () => ({
    reviews: [],
    isLoading: false,
    error: null,
    currentPage: 1,
    totalPages: 1,
    filterRating: null,
  }),

  getters: {
    filteredReviews: (state) => {
      const reviewsArray = Array.isArray(state.reviews) ? state.reviews : [];

      if (state.filterRating === null) {
        return reviewsArray;
      }

      return reviewsArray.filter((review) => review.rating === state.filterRating);
    },

    reviewsByRating: (state) => {
      const counts = { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 };
      const reviewsArray = Array.isArray(state.reviews) ? state.reviews : [];

      reviewsArray.forEach((review) => {
        if (counts[review.rating] !== undefined) {
          counts[review.rating]++;
        }
      });
      return counts;
    },
  },

  actions: {
    async fetchReviews() {
      this.isLoading = true;
      this.error = null;

      try {
        const { data } = await axios.get('/api/reviews');
        this.reviews = data.data ?? data;
        if (!Array.isArray(this.reviews)) this.reviews = [];
      } catch (error) {
        this.error = error.response?.data?.message || 'Ошибка загрузки отзывов';
        this.reviews = [];
      } finally {
        this.isLoading = false;
      }
    },

    async createReview(reviewData) {
      const { data } = await axios.post('/api/reviews', {
        text: reviewData.text,
        rating: reviewData.rating,
        user_id: reviewData.user_id,
      });
      const review = data.data ?? data;
      this.reviews.unshift(review);
      return review;
    },

    async updateReview(reviewId, reviewData) {
      const { data } = await axios.put(`/api/reviews/${reviewId}`, {
        text: reviewData.text,
        rating: reviewData.rating,
      });
      const updated = data.data ?? data;
      const index = this.reviews.findIndex((r) => r.id === reviewId);
      if (index !== -1) this.reviews[index] = updated;
      return updated;
    },

    async deleteReview(reviewId) {
      await axios.delete(`/api/reviews/${reviewId}`);
      this.reviews = this.reviews.filter((r) => r.id !== reviewId);
    },

    setRatingFilter(rating) {
      this.filterRating = rating;
      this.currentPage = 1;
    },

    clearFilter() {
      this.filterRating = null;
      this.currentPage = 1;
    },

    setPage(page) {
      this.currentPage = page;
    },
  },
});
