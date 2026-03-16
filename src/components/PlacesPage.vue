<script setup>
  import { ref, computed, onMounted, watch, nextTick } from 'vue';
  import { usePlacesStore } from '@/store/places';
  import { storeToRefs } from 'pinia';
  import PlaceCard from '@/components/PlaceCard.vue';
  import DatePicker from '@/components/DatePicker.vue';
  import RangeSlider from '@/components/RangeSlider.vue';

  const props = defineProps({
    type: {
      type: String,
      required: true,
      validator: (value) => ['office', 'coworking', 'meeting'].includes(value),
    },
  });

  const placesStore = usePlacesStore();
  const { places, isLoading, filters } = storeToRefs(placesStore);

  const priceRange = ref([0, 10000]);
  const selectedDate = ref('');
  const isInitialLoad = ref(true); // ✅ Флаг первой загрузки

  const pageTitle = computed(() => {
    const titles = {
      office: 'Офисы',
      coworking: 'Коворкинги',
      meeting: 'Переговорные комнаты',
    };
    return titles[props.type];
  });

  const filteredPlaces = computed(() => {
    return places.value;
  });

  const currentPage = ref(1);
  const itemsPerPage = 6;

  const totalPages = computed(() => {
    return Math.ceil(filteredPlaces.value.length / itemsPerPage);
  });

  const paginatedPlaces = computed(() => {
    const start = (currentPage.value - 1) * itemsPerPage;
    const end = start + itemsPerPage;
    return filteredPlaces.value.slice(start, end);
  });

  function goToPage(page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }
  }

  // ✅ Загрузка помещений
  async function loadPlaces() {
    const filterParams = {
      type: props.type,
      minPrice: priceRange.value[0],
      maxPrice: priceRange.value[1],
    };

    // Добавляем дату только если она выбрана
    if (selectedDate.value) {
      filterParams.date = selectedDate.value;
    }

    await placesStore.fetchPlaces(filterParams);

    // ✅ Обновляем диапазон цен ТОЛЬКО при первой загрузке
    if (isInitialLoad.value && filters.value?.price_range) {
      await nextTick(); // Ждем обновления DOM

      // ✅ Отключаем watch на время обновления
      priceRange.value = [filters.value.price_range.min_price, filters.value.price_range.max_price];

      isInitialLoad.value = false;
    }

    currentPage.value = 1;
  }

  // ✅ При смене типа помещения
  watch(
    () => props.type,
    () => {
      isInitialLoad.value = true; // Сбрасываем флаг
      priceRange.value = [0, 10000];
      selectedDate.value = '';
      loadPlaces();
    },
  );

  // ✅ Debounce для цены - НЕ срабатывает при первой загрузке
  let priceDebounceTimer = null;
  watch(
    priceRange,
    (newVal, oldVal) => {
      // ✅ Пропускаем если это первая загрузка
      if (isInitialLoad.value) {
        return;
      }

      // ✅ Пропускаем если значения не изменились
      if (newVal[0] === oldVal[0] && newVal[1] === oldVal[1]) {
        return;
      }

      clearTimeout(priceDebounceTimer);
      priceDebounceTimer = setTimeout(() => {
        loadPlaces();
      }, 500);
    },
    { deep: true },
  );

  // ✅ При выборе даты
  watch(selectedDate, (newDate, oldDate) => {
    // Пропускаем если значение не изменилось
    if (newDate === oldDate) {
      return;
    }

    loadPlaces();
  });

  onMounted(() => {
    loadPlaces();
  });
</script>

<template>
  <div class="places-page">
    <div class="places-page__container">
      <div class="places-page__header">
        <h1 class="places-page__title">{{ pageTitle }}</h1>

        <div class="places-page__filters">
          <div class="places-page__filter places-page__filter--date">
            <DatePicker v-model="selectedDate" />
          </div>

          <div class="places-page__filter places-page__filter--price">
            <div class="places-page__price-controls">
              <input
                v-model.number="priceRange[0]"
                type="number"
                class="places-page__price-input"
                :min="0"
                :max="10000"
                placeholder="От"
              />
              <RangeSlider v-model="priceRange" :min="0" :max="10000" :step="50" />
              <input
                v-model.number="priceRange[1]"
                type="number"
                class="places-page__price-input"
                :min="0"
                :max="10000"
                placeholder="До"
              />
            </div>
          </div>
        </div>
      </div>

      <div v-if="isLoading" class="places-page__loading">
        <p>Загрузка...</p>
      </div>

      <div v-else-if="paginatedPlaces.length > 0" class="places-page__grid">
        <PlaceCard v-for="place in paginatedPlaces" :key="place.id" :place="place" />
      </div>

      <div v-else class="places-page__empty">
        <p>Мест не найдено</p>
        <p v-if="selectedDate" class="places-page__empty-hint">
          Попробуйте выбрать другую дату или изменить диапазон цен
        </p>
      </div>

      <div v-if="totalPages > 1" class="places-page__pagination">
        <button
          class="places-page__pagination-btn"
          :disabled="currentPage === 1"
          @click="goToPage(currentPage - 1)"
        >
          <img src="/arrow-left.svg" alt="Назад" />
        </button>

        <button
          v-for="page in totalPages"
          :key="page"
          class="places-page__pagination-number"
          :class="{ 'places-page__pagination-number--active': currentPage === page }"
          @click="goToPage(page)"
        >
          {{ page }}
        </button>

        <button
          class="places-page__pagination-btn"
          :disabled="currentPage === totalPages"
          @click="goToPage(currentPage + 1)"
        >
          <img src="/arrow-right.svg" alt="Вперед" />
        </button>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;
  @use '@/assets/styles/mixins' as *;

  .places-page {
    min-height: 100vh;
    padding: 4rem 2rem;

    &__container {
      @include container;
    }

    &__header {
      margin-bottom: 3rem;
    }

    &__title {
      font-family: $font-title;
      font-size: $text-3xl;
      font-weight: 500;
      color: $color-text;
      margin-bottom: 2rem;
      text-align: start;
    }

    &__filters {
      display: flex;
      gap: 2rem;
      align-items: flex-start;
      flex-direction: column;
    }

    &__filter {
      display: flex;
      flex-direction: column;
      gap: 1rem;

      &--date {
        min-width: 200px;
      }

      &--price {
        flex: 1;
        max-width: 1000px;
      }
    }

    &__price-controls {
      display: flex;
      gap: 1rem;
      align-items: center;
    }

    &__price-input {
      width: 120px;
      padding: 0.75rem 1rem;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      background: $color-input-bg;
      font-size: $text-base;
      color: $color-text;
      text-align: center;

      &:focus {
        outline: none;
        border-color: $color-text;
        box-shadow: 0 0 0 3px rgba($color-text, 0.1);
      }

      &::placeholder {
        color: rgba($color-text, 0.5);
      }

      &::-webkit-outer-spin-button,
      &::-webkit-inner-spin-button {
        -webkit-appearance: none;
        margin: 0;
      }

      &[type='number'] {
        -moz-appearance: textfield;
      }
    }

    &__grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
      gap: 2rem;
      margin-bottom: 3rem;
    }

    &__loading,
    &__empty {
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      min-height: 400px;
      font-size: $text-lg;
      color: $color-text;
      gap: 1rem;
    }

    &__empty-hint {
      font-size: $text-base;
      color: rgba($color-text, 0.6);
    }

    &__pagination {
      display: flex;
      justify-content: center;
      align-items: center;
      gap: 0.5rem;
    }

    &__pagination-btn {
      img {
        width: 2.5rem;
        height: 2.5rem;
      }

      &:hover:not(:disabled) {
        background: $color-input-bg-dark;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
      }

      &:disabled {
        opacity: 0.5;
        cursor: not-allowed;
      }
    }

    &__pagination-number {
      width: 2.5rem;
      height: 2.5rem;
      display: flex;
      align-items: center;
      justify-content: center;
      border: 1px solid $color-border;
      border-radius: $radius-xs;
      background: $color-input-bg;
      color: $color-text;
      font-size: $text-base;
      cursor: pointer;
      transition: all 0.2s;
      font-weight: 500;

      &:hover {
        background: $color-input-bg-dark;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
      }

      &--active {
        background: $color-header-bg;
        font-weight: 600;
        border-color: $color-text;
      }
    }

    @media (max-width: 768px) {
      padding: 2rem 1rem;

      &__title {
        font-size: $text-2xl;
      }

      &__filters {
        flex-direction: column;
      }

      &__filter {
        width: 100%;

        &--date,
        &--price {
          max-width: 100%;
        }
      }

      &__price-controls {
        flex-wrap: wrap;
      }

      &__grid {
        grid-template-columns: 1fr;
      }
    }
  }
</style>
