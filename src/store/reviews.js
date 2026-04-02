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
        deletingReviewId: null,
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
                console.error('Ошибка загрузки отзывов:', error);
                this.error = error.response?.data?.message || 'Ошибка загрузки отзывов';
                this.reviews = [];
            } finally {
                this.isLoading = false;
            }
        },

        async createReview(reviewData) {
            try {
                const { data } = await axios.post('/api/reviews', {
                    text: reviewData.text,
                    rating: reviewData.rating,
                    user_id: reviewData.user_id,
                });
                const review = data.data ?? data;
                this.reviews.unshift(review);
                return { success: true, data: review };
            } catch (error) {
                console.error('Ошибка создания отзыва:', error);
                return {
                    success: false,
                    error: error.response?.data?.message || 'Не удалось создать отзыв',
                };
            }
        },

        async updateReview(reviewId, reviewData) {
            try {
                const { data } = await axios.put(`/api/reviews/${reviewId}`, {
                    text: reviewData.text,
                    rating: reviewData.rating,
                });
                const updated = data.data ?? data;
                const index = this.reviews.findIndex((r) => r.id === reviewId);
                if (index !== -1) this.reviews[index] = updated;
                return { success: true, data: updated };
            } catch (error) {
                console.error('Ошибка обновления отзыва:', error);
                return {
                    success: false,
                    error: error.response?.data?.message || 'Не удалось обновить отзыв',
                };
            }
        },

        async deleteReview(reviewId) {
            this.deletingReviewId = reviewId;

            try {
                await axios.delete(`/api/reviews/${reviewId}`);

                // Удаляем из массива
                this.reviews = this.reviews.filter((r) => r.id !== reviewId);

                return { success: true };
            } catch (error) {
                console.error('Ошибка удаления отзыва:', error);
                return {
                    success: false,
                    error: error.response?.data?.message || 'Не удалось удалить отзыв',
                };
            } finally {
                this.deletingReviewId = null;
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
