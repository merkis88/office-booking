<script setup>
  import { computed } from 'vue';

  const props = defineProps({
    place: {
      type: Object,
      required: true,
    },
  });

  // Форматирование времени
  const formattedStartTime = computed(() => {
    if (!props.place.booking_start_time) return '';
    // Извлекаем время из datetime "2024-01-01 08:00:00" -> "08:00"
    const timeStr = props.place.booking_start_time;
    if (timeStr.includes(' ')) {
      return timeStr.split(' ')[1].substring(0, 5);
    }
    return timeStr.substring(0, 5);
  });

  const formattedEndTime = computed(() => {
    if (!props.place.booking_end_time) return '';
    const timeStr = props.place.booking_end_time;
    if (timeStr.includes(' ')) {
      return timeStr.split(' ')[1].substring(0, 5);
    }
    return timeStr.substring(0, 5);
  });

  // Перевод типа места
  const placeTypeLabel = computed(() => {
    const types = {
      office: 'Аренда офиса',
      coworking: 'Аренда коворкинга',
      meeting: 'Аренда переговорной',
    };
    return types[props.place.type] || props.place.type;
  });
</script>

<template>
  <div class="place-card">
    <div class="place-card__main">
      <div class="place-card__image-wrapper">
        <img
          :src="place.photo"
          :alt="place.name"
          class="place-card__image"
          @error="$event.target.src = '/placeholder.jpg'"
        />
      </div>

      <div class="place-card__content">
        <h3 class="place-card__title">{{ placeTypeLabel }}</h3>
        <p class="place-card__number">Кабинет №{{ place.number_place }}</p>
        <p class="place-card__price">Стоимость: {{ place.price }}₽</p>
        <p class="place-card__capacity">Вместимость: {{ place.capacity }} человек</p>
      </div>

      <button class="place-card__favorite" aria-label="Добавить в избранное">
        <img src="/heart-empty.svg" alt="">
      </button>
    </div>

    <div class="place-card__time">
      Допустимое время: с {{ formattedStartTime }} - {{ formattedEndTime }}
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;

  .place-card {
    overflow: hidden;
    display: flex;
    flex-direction: column;
    align-items: center;

    &__main {
      background: $color-btn-profile;
      border: 1px solid $color-border;
      border-radius: $radius-lg;
      display: flex;
      gap: 1rem;
      padding: 1.5rem;
      position: relative;
      transition: all 0.3s;
    }

    &__image-wrapper {
      position: relative;
      width: 280px;
      height: 280px;
      flex-shrink: 0;
      overflow: hidden;
      border-radius: $radius-lg;
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
      gap: 1rem;
      justify-content: center;
      align-items: stretch;
    }

    &__title {
      font-size: $text-xl;
      font-weight: 600;
      color: $color-text;
      margin: 0;
    }

    &__number {
      font-size: $text-lg;
      color: $color-text;
      margin: 0;
    }

    &__price {
      font-size: $text-lg;
      color: $color-text;
      margin: 0;
    }

    &__capacity {
      font-size: $text-lg;
      color: $color-text;
      margin: 0;
    }

    &__favorite {
      top: 2rem;
      right: 2rem;
      width: 3rem;
      height: 3rem;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      transition: all 0.2s;
      color: $color-text;

      svg {
        width: 1.5rem;
        height: 1.5rem;
      }
    }

    &__time {
      padding: 0.3rem 10rem;
      background: $color-btn-profile;
      border: 1px solid $color-border;
      border-radius: $radius-xxs;
      font-size: $text-xl;
      font-weight: 400;
      text-align: center;
      color: $color-text;
      margin-top: 10px;
      max-width: 90rem;
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

      &__favorite {
        top: 1.5rem;
        right: 1.5rem;
        width: 2.5rem;
        height: 2.5rem;

        svg {
          width: 1.25rem;
          height: 1.25rem;
        }
      }

      &__time {
        font-size: $text-base;
      }
    }
  }
</style>
