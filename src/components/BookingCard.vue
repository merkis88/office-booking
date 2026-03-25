<script setup>
  import { computed, ref } from 'vue';
  import { useFavoritesStore } from '@/store/favorites';
  import { formatBookingTime } from '@/utils/dateFormat';
  import heartFilledUrl from '@/assets/images/icons/heart-filled.svg';
  import heartEmptyUrl from '@/assets/images/icons/heart-empty.svg';
  import placeholder from '@/assets/images/photos/placeholder.jpg';

  const props = defineProps({
    booking: {
      type: Object,
      required: true,
    },
  });

  defineEmits(['invite', 'reschedule', 'cancel']);

  const favoritesStore = useFavoritesStore();

  const isFav = computed(() => favoritesStore.isFavorite(props.booking.place?.id));
  const isTogglingFav = ref(false);

  async function toggleFavorite() {
    if (isTogglingFav.value || !props.booking.place?.id) return;
    isTogglingFav.value = true;
    try {
      await favoritesStore.toggleFavorite(props.booking.place.id);
    } finally {
      isTogglingFav.value = false;
    }
  }

  const placeTypeLabel = computed(() => {
    const types = {
      office: 'Аренда офиса',
      coworking: 'Аренда коворкинга',
      meeting: 'Аренда переговорной',
    };

    return types[props.booking.place?.type] || props.booking.place?.type;
  });
</script>

<template>
  <div class="booking-card">
    <div class="booking-card__left">
      <img
        :src="booking.place?.photo_url"
        :alt="booking.place?.name"
        class="booking-card__image"
        @error="
          (e) => {
            e.target.onerror = null;
            e.target.src = placeholder;
          }
        "
      />

      <div class="booking-card__info">
        <p class="booking-card__type">{{ placeTypeLabel }} "{{ booking.place?.name }}"</p>
        <p class="booking-card__place">Кабинет No{{ booking.place?.number_place }}</p>
        <p class="booking-card__time">
          {{ formatBookingTime(booking.start_time) }} - {{ formatBookingTime(booking.end_time) }}
        </p>
        <p class="booking-card__capacity">Вместимость: {{ booking.place?.capacity }} человек</p>
      </div>
    </div>

    <div class="booking-card__right">
      <button
        class="booking-card__fav-btn"
        :class="{ 'booking-card__fav-btn--active': isFav }"
        @click.stop="toggleFavorite"
        :disabled="isTogglingFav"
      >
        <img :src="isFav ? heartFilledUrl : heartEmptyUrl" alt="Избранное" />
      </button>

      <div class="booking-card__actions">
        <button class="booking-card__btn" @click="$emit('invite', booking)">
          Пригласить сотрудника
        </button>
        <button class="booking-card__btn" @click="$emit('reschedule', booking)">
          Перенести бронь
        </button>
        <button class="booking-card__btn" @click="$emit('cancel', booking)">Отменить бронь</button>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;

  .booking-card {
    width: 100%;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 2rem;
    padding: 1.5rem;
    background: $color-card-bg;
    border: 1px solid $color-border;
    border-radius: $radius-lg;

    &__left {
      display: flex;
      gap: 1.5rem;
      align-items: center;
    }

    &__image {
      width: 120px;
      height: 100px;
      object-fit: cover;
      border-radius: $radius-sm;
    }

    &__info {
      display: flex;
      flex-direction: column;
      gap: 0.3rem;
    }

    &__type {
      font-weight: 500;
    }

    &__place {
      font-size: $text-sm;
    }

    &__time {
      font-size: $text-sm;
    }

    &__capacity {
      font-size: $text-sm;
    }

    &__right {
      display: flex;
      flex-direction: column;
      align-items: flex-end;
      gap: 0.5rem;
    }

    &__fav-btn {
      background: none;
      border: none;
      cursor: pointer;
      padding: 0.25rem;
      transition: transform 0.2s;

      img {
        width: 1.5rem;
        height: 1.5rem;
      }

      &:hover {
        transform: scale(1.1);
      }

      &:disabled {
        opacity: 0.5;
        cursor: not-allowed;
      }
    }

    &__actions {
      display: flex;
      flex-direction: column;
      gap: 0.6rem;
    }

    &__btn {
      padding: 0.4rem 1rem;
      border-radius: $radius-sm;
      border: 1px solid $color-border;
      background: $color-input-bg;
      font-size: $text-sm;
      cursor: pointer;

      &:hover {
        background: $color-input-bg-dark;
      }
    }
  }
</style>
