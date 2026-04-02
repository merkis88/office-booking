<script setup>
  import { computed } from 'vue';
  import FavoriteButton from '@/components/FavoriteButton.vue';
  import placeholder from '@/assets/images/photos/placeholder.jpg';

  const props = defineProps({
    place: {
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
    return types[props.place.type] || props.place.type;
  });
</script>

<template>
  <div class="favorite-card">
    <div class="favorite-card__image-wrapper">
      <img
        :src="place.photo_url || placeholder"
        :alt="place.name"
        class="favorite-card__image"
        @error="(e) => { e.target.onerror = null; e.target.src = placeholder; }"
      />
    </div>

    <div class="favorite-card__content">
      <p class="favorite-card__title">{{ placeTypeLabel }} "{{ place.name }}"</p>
      <p class="favorite-card__line">Кабинет №{{ place.number_place }}</p>
      <p class="favorite-card__line">Стоимость: {{ Math.round(place.price) }} р/час</p>
      <p class="favorite-card__line">Вместимость: {{ place.capacity }} человек</p>
    </div>

    <FavoriteButton
      :place-id="place.id"
      class="favorite-card__fav-btn"
    />
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;
  @use '@/assets/styles/mixins' as *;

  .favorite-card {
    @include card-base;
    overflow: hidden;
    min-height: 200px;

    &__image-wrapper {
      @include card-image;
    }

    &__content {
      flex: 1;
      display: flex;
      flex-direction: column;
      justify-content: center;
      gap: 0.5rem;
    }

    &__title {
      font-size: $text-lg;
      font-weight: 500;
      margin: 0;
      padding-right: 3rem;
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

    @media (max-width: 640px) {
      flex-direction: column;
      min-height: auto;
    }
  }
</style>
