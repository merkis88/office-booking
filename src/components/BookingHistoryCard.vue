<script setup>
  import { computed } from 'vue';
  import { getPlaceTypeLabel } from '@/store/places.js';
  import { formatBookingTime } from '@/utils/dateFormat';
  import FavoriteButton from '@/components/FavoriteButton.vue';
  import placeholder from '@/assets/images/photos/placeholder.jpg';

  const props = defineProps({
    booking: {
      type: Object,
      required: true,
    },
  });

  const placeTypeLabel = computed(() => getPlaceTypeLabel(props.booking.place?.type));
</script>

<template>
  <div class="booking-history-card">
    <div class="booking-history-card__image-wrapper">
      <img
        :src="booking.place?.photo_url || placeholder"
        :alt="booking.place?.name"
        class="booking-history-card__image"
        @error="
          (e) => {
            e.target.onerror = null;
            e.target.src = placeholder;
          }
        "
      />
    </div>
    <FavoriteButton :place-id="booking.place?.id" class="booking-history-card__fav-btn" />
    <div class="booking-history-card__content">
      <p class="booking-history-card__title">{{ placeTypeLabel }} “{{ booking.place?.name }}”</p>
      <p class="booking-history-card__line">Кабинет №{{ booking.place?.number_place }}</p>
      <p class="booking-history-card__line">
        {{ formatBookingTime(booking.start_time) }} - {{ formatBookingTime(booking.end_time) }}
      </p>
      <p class="booking-history-card__line">Стоимость: {{ booking.price }}р</p>
      <p class="booking-history-card__line">Вместимость: {{ booking.place?.capacity }} человек</p>
      <p class="booking-history-card__status">
        {{ booking.status === 'cancelled' ? 'Аренда отменена' : 'Аренда завершена' }}
      </p>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;
  @use '@/assets/styles/mixins' as *;

  .booking-history-card {
    @include card-base;
    overflow: hidden;
    min-height: 200px;

    @media (max-width: 640px) {
      flex-direction: column;
      min-height: auto;
    }

    &__image-wrapper {
      @include card-image;
    }

    &__content {
      flex: 1;
      display: flex;
      flex-direction: column;
      justify-content: center; /* центр текста по вертикали */
      gap: 0.5rem;
    }

    &__title {
      font-size: $text-lg;
      font-weight: 500;
      margin: 0;
    }

    &__line {
      margin: 0;
      font-size: $text-base;
      line-height: 1.4;
    }

    &__fav-btn {
      position: absolute;
      top: 0.75rem;
      right: 0.75rem;
    }

    &__status {
      margin-top: 0.5rem;
      font-size: $text-base;
      font-weight: 500;
      color: rgba($color-text, 0.7);
    }
  }
</style>
