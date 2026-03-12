<script setup>
  import { ref, computed, onMounted } from 'vue';
  import { useAuthStore } from '@/store/auth';
  import { useReviewsStore } from '@/store/reviews';
  import { storeToRefs } from 'pinia';
  import ReviewCard from '@/components/ReviewCard.vue';

  const authStore = useAuthStore();
  const reviewsStore = useReviewsStore();

  const { reviews, isLoading, filterRating } = storeToRefs(reviewsStore);
  const { user } = storeToRefs(authStore);

  const rating = ref(0);
  const reviewText = ref('');
  const isSubmitting = ref(false);

  const editingReviewId = ref(null);
  const isEditing = computed(() => editingReviewId.value !== null);

  const showSuccessMessage = ref(false);
  const successMessageText = ref('');
  const showErrorMessage = ref(false);
  const errorMessageText = ref('');

  const itemsPerPage = 6;
  const currentPage = ref(1);

  const totalPages = computed(() => {
    const filtered = reviewsStore.filteredReviews;
    return Math.ceil(filtered.length / itemsPerPage);
  });

  const paginatedReviews = computed(() => {
    const filtered = reviewsStore.filteredReviews;
    const start = (currentPage.value - 1) * itemsPerPage;
    const end = start + itemsPerPage;
    return filtered.slice(start, end);
  });

  onMounted(async () => {
    try {
      await reviewsStore.fetchReviews();
    } catch (error) {
      console.error('Не удалось загрузить отзывы:', error);
    }
  });

  function goToPage(page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }
  }

  function setRating(value) {
    rating.value = value;
  }

  function filterByRating(ratingValue) {
    if (filterRating.value === ratingValue) {
      reviewsStore.clearFilter();
    } else {
      reviewsStore.setRatingFilter(ratingValue);
    }
    currentPage.value = 1;
  }

  function handleEditReview(review) {
    editingReviewId.value = review.id;
    rating.value = review.rating;
    reviewText.value = review.text;

    setTimeout(() => {
      document.querySelector('.reviews__form')?.scrollIntoView({ behavior: 'smooth' });
    }, 100);
  }

  function showError(message) {
    errorMessageText.value = message;
    showErrorMessage.value = true;
    showSuccessMessage.value = false;

    setTimeout(() => {
      showErrorMessage.value = false;
    }, 4000);
  }

  function showSuccess(message) {
    successMessageText.value = message;
    showSuccessMessage.value = true;
    showErrorMessage.value = false;

    setTimeout(() => {
      showSuccessMessage.value = false;
    }, 3000);
  }

  function cancelEdit() {
    editingReviewId.value = null;
    rating.value = 0;
    reviewText.value = '';
    showSuccessMessage.value = false;
    showErrorMessage.value = false;
  }

  async function handleSubmitReview() {
    if (!authStore.isAuthenticated) {
      showError('Необходимо авторизоваться для добавления отзыва');
      return;
    }

    if (rating.value === 0) {
      showError('Пожалуйста, выберите оценку');
      return;
    }

    const trimmedText = reviewText.value.trim();

    if (!trimmedText) {
      showError('Пожалуйста, напишите отзыв');
      return;
    }

    if (trimmedText.length < 16) {
      showError('Отзыв слишком короткий. Минимум 16 символов');
      return;
    }

    if (trimmedText.length > 1000) {
      showError('Отзыв слишком длинный. Максимум 1000 символов');
      return;
    }

    isSubmitting.value = true;

    try {
      if (isEditing.value) {
        await reviewsStore.updateReview(editingReviewId.value, {
          text: trimmedText,
          rating: rating.value,
        });
        showSuccess('Отзыв успешно обновлен');
      } else {
        await reviewsStore.createReview({
          text: trimmedText,
          rating: rating.value,
          user_id: user.value.id,
        });
        showSuccess('Отзыв успешно добавлен');
      }

      cancelEdit();

      setTimeout(() => {
        const grid = document.querySelector('.reviews__grid');
        if (grid) {
          grid.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
      }, 100);
    } catch (error) {
      console.error('Ошибка отправки отзыва:', error);

      if (error.response?.data?.errors) {
        const errors = error.response.data.errors;
        const firstError = Object.values(errors)[0];
        const errorMessage = Array.isArray(firstError) ? firstError[0] : firstError;
        showError(errorMessage);
      } else if (error.response?.data?.message) {
        showError(error.response.data.message);
      } else {
        showError('Не удалось отправить отзыв. Попробуйте позже');
      }
    } finally {
      isSubmitting.value = false;
    }
  }
</script>

<template>
  <div class="reviews">
    <div class="reviews__container">
      <div class="reviews__header">
        <h1 class="reviews__title">Узнайте, что думают клиенты о нашем бизнес центре</h1>

        <div class="reviews__filters">
          <button
            class="reviews__filter"
            :class="{ 'reviews__filter--active': filterRating === null }"
            @click="reviewsStore.clearFilter()"
          >
            Все отзывы
          </button>
          <button
            class="reviews__filter"
            :class="{ 'reviews__filter--active': filterRating === 5 }"
            @click="filterByRating(5)"
          >
            <img src="/star-icon.svg" alt="" class="reviews__filter-icon" />
            <img src="/star-icon.svg" alt="" class="reviews__filter-icon" />
            <img src="/star-icon.svg" alt="" class="reviews__filter-icon" />
            <img src="/star-icon.svg" alt="" class="reviews__filter-icon" />
            <img src="/star-icon.svg" alt="" class="reviews__filter-icon" />
          </button>
          <button
            class="reviews__filter"
            :class="{ 'reviews__filter--active': filterRating === 4 }"
            @click="filterByRating(4)"
          >
            <img src="/star-icon.svg" alt="" class="reviews__filter-icon" />
            <img src="/star-icon.svg" alt="" class="reviews__filter-icon" />
            <img src="/star-icon.svg" alt="" class="reviews__filter-icon" />
            <img src="/star-icon.svg" alt="" class="reviews__filter-icon" />
            <img src="/star-empty.svg" alt="" class="reviews__filter-icon" />
          </button>
          <button
            class="reviews__filter"
            :class="{ 'reviews__filter--active': filterRating === 3 }"
            @click="filterByRating(3)"
          >
            <img src="/star-icon.svg" alt="" class="reviews__filter-icon" />
            <img src="/star-icon.svg" alt="" class="reviews__filter-icon" />
            <img src="/star-icon.svg" alt="" class="reviews__filter-icon" />
            <img src="/star-empty.svg" alt="" class="reviews__filter-icon" />
            <img src="/star-empty.svg" alt="" class="reviews__filter-icon" />
          </button>
          <button
            class="reviews__filter"
            :class="{ 'reviews__filter--active': filterRating === 2 }"
            @click="filterByRating(2)"
          >
            <img src="/star-icon.svg" alt="" class="reviews__filter-icon" />
            <img src="/star-icon.svg" alt="" class="reviews__filter-icon" />
            <img src="/star-empty.svg" alt="" class="reviews__filter-icon" />
            <img src="/star-empty.svg" alt="" class="reviews__filter-icon" />
            <img src="/star-empty.svg" alt="" class="reviews__filter-icon" />
          </button>
          <button
            class="reviews__filter"
            :class="{ 'reviews__filter--active': filterRating === 1 }"
            @click="filterByRating(1)"
          >
            <img src="/star-icon.svg" alt="" class="reviews__filter-icon" />
            <img src="/star-empty.svg" alt="" class="reviews__filter-icon" />
            <img src="/star-empty.svg" alt="" class="reviews__filter-icon" />
            <img src="/star-empty.svg" alt="" class="reviews__filter-icon" />
            <img src="/star-empty.svg" alt="" class="reviews__filter-icon" />
          </button>
        </div>
      </div>

      <div v-if="isLoading" class="reviews__loading">
        <p>Загрузка отзывов...</p>
      </div>

      <div v-else-if="paginatedReviews.length > 0" class="reviews__grid">
        <ReviewCard
          v-for="review in paginatedReviews"
          :key="review.id"
          :review="review"
          @edit="handleEditReview"
        />
      </div>

      <div v-else class="reviews__empty">
        <p>Отзывов пока нет. Будьте первым!</p>
      </div>

      <div v-if="totalPages > 1" class="reviews__pagination">
        <button
          class="reviews__pagination-btn"
          :disabled="currentPage === 1"
          @click="goToPage(currentPage - 1)"
        >
          <img src="/arrow-left.svg" alt="Назад" />
        </button>

        <button
          v-for="page in totalPages"
          :key="page"
          class="reviews__pagination-number"
          :class="{ 'reviews__pagination-number--active': currentPage === page }"
          @click="goToPage(page)"
        >
          {{ page }}
        </button>

        <button
          class="reviews__pagination-btn"
          :disabled="currentPage === totalPages"
          @click="goToPage(currentPage + 1)"
        >
          <img src="/arrow-right.svg" alt="Вперед" />
        </button>
      </div>

      <div class="reviews__form">
        <Transition name="slide-down">
          <div v-if="showSuccessMessage" class="reviews__message">
            <p class="reviews__message-success">{{ successMessageText }}</p>
          </div>
        </Transition>

        <Transition name="slide-down">
          <div v-if="showErrorMessage" class="reviews__message">
            <p class="reviews__message-error">{{ errorMessageText }}</p>
          </div>
        </Transition>
        <h2 class="reviews__form-title">
          {{ isEditing ? 'Редактировать отзыв' : 'Оставь отзыв' }}
        </h2>

        <div v-if="!authStore.isAuthenticated" class="reviews__auth-warning">
          <p>
            Для добавления отзыва необходимо
            <router-link to="/authorization">авторизоваться</router-link>
          </p>
        </div>

        <template v-else>
          <div class="reviews__rating-section">
            <p class="reviews__form-label">Оцените нас, пожалуйста:</p>
            <div class="reviews__stars">
              <button
                v-for="star in 5"
                :key="star"
                class="reviews__star-btn"
                @click="setRating(star)"
                :disabled="isSubmitting"
              >
                <img
                  :src="star <= rating ? '/star-icon.svg' : '/star-empty.svg'"
                  alt="star"
                  class="reviews__star"
                />
              </button>
            </div>
          </div>

          <div class="reviews__textarea-section">
            <label class="reviews__form-label">Ваш отзыв:</label>
            <textarea
              v-model="reviewText"
              class="reviews__textarea"
              placeholder="Напишите отзыв"
              rows="6"
              :disabled="isSubmitting"
            ></textarea>
            <span class="reviews__char-count">{{ reviewText.length }} / 1000</span>
          </div>

          <div class="reviews__form-buttons">
            <button
              class="reviews__submit-btn"
              @click="handleSubmitReview"
              :disabled="isSubmitting"
            >
              {{
                isSubmitting ? 'Отправка...' : isEditing ? 'Сохранить изменения' : 'Отправить отзыв'
              }}
            </button>

            <button
              v-if="isEditing"
              class="reviews__cancel-btn"
              @click="cancelEdit"
              :disabled="isSubmitting"
            >
              Отмена
            </button>
          </div>
        </template>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;
  @use '@/assets/styles/mixins' as *;

  .reviews {
    min-height: 100vh;
    padding: 4rem 2rem;

    &__container {
      @include container;
    }

    &__header {
      margin-bottom: 3rem;
    }

    &__title {
      font-family: $font-title;
      font-size: $text-3xl;
      font-weight: 500;
      color: $color-text;
      margin-bottom: 2rem;
      text-align: start;
    }

    &__filters {
      display: flex;
      justify-content: center;
      gap: 1rem;
      flex-wrap: wrap;
    }

    &__filter {
      padding: 0.3rem 1.5rem;
      border: 1px solid $color-border;
      border-radius: $radius-xxs;
      background: transparent;
      color: $color-text;
      font-size: $text-xl;
      cursor: pointer;
      transition: all 0.2s;
      display: flex;
      align-items: center;
      gap: 0.25rem;

      &:hover {
        background: $color-btn-profile;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
      }

      &--active {
        background: $color-btn-profile;
        border-color: $color-text;
      }
    }

    &__filter-icon {
      width: 1.7rem;
      height: 1.7rem;
    }

    &__grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 2rem;
      margin-bottom: 3rem;
    }

    &__loading,
    &__empty {
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 300px;
      font-size: $text-lg;
      color: $color-text;
    }

    &__pagination {
      display: flex;
      justify-content: center;
      align-items: center;
      gap: 0.5rem;
      margin-bottom: 4rem;
    }

    &__pagination-btn {
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      transition: all 0.2s;

      &:hover:not(:disabled) {
        background: $color-input-bg-dark;
      }

      &:disabled {
        opacity: 0.5;
        cursor: not-allowed;
      }

      img {
        width: 2.5rem;
        height: 2.5rem;
      }
    }

    &__pagination-number {
      width: 2.5rem;
      height: 2.5rem;
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: $radius-xs;
      background: $color-input-bg;
      color: $color-text;
      font-size: $text-base;
      cursor: pointer;
      transition: all 0.2s;
      font-weight: 600;

      &:hover {
        background: $color-input-bg-dark;
      }

      &--active {
        background: $color-header-bg;
        border-color: $color-text;
        font-weight: 600;
      }
    }

    &__form {
      max-width: 600px;
      margin: 0 auto;
      padding: 2.5rem;
      border-radius: $radius-lg;
      display: flex;
      flex-direction: column;
      gap: 2rem;
      position: relative;
      align-items: stretch;
    }

    &__message {
      margin-bottom: 1rem;
      display: flex;
      justify-content: center;
    }

    &__message-success,
    &__message-error {
      padding: 1rem 2rem;
      border-radius: $radius-xs;
      font-size: $text-base;
      margin: 0;
      box-shadow: 0 7px 6px rgba(0, 0, 0, 0.2);
      text-align: center;
      width: auto;
      display: inline-block;
    }

    &__message-success {
      background: #c1f97d;
      border: 1px solid #000000;
    }

    &__message-error {
      background: #ee5a6f;
      border: 1px solid #000000;
    }

    &__char-count {
      font-size: $text-sm;
      color: rgba($color-text, 0.6);
      text-align: right;
      display: block;
      margin-top: 0.25rem;
    }

    .slide-down-enter-active {
      transition: all 0.4s ease-out;
    }

    .slide-down-leave-active {
      transition: all 0.4s ease-in;
    }

    .slide-down-enter-from {
      transform: translateY(-20px);
      opacity: 0;
    }

    .slide-down-leave-to {
      transform: translateY(-20px);
      opacity: 0;
    }

    &__form-title {
      font-family: $font-title;
      font-size: $text-2xl;
      font-weight: 500;
      color: $color-text;
      text-align: center;
      margin: 0;
      width: 100%;
    }

    &__auth-warning {
      text-align: center;
      padding: 1.5rem;
      background: rgba(255, 193, 7, 0.1);
      border: 1px solid rgba(255, 193, 7, 0.3);
      border-radius: $radius-sm;

      p {
        margin: 0;
        color: $color-text;
      }

      a {
        color: #2563eb;
        text-decoration: underline;
        font-weight: 600;

        &:hover {
          color: #1e40af;
        }
      }
    }

    &__rating-section {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 1rem;
    }

    &__form-label {
      font-size: $text-base;
      font-weight: 500;
      color: $color-text;
      margin: 0;
    }

    &__stars {
      display: flex;
      gap: 0.5rem;
    }

    &__star-btn {
      background: transparent;
      border: none;
      cursor: pointer;
      padding: 0;
      transition: transform 0.2s;

      &:hover:not(:disabled) {
        transform: scale(1.2);
        filter: drop-shadow(0 4px 4px rgba(0, 0, 0, 0.2));
      }

      &:disabled {
        opacity: 0.6;
        cursor: not-allowed;
      }
    }

    &__star {
      width: 2rem;
      height: 2rem;
      filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.2));
    }

    &__textarea-section {
      display: flex;
      flex-direction: column;
      gap: 0.75rem;
    }

    &__textarea {
      width: 100%;
      padding: 1rem;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      background: #ffffff;
      font-family: $font-base;
      font-size: $text-base;
      color: $color-text;
      resize: vertical;
      outline: none;
      min-height: 120px;
      box-sizing: border-box;

      &:focus {
        border-color: $color-text;
      }

      &::placeholder {
        color: rgba($color-text, 0.5);
      }

      &:disabled {
        opacity: 0.6;
        cursor: not-allowed;
      }
    }

    &__form-buttons {
      display: flex;
      gap: 1rem;
      justify-content: center;
      flex-wrap: wrap;
    }

    &__submit-btn {
      padding: 1rem 2rem;
      background: $color-input-bg;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      font-size: $text-lg;
      font-weight: 500;
      color: $color-text;
      cursor: pointer;
      transition: all 0.3s;

      &:hover:not(:disabled) {
        background: $color-input-bg-dark;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        transform: translateY(-2px);
      }

      &:active {
        transform: translateY(0);
      }

      &:disabled {
        opacity: 0.6;
        cursor: not-allowed;
      }
    }

    &__cancel-btn {
      padding: 1rem 2rem;
      background: transparent;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      font-size: $text-lg;
      font-weight: 500;
      color: $color-text;
      cursor: pointer;
      transition: all 0.3s;

      &:hover:not(:disabled) {
        background: rgba($color-text, 0.1);
      }

      &:disabled {
        opacity: 0.6;
        cursor: not-allowed;
      }
    }

    @media (max-width: 1024px) {
      &__grid {
        grid-template-columns: 1fr;
      }
    }

    @media (max-width: 768px) {
      padding: 2rem 1rem;

      &__title {
        font-size: $text-2xl;
      }

      &__filters {
        flex-direction: column;
        align-items: stretch;
      }

      &__filter {
        justify-content: center;
      }

      &__form {
        padding: 1.5rem;
      }

      &__form-title {
        font-size: $text-xl;
      }

      &__form-buttons {
        flex-direction: column;
      }

      &__submit-btn,
      &__cancel-btn {
        width: 100%;
      }
    }
  }
</style>