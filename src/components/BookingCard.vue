<script setup>
  import { computed } from 'vue';

  const props = defineProps({
    booking: {
      type: Object,
      required: true,
    },
  });

  const placeTypeLabel = computed(() => {
    const types = {
      office: 'Аренда офиса',
      coworking: 'Аренда коворкинга',
      meeting: 'Аренда переговорной',
    };

    return types[props.booking.place.type] || props.booking.place.type;
  });

  const formatTime = (date) => {
    return new Date(date).toLocaleTimeString('ru-RU', {
      hour: '2-digit',
      minute: '2-digit',
    });
  };
</script>

<template>
  <div class="booking-card">
    <div class="booking-card__left">
      <img :src="booking.place.photo_url || '/placeholder.jpg'" class="booking-card__image" />

      <div class="booking-card__info">
        <p class="booking-card__type">
          {{ placeTypeLabel }}
        </p>

        <p class="booking-card__place">Кабинет №{{ booking.place.number_place }}</p>

        <p class="booking-card__time">
          {{ formatTime(booking.start_time) }} - {{ formatTime(booking.end_time) }}
        </p>

        <p class="booking-card__capacity">Вместимость: {{ booking.place.capacity }} человек</p>
      </div>
    </div>

    <div class="booking-card__actions">
      <button class="booking-card__btn">Пригласить сотрудников</button>

      <button class="booking-card__btn">Перенести бронь</button>

      <button class="booking-card__btn">Отменить бронь</button>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;

  .booking-card {
    width: 60%;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 2rem;

    padding: 1.5rem;

    background: $color-card-bg;
    border: 1px solid $color-border;
    border-radius: $radius-lg;

    margin-bottom: 2rem;

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
