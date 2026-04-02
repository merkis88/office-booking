<script setup>
  const props = defineProps({
    currentPage: {
      type: Number,
      required: true,
    },
    totalPages: {
      type: Number,
      required: true,
    },
  });

  const emit = defineEmits(['update:currentPage']);

  function goToPage(page) {
    if (page >= 1 && page <= props.totalPages) {
      emit('update:currentPage', page);
    }
  }
</script>

<template>
  <div v-if="totalPages > 1" class="pagination">
    <button
      class="pagination__arrow"
      :disabled="currentPage === 1"
      @click="goToPage(currentPage - 1)"
    >
      <img src="@/assets/images/icons/arrow-left.svg" alt="Назад" />
    </button>

    <button
      v-for="page in totalPages"
      :key="page"
      class="pagination__number"
      :class="{ 'pagination__number--active': currentPage === page }"
      @click="goToPage(page)"
    >
      {{ page }}
    </button>

    <button
      class="pagination__arrow"
      :disabled="currentPage === totalPages"
      @click="goToPage(currentPage + 1)"
    >
      <img src="@/assets/images/icons/arrow-right.svg" alt="Вперёд" />
    </button>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;

  .pagination {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 0.5rem;
    margin-top: 2rem;

    &__arrow {
      img {
        width: $pagination-arrow-size;
        height: $pagination-arrow-size;
      }

      &:disabled {
        opacity: 0.5;
        cursor: not-allowed;
      }
    }

    &__number {
      width: $pagination-size;
      height: $pagination-size;
      display: flex;
      align-items: center;
      justify-content: center;
      border: 1px solid $color-border;
      border-radius: $radius-xs;
      background: $color-input-bg;
      color: $color-text;
      font-size: $text-base;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.2s;

      &:hover:not(:disabled) {
        background: $color-input-bg-dark;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
      }

      &--active {
        background: $color-header-bg;
        font-weight: 600;
      }
    }
  }
</style>
