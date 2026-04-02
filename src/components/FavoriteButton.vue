<script setup>
  import { computed, ref } from 'vue';
  import { useFavoritesStore } from '@/store/favorites';
  import heartFilledUrl from '@/assets/images/icons/heart-filled.svg';
  import heartEmptyUrl from '@/assets/images/icons/heart-empty.svg';

  const props = defineProps({
    placeId: {
      type: Number,
      required: true,
    },
  });

  const favoritesStore = useFavoritesStore();
  const isFav = computed(() => favoritesStore.isFavorite(props.placeId));
  const isToggling = ref(false);

  async function toggle() {
    if (isToggling.value) return;
    isToggling.value = true;
    try {
      await favoritesStore.toggleFavorite(props.placeId);
    } finally {
      isToggling.value = false;
    }
  }
</script>

<template>
  <button
    class="favorite-btn"
    :class="{ 'favorite-btn--active': isFav }"
    :disabled="isToggling"
    aria-label="Избранное"
    @click.stop="toggle"
  >
    <img :src="isFav ? heartFilledUrl : heartEmptyUrl" alt="" />
  </button>
</template>

<style lang="scss" scoped>
  .favorite-btn {
    background: none;
    border: none;
    cursor: pointer;
    padding: 0.25rem;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: transform 0.2s;

    img {
      width: 2.25rem;
      height: 2.25rem;
    }

    &:hover:not(:disabled) {
      transform: scale(1.1);
    }

    &:disabled {
      opacity: 0.5;
      cursor: not-allowed;
    }
  }
</style>
