<script setup>
  import { computed } from 'vue';
  import { useAuthStore } from '@/store/auth';
  import { useReviewsStore } from '@/store/reviews';

  const authStore = useAuthStore();
  const reviewsStore = useReviewsStore();

  const props = defineProps({
    review: {
      type: Object,
      required: true,
    },
  });

  const emit = defineEmits(['edit', 'delete']);

  // Генерируем массив звезд
  const stars = Array.from({ length: 5 }, (_, i) => i < props.review.rating);

  // ✅ Проверка - это отзыв текущего пользователя?
  const isCurrentUserReview = computed(() => {
    if (!authStore.user) return false;
    return props.review.user_id === authStore.user.id;
  });

  // Имя автора
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

  // Аватар
  const avatarSrc = computed(() => {
    if (props.review.user?.photo) {
      return props.review.user.photo;
    }
    return '/avatar-default.png';
  });

  // Дата
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

  const handleImageError = (event) => {
    event.target.src = '/avatar-default.png';
  };

  // ✅ Редактировать отзыв
  function handleEdit() {
    emit('edit', props.review);
  }

  // ✅ Удалить отзыв
  async function handleDelete() {
    const confirmed = confirm('Вы уверены, что хотите удалить этот отзыв?');

    if (!confirmed) return;

    try {
      await reviewsStore.deleteReview(props.review.id);
      alert('Отзыв удален');
    } catch (error) {
      console.error('Ошибка удаления отзыва:', error);
      alert('Не удалось удалить отзыв');
    }
  }
</script>

<template>
  <div class="review-card">
    <!-- Левая часть: Автор, дата, звезды, текст -->
    <div class="review-card__content">
      <!-- Заголовок -->
      <div class="review-card__header">
        <div class="review-card__author-info">
          <h3 class="review-card__author">{{ authorName }}</h3>
          <p class="review-card__date">{{ reviewDate }}</p>
        </div>

        <!-- ✅ Кнопки редактирования/удаления (только для своих отзывов) -->
        <div v-if="isCurrentUserReview" class="review-card__actions">
          <button class="review-card__action-btn" @click="handleEdit" aria-label="Редактировать">
            <img src="/edit-icon.svg" alt="Редактировать" />
          </button>
          <button class="review-card__action-btn" @click="handleDelete" aria-label="Удалить">
            <img src="/delete-icon.svg" alt="Удалить" />
          </button>
        </div>
      </div>

      <!-- Звезды рейтинга -->
      <div class="review-card__rating">
        <img
          v-for="(filled, index) in stars"
          :key="index"
          :src="filled ? '/star-icon.svg' : '/star-empty.svg'"
          alt="star"
          class="review-card__star"
        />
      </div>

      <!-- Текст отзыва -->
      <p class="review-card__text">{{ review.text }}</p>
    </div>

    <!-- Правая часть: Аватар -->
    <div class="review-card__avatar-wrapper">
      <img
        :src="avatarSrc"
        :alt="authorName"
        class="review-card__avatar"
        @error="handleImageError"
      />
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;

  .review-card {
    padding: 1.5rem;
    background: $color-card-bg;
    border: 1px solid $color-border;
    border-radius: $radius-lg;
    display: flex;
    gap: 1.5rem;
    transition: all 0.2s;
    position: relative; // ✅ Для абсолютного позиционирования кнопок

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
      border-bottom: 1px solid rgba($color-border, 0.3);
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

    // ✅ Кнопки в правом нижнем углу
    &__actions {
      position: absolute;
      bottom: 1.5rem;
      right: 1.5rem;
      display: flex;
      gap: 0.75rem;
      z-index: 10;
    }

    &__action-btn {
      width: 2.5rem;
      height: 2.5rem;
      display: flex;
      align-items: center;
      justify-content: center;
      border: none;
      border-radius: 50%;
      background: rgba(255, 255, 255, 0.9);
      box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
      cursor: pointer;
      transition: all 0.2s;

      &:hover {
        background: white;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
        transform: scale(1.1);
      }

      &:active {
        transform: scale(0.95);
      }

      img {
        width: 1.25rem;
        height: 1.25rem;
        filter: brightness(0) saturate(100%); // Делаем иконки черными
      }
    }

    &__rating {
      display: flex;
      gap: 0.25rem;
    }

    &__star {
      width: 1.25rem;
      height: 1.25rem;
      filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.2));
    }

    &__text {
      font-size: $text-base;
      line-height: 1.6;
      color: $color-text;
      margin: 0;
      word-break: break-word;
      padding-right: 5rem; // ✅ Отступ для кнопок
    }

    &__avatar-wrapper {
      flex-shrink: 0;
      display: flex;
      align-items: flex-start;
    }

    &__avatar {
      width: 5rem;
      height: 5rem;
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
