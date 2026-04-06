<script setup>
  import { ref, computed } from 'vue';
  import { useAuthStore } from '@/store/auth';
  import placeholder from '@/assets/images/photos/placeholder.jpg';
  import { getPlaceTypeLabel } from '@/store/places.js';

  const authStore = useAuthStore();

  const props = defineProps({
    place: {
      type: Object,
      required: true,
    },
  });

  const emit = defineEmits(['delete-place', 'restore-place']);

  const showDetails = ref(false);

  function toggleDetails() {
    showDetails.value = !showDetails.value;
  }

  function handleDelete() {
    if (confirm(`Вы уверены, что хотите удалить "${props.place.name}"?`)) {
      emit('delete-place', props.place.id);
    }
  }

  function handleRestore() {
    emit('restore-place', props.place.id);
  }

  const placeTypeLabel = computed(() => {
    getPlaceTypeLabel(props.place.type);
  });
</script>

<template>
  <div class="archived-place-card">
    <div
      class="archived-place-card__main"
      :class="{ 'archived-place-card__main--details': showDetails }"
    >
      <template v-if="!showDetails">
        <div class="archived-place-card__image-wrapper">
          <img
            :src="place.photo_url"
            :alt="place.name"
            class="archived-place-card__image"
            @error="
              (e) => {
                e.target.onerror = null;
                e.target.src = placeholder;
              }
            "
          />
        </div>

        <div class="archived-place-card__content">
          <h3 class="archived-place-card__title">{{ placeTypeLabel }} "{{ place.name }}"</h3>
          <p class="archived-place-card__number">Кабинет №{{ place.number_place }}</p>
          <p class="archived-place-card__price">Стоимость: {{ place.price }}₽</p>
          <p class="archived-place-card__capacity">Вместимость: {{ place.capacity }} человек</p>
          <span class="archived-place-card__details-text" @click="toggleDetails">Подробнее</span>
        </div>

        <button
          v-if="authStore.isAdmin"
          class="archived-place-card__restore"
          @click="handleRestore"
          aria-label="Восстановить помещение"
        >
          <img src="@/assets/images/icons/un-restore.svg" alt="Восстановить" />
        </button>
      </template>

      <template v-else>
        <img
          src="@/assets/images/icons/arrow-left.svg"
          class="archived-place-card__back"
          @click="toggleDetails"
          alt="Назад"
        />
        <div class="archived-place-card__content archived-place-card__content--details">
          <h3 class="archived-place-card__title archived-place-card__title--details">
            {{ placeTypeLabel }} "{{ place.name }}"
          </h3>
          <p class="archived-place-card__description">{{ place.description }}</p>
        </div>
      </template>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;
  @use '@/assets/styles/mixins' as *;

  .archived-place-card {
    overflow: hidden;
    display: flex;
    flex-direction: column;
    font-family: $font-base;

    &__main {
      background: $color-btn-profile;
      border: 1px solid $color-border;
      border-radius: $radius-lg;
      display: flex;
      align-items: center;
      gap: 2.4rem;
      padding: 1.5rem;
      position: relative;
      transition: $transition-fast;
      opacity: 0.8;
      min-height: 300px;
    }

    &__main--details {
      flex-direction: column;
      justify-content: flex-start;
      align-items: stretch;
    }

    &__image-wrapper {
      position: relative;
      width: 180px;
      height: 180px;
      flex-shrink: 0;
      overflow: hidden;
      border-radius: $radius-lg;
    }

    &__image {
      width: 100%;
      height: 100%;
      object-fit: cover;
      filter: grayscale(30%);
    }

    &__content {
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 0.75rem;
      justify-content: center;
    }

    &__content--details {
      align-items: center;
      justify-content: flex-start;
      text-align: left;
      padding: 0 1rem;
    }

    &__title {
      font-size: $text-lg;
      font-weight: 600;
      color: $color-text;
      margin: 0;
    }

    &__title--details {
      font-size: $text-xl;
      font-weight: normal;
    }

    &__number {
      font-size: $text-base;
      color: $color-text;
      margin: 0;
    }

    &__price {
      font-size: $text-base;
      color: $color-text;
      margin: 0;
    }

    &__capacity {
      font-size: $text-base;
      color: $color-text;
      margin: 0;
    }

    &__details-text {
      color: $color-text;
      text-decoration: underline;
      cursor: pointer;
      font-size: $text-lg;
      font-weight: 500;
    }

    &__description {
      font-size: $text-base;
      color: $color-text;
      margin: 0;
      line-height: 1.5;
    }

    &__back {
      position: absolute;
      top: 0.75rem;
      left: 0.75rem;
      width: 40px;
      height: 40px;
      cursor: pointer;
      z-index: 10;
      object-fit: contain;

      &:hover {
        transform: scale(1.1);
      }
      &:active {
        transform: scale(0.95);
      }

      @media (max-width: 768px) {
        top: 0.5rem;
        left: 0.5rem;
        width: 20px;
        height: 20px;
      }
    }

    &__restore {
      position: absolute;
      bottom: 0.75rem;
      right: 1.5rem;
      width: 2.5rem;
      height: 2.5rem;
      border: none;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      transition: all 0.2s;

      &:hover {
        transform: scale(1.1);
      }

      img {
        width: 2rem;
        height: 2rem;
      }
    }

    @media (max-width: 768px) {
      &__main {
        flex-direction: column;
        padding: 1rem;
      }

      &__image-wrapper {
        width: 100%;
        height: 200px;
      }

      &__restore {
        bottom: 0.5rem;
        right: 0.5rem;
        width: 2rem;
        height: 2rem;

        img {
          width: 1.25rem;
          height: 1.25rem;
        }
      }
    }
  }
</style>
