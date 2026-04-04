<script setup>
import { ref, computed } from 'vue';
import { useAuthStore } from '@/store/auth';
import { useReviewsStore } from '@/store/reviews';
import { storeToRefs } from 'pinia';
import starFilled from '@/assets/images/icons/star-icon.svg';
import starEmpty from '@/assets/images/icons/star-empty.svg';

const authStore = useAuthStore();
const reviewsStore = useReviewsStore();
const { deletingReviewId } = storeToRefs(reviewsStore);

const props = defineProps({
    review: {
        type: Object,
        required: true,
    },
});

const emit = defineEmits(['edit', 'delete']);

const errorMessage = ref('');

const stars = Array.from({ length: 5 }, (_, i) => i < props.review.rating);

const isCurrentUserReview = computed(() => {
    if (!authStore.user) return false;
    return props.review.user_id === authStore.user.id;
});

const authorName = computed(() => {
    if (props.review.user) {
        const { first_name, last_name, patronymic } = props.review.user;
        const parts = [last_name, first_name];
        if (patronymic) {
            parts.push(patronymic);
        }
        return parts.filter(Boolean).join(' ');
    }
    return 'Аноним';
});

const avatarSrc = computed(() => {
    if (props.review.user?.photo_url) {
        return props.review.user.photo_url;
    }
    return '/avatar-default.png';
});

const reviewDate = computed(() => {
    if (!props.review.created_at) return 'Дата не указана';

    if (props.review.created_at.includes('-')) {
        const date = new Date(props.review.created_at);
        return date.toLocaleDateString('ru-RU', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
        });
    }

    return props.review.created_at;
});

const isDeleting = computed(() => {
    return deletingReviewId.value === props.review.id;
});

function handleEdit() {
    emit('edit', props.review);
}

async function handleDelete() {

    try {
        const result = await reviewsStore.deleteReview(props.review.id);

        if (!result.success) {
            errorMessage.value = result?.error || 'Не удалось удалить отзыв';
        }
    } catch (error) {
        console.error('Ошибка удаления отзыва:', error);
        errorMessage.value = 'Произошла ошибка при удалении отзыва';
    }
}
</script>

<template>
  <div class="review-card">
    <div class="review-card__content">
      <div class="review-card__header">
        <div class="review-card__author-info">
          <h3 class="review-card__author">{{ authorName }}</h3>
          <p class="review-card__date">{{ reviewDate }}</p>
        </div>
      </div>

        <div class="review-card__rating">
            <img
                v-for="(filled, index) in stars"
                :key="index"
                :src="filled ? starFilled : starEmpty"
                alt="star"
                class="review-card__star"
            />
        </div>

      <p class="review-card__text">{{ review.text }}</p>

      <p v-if="errorMessage" class="error-message">{{ errorMessage }}</p>
    </div>

    <div class="review-card__avatar-wrapper">
        <img :src="avatarSrc" class="review-card__avatar" alt="Аватар" />
        <div v-if="isCurrentUserReview" class="review-card__actions">
        <button class="review-card__action-btn" @click="handleEdit" aria-label="Редактировать">
          <img src="@/assets/images/icons/edit-icon.svg" alt="Редактировать" />
        </button>
        <button class="review-card__action-btn" @click="handleDelete" aria-label="Удалить">
          <img src="@/assets/images/icons/delete-icon.svg" alt="Удалить" />
        </button>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;
  @use '@/assets/styles/mixins' as *;

  .review-card {
    @include card-base;
    transition: all 0.2s;

    &:hover {
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    }

    &__content {
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 0.75rem;
    }

    &__header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      gap: 1rem;
      padding-bottom: 0.5rem;
      border-bottom: 2px solid rgba($color-border, 0.5);
    }

    &__author-info {
      display: flex;
      align-items: baseline;
      gap: 1rem;
      flex-wrap: wrap;
    }

    &__author {
      font-size: $text-lg;
      font-weight: 600;
      color: $color-text;
      margin: 0;
    }

    &__date {
      font-size: $text-sm;
      color: rgba($color-text, 0.6);
      margin: 0;
      white-space: nowrap;
    }

    &__actions {
      bottom: 1.5rem;
      right: 1.5rem;
      display: flex;
      gap: 0.75rem;
      z-index: 10;
    }

    &__action-btn {
      display: flex;
      align-items: center;
      justify-content: center;
      border: none;
      border-radius: 50%;
      cursor: pointer;
      transition: all 0.2s;

      &:hover {
        transform: scale(1.1);
      }

      &:active {
        transform: scale(0.95);
      }

      img {
        width: 1.5rem;
        height: 1.5rem;
        filter: brightness(0) saturate(100%);
      }
    }

    &__rating {
      display: flex;
      gap: 0.25rem;
    }

    &__star {
      width: 1.75rem;
      height: 1.75rem;
      filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.2));
    }

    &__text {
      font-size: $text-base;
      line-height: 1.6;
      color: $color-text;
      margin: 0;
      word-break: break-word;
      padding-right: 5rem;
    }

    &__avatar-wrapper {
      flex-shrink: 0;
      display: flex;
      flex-direction: column;
      align-items: end;
      justify-content: space-between;
      gap: 30px;
    }

    &__avatar {
      width: 8rem;
      height: 8rem;
      border-radius: 50%;
      object-fit: cover;
      background: $color-input-bg;
      border: 2px solid rgba($color-border, 0.3);
    }

    @media (max-width: 768px) {
      flex-direction: column-reverse;
      align-items: center;

      &__avatar-wrapper {
        width: 100%;
        justify-content: center;
      }

      &__header {
        flex-direction: column;
        align-items: flex-start;
      }

      &__author-info {
        flex-direction: column;
        gap: 0.25rem;
      }

      &__actions {
        position: static;
        margin-top: 1rem;
        justify-content: flex-end;
      }

      &__text {
        padding-right: 0;
      }
    }
  }
</style>
