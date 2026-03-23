import { defineStore } from 'pinia';
import axios from 'axios';

export const useReviewsStore = defineStore('reviews', {
  state: () => ({
    reviews: [],
    isLoading: false,
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
      try {
        const { data } = await axios.get('/api/reviews');


        if (data.data && Array.isArray(data.data)) {
          this.reviews = data.data;
        } else if (Array.isArray(data)) {
          this.reviews = data;
        } else if (data.reviews && Array.isArray(data.reviews)) {
          this.reviews = data.reviews;
        } else {
          console.warn('Неожиданный формат данных от API:', data);
          this.reviews = [];
        }
      } catch (error) {
        console.error('Ошибка загрузки отзывов:', error);
        this.reviews = [];
        throw error;
      } finally {
        this.isLoading = false;
      }
    },

    async createReview(reviewData) {
      this.isLoading = true;
      try {
        const { data } = await axios.post('/api/reviews', {
          text: reviewData.text,
          rating: reviewData.rating,
          user_id: reviewData.user_id,
        });


        let newReview = null;

        if (data.review) {
          newReview = data.review;
        } else if (data.data && data.data.review) {
          newReview = data.data.review;
        } else if (data.data && data.data.id) {
          newReview = data.data;
        } else if (data.id) {
          newReview = data;
        }

        if (newReview) {
          if (!Array.isArray(this.reviews)) {
            this.reviews = [];
          }

          this.reviews.unshift(newReview);
        } else {
          console.warn('Не удалось извлечь новый отзыв из ответа, перезагружаем список');
          await this.fetchReviews();
        }

        return data;
      } catch (error) {
        console.error('Ошибка создания отзыва:', error);
        throw error;
      } finally {
        this.isLoading = false;
      }
    },

    async updateReview(reviewId, reviewData) {
      this.isLoading = true;
      try {
        const { data } = await axios.put(`/api/reviews/${reviewId}`, {
          text: reviewData.text,
          rating: reviewData.rating,
        });


        let updatedReview = null;

        if (data.review) {
          updatedReview = data.review;
        } else if (data.data && data.data.review) {
          updatedReview = data.data.review;
        } else if (data.data && data.data.id) {
          updatedReview = data.data;
        } else if (data.id) {
          updatedReview = data;
        }

        if (Array.isArray(this.reviews)) {
          const index = this.reviews.findIndex((r) => r.id === reviewId);

          if (index !== -1) {
            if (updatedReview) {
              this.reviews[index] = updatedReview;
            } else {
              this.reviews[index] = {
                ...this.reviews[index],
                text: reviewData.text,
                rating: reviewData.rating,
                updated_at: new Date().toISOString(),
              };
            }
          } else {
            console.warn('Отзыв не найден в списке, перезагружаем');
            await this.fetchReviews();
          }
        }

        return data;
      } catch (error) {
        console.error('Ошибка обновления отзыва:', error);
        throw error;
      } finally {
        this.isLoading = false;
      }
    },

    async deleteReview(reviewId) {
      this.isLoading = true;
      try {
        const { data } = await axios.delete(`/api/reviews/${reviewId}`);

        if (Array.isArray(this.reviews)) {
          this.reviews = this.reviews.filter((r) => r.id !== reviewId);
        }

        return data;
      } catch (error) {
        console.error('Ошибка удаления отзыва:', error);
        throw error;
      } finally {
        this.isLoading = false;
      }
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
