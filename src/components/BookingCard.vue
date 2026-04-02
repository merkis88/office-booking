<script setup>
  import { computed } from 'vue';
  import { formatBookingTime } from '@/utils/dateFormat';
  import FavoriteButton from '@/components/FavoriteButton.vue';
  import placeholder from '@/assets/images/photos/placeholder.jpg';

  const props = defineProps({
    booking: {
      type: Object,
      required: true,
    },
  });

  defineEmits(['invite', 'reschedule', 'cancel']);

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
  <div class="booking-card">
    <div class="booking-card__main">
      <FavoriteButton
        :place-id="booking.place?.id"
        class="booking-card__fav-btn"
      />

      <div class="booking-card__image-wrapper">
        <img
          :src="booking.place?.photo_url || placeholder"
          :alt="booking.place?.name"
          class="booking-card__image"
          @error="
            (e) => {
              e.target.onerror = null;
              e.target.src = placeholder;
            }
          "
        />
      </div>

      <div class="booking-card__content">
        <p class="booking-card__title">{{ placeTypeLabel }} “{{ booking.place?.name }}”</p>
        <p class="booking-card__line">Кабинет №{{ booking.place?.number_place }}</p>
        <p class="booking-card__line">
          {{ formatBookingTime(booking.start_time) }} - {{ formatBookingTime(booking.end_time) }}
        </p>
        <p class="booking-card__line">Вместимость: {{ booking.place?.capacity }} человек</p>
      </div>
    </div>

    <div class="booking-card__side">
      <button class="booking-card__action-btn" @click="$emit('invite', booking)">
        Пригласить сотрудников
      </button>
      <button class="booking-card__action-btn" @click="$emit('reschedule', booking)">
        Перенести бронь
      </button>
      <button class="booking-card__action-btn" @click="$emit('cancel', booking)">
        Отменить бронь
      </button>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;

  .booking-card {
    width: 100%;
    display: flex;
    align-items: center;
    gap: 1.5rem;

    &__main {
      width: 600px;
      max-width: 100%;
      min-height: 260px;
      background: rgba(230, 242, 250, 0.7);
      border: 2px solid $color-footer-bg;
      border-radius: 1.25rem; // 20px
      display: flex;
      align-items: center;
      gap: 1.75rem;
      padding: 1.25rem;
      position: relative;
    }

    &__image-wrapper {
      width: 190px;
      height: 190px;
      flex-shrink: 0;
      border: 2px solid $color-footer-bg;
      border-radius: 0.625rem; // 10px
      overflow: hidden;
      background: rgba(230, 242, 250, 0.7);
    }

    &__image {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    &__content {
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 0.9rem;
      min-width: 0;
    }

    &__title {
      padding-right: 46px;
      margin: 0;
      font-size: $text-lg;
      font-weight: 500;
      line-height: 1.35;
    }

    &__line {
      margin: 0;
      font-size: $text-lg;
      line-height: 1.35;
    }

    &__fav-btn {
      position: absolute;
      top: 1rem;
      right: 1rem;
    }

    &__side {
      width: 260px;
      flex-shrink: 0;
      display: flex;
      flex-direction: column;
      gap: 1rem;
    }

    &__action-btn {
      width: 260px;
      height: 50px;
      padding: 0;
      border-radius: 0.625rem; // 10px
      border: 1px solid $color-border;
      background: $color-btn-profile;
      font-size: $text-base;
      font-weight: 400;
      cursor: pointer;
      transition: background 0.2s;

      &:hover {
        background: rgba(209, 223, 232, 0.95);
      }
    }

    @media (max-width: 1024px) {
      flex-direction: column;
      align-items: flex-start;

      &__main {
        width: 100%;
      }

      &__side {
        width: 100%;
        flex-direction: row;
        flex-wrap: wrap;
      }

      &__action-btn {
        width: 260px;
      }
    }

    @media (max-width: 640px) {
      &__main {
        flex-direction: column;
        align-items: stretch;
      }

      &__image-wrapper {
        width: 100%;
        height: 200px;
      }

      &__side {
        flex-direction: column;
        width: 100%;
      }

      &__action-btn {
        width: 100%;
      }
    }
  }
</style>
