<script setup>
  import { computed } from 'vue';
  import { formatBookingTime } from '@/utils/dateFormat';
  import placeholder from '@/assets/images/photos/placeholder.jpg';

  const props = defineProps({
    booking: {
      type: Object,
      required: true,
    },
  });

  const placeTypeLabel = computed(() => {
    const types = {
      office: 'Офис',
      coworking: 'Коворкинг',
      meeting: 'Переговорная',
    };
    return types[props.booking.place?.type] || props.booking.place?.type;
  });
</script>

<template>
  <div class="booking-history-card">
    <div class="booking-history-card__image-wrapper">
      <img
        :src="booking.place?.photo || placeholder"
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

  .booking-history-card {
    display: flex;
    background: rgba(230, 242, 250, 0.7);
    border: 2px solid $color-footer-bg;
    border-radius: 1.25rem;
    overflow: hidden;
    min-height: 200px;
    gap: 1.5rem;
    padding: 1rem;
    align-items: center;

    @media (max-width: 640px) {
      flex-direction: column;
      min-height: auto;
    }

    &__image-wrapper {
      width: 200px;
      height: 200px; /* квадрат */
      flex-shrink: 0;
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: 0.625rem;
      overflow: hidden;
      border: 2px solid $color-footer-bg; /* обводка wrapper */
      background: rgba(230, 242, 250, 0.7);
    }

    &__image {
      width: 100%;
      height: 100%;
      object-fit: cover; /* полностью заполняет wrapper */
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

    &__status {
      margin-top: 0.5rem;
      font-size: $text-base;
      font-weight: 500;
      color: rgba($color-text, 0.7);
    }
  }
</style>
