<script setup>
  import { computed, nextTick, onMounted, ref, watch } from 'vue';
  import { usePlacesStore } from '@/store/places';
  import { storeToRefs } from 'pinia';
  import PlaceCard from '@/components/PlaceCard.vue';
  import DatePicker from '@/components/DatePicker.vue';
  import RangeSlider from '@/components/RangeSlider.vue';
  import BookingModal from '@/components/modals/BookingModal.vue';
  import AppPagination from '@/components/AppPagination.vue';
  import ArchiveConfirmModal from "@/components/modals/ArchiveConfirmModal.vue";

  const props = defineProps({
    type: {
      type: String,
      required: true,
      validator: (value) => ['office', 'coworking', 'meeting'].includes(value),
    },
  });

  const placesStore = usePlacesStore();
  const { places, isLoading, filters } = storeToRefs(placesStore);

  const priceRange = ref([0, 6000]);
  const selectedDate = ref(new Date().toISOString().split('T')[0]);
  const isInitialLoad = ref(true);
  const isPriceRangeUpdating = ref(false);
  const showArchiveModal = ref(false);
  const placeToArchive = ref(null);

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

  async function loadPlaces() {
    const filterParams = {
      type: props.type,
      minPrice: priceRange.value[0],
      maxPrice: priceRange.value[1],
    };

    if (selectedDate.value && selectedDate.value.trim() !== '') {
      filterParams.date = selectedDate.value;
    }

    await placesStore.fetchPlaces(filterParams);

    if (isInitialLoad.value && filters.value?.price_range) {
      isPriceRangeUpdating.value = true;

      await nextTick();

      priceRange.value = [filters.value.price_range.min_price, filters.value.price_range.max_price];

      isInitialLoad.value = false;

      await nextTick();
      setTimeout(() => {
        isPriceRangeUpdating.value = false;
      }, 100);
    }

    currentPage.value = 1;
  }

  const errorMessage = ref('');
  const showBookingModal = ref(false);
  const selectedSlots = ref([]);
  const selectedPlace = ref(null);

  function openBookingModal(data) {
    const { place, range, availableSlots } = data;

    selectedSlots.value = availableSlots.filter(
      (slot) => slot.start >= range.start && slot.end <= range.end,
    );
    selectedPlace.value = place;

    showBookingModal.value = true;
  }

  function createBooking(booking) {
    loadPlaces();
  }

  async function handleArchivePlace(placeId, force = false) {
      errorMessage.value = '';


      try {
          const result = await placesStore.archivePlace(placeId, force);


          if (!result.success) {
              if (result.hasBookings) {
                  placeToArchive.value = placeId;
                  showArchiveModal.value = true;
                  return result;
              } else {
                  errorMessage.value = result.error;
              }
          } else {
              await loadPlaces();
          }
      } catch (error) {
          console.error('Ошибка архивации:', error);
          errorMessage.value = 'Произошла ошибка при архивации помещения';
      }
  }

  async function confirmArchiveWithForce() {

      if (!placeToArchive.value) {
          return;
      }

      showArchiveModal.value = false;
      errorMessage.value = '';

      const result = await placesStore.archivePlace(placeToArchive.value, true);


      if (result.success) {
          await loadPlaces();
      } else {
          errorMessage.value = result.error || 'Не удалось архивировать помещение';
      }

      placeToArchive.value = null;
  }

  function cancelArchive() {
      showArchiveModal.value = false;
      placeToArchive.value = null;
  }

  watch(
    () => props.type,
    () => {
      isInitialLoad.value = true;
      isPriceRangeUpdating.value = false;
      priceRange.value = [0, 6000];
      selectedDate.value = '';
      loadPlaces();
    },
  );

  let priceDebounceTimer = null;
  watch(
    priceRange,
    (newVal, oldVal) => {
      if (isInitialLoad.value) {
        return;
      }

      if (isPriceRangeUpdating.value) {
        return;
      }

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

  watch(selectedDate, (newDate, oldDate) => {
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
    <ArchiveConfirmModal
        v-model="showArchiveModal"
        @confirm="confirmArchiveWithForce"
        @cancel="cancelArchive"
    />

  <BookingModal
    v-model="showBookingModal"
    :slots="selectedSlots"
    :place="selectedPlace"
    :date="selectedDate"
    @close="showBookingModal = false"
    @confirm="createBooking"
  />
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
              <RangeSlider v-model="priceRange" :min="0" :max="6000" :step="50" />
              <input
                v-model.number="priceRange[1]"
                type="number"
                class="places-page__price-input"
                :min="0"
                :max="6000"
                placeholder="До"
              />
            </div>
          </div>
        </div>
      </div>


      <p v-if="errorMessage" class="error-message">{{ errorMessage }}</p>

      <div v-if="isLoading" class="loading">
        <div class="spinner"></div>
      </div>

      <div v-else-if="paginatedPlaces.length > 0" class="places-page__grid">
        <PlaceCard
          v-for="place in paginatedPlaces"
          :key="place.id"
          :place="place"
          @select-slot="openBookingModal"
          @archive-place="handleArchivePlace"
        />
      </div>

      <div v-else class="empty-state">
        <p>Помещения не найдены</p>
        <p v-if="selectedDate" class="empty-state__hint">
          Попробуйте выбрать другую дату или изменить диапазон цен
        </p>
      </div>

      <AppPagination
        v-if="!isLoading"
        :current-page="currentPage"
        :total-pages="totalPages"
        @update:current-page="goToPage"
      />
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
      text-align: center;
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
      align-items: start;
    }

    &__grid > * {
      display: flex;
      flex-direction: column;
      height: 100%;
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
