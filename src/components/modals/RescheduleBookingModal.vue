<script setup>
  import { ref, computed, watch } from 'vue';
  import { useBookingsStore } from '@/store/bookings';
  import { formatBookingDate } from '@/utils/dateFormat';
  import axios from 'axios';
  import BaseModal from '@/components/modals/BaseModal.vue';

  const props = defineProps({
    booking: {
      type: Object,
      default: null,
    },
    modelValue: {
      type: Boolean,
      default: false,
    },
  });

  const emit = defineEmits(['update:modelValue', 'rescheduled']);

  const bookingsStore = useBookingsStore();

  const screen = ref('intervals'); // 'intervals' | 'slots' | 'confirm'
  const isLoading = ref(false);
  const isSlotsLoading = ref(false);
  const isSubmitting = ref(false);
  const errorMessage = ref('');

  // Данные слотов
  const availableSlots = ref([]);
  const mergedIntervals = ref([]);
  const selectedInterval = ref(null);

  // Данные для экрана 2 (выбор часа начала)
  const timePoints = ref([]);
  const selectedStartIndex = ref(null);

  const screenTitle = computed(() => {
    if (screen.value === 'intervals') return 'Перенос брони';
    if (screen.value === 'slots') return 'Выберите время';
    return 'Подтверждение';
  });

  // Длительность текущей брони в часах (фиксирована, менять нельзя)
  const bookingDurationHours = computed(() => {
    if (!props.booking) return 1;
    const start = new Date(props.booking.start_time);
    const end = new Date(props.booking.end_time);
    return Math.round((end - start) / (1000 * 60 * 60));
  });

  watch(
    () => props.modelValue,
    async (isOpen) => {
      if (isOpen && props.booking) {
        screen.value = 'intervals';
        selectedInterval.value = null;
        selectedStartIndex.value = null;
        errorMessage.value = '';
        await loadSlots();
      }
    },
  );

  async function loadSlots() {
    isSlotsLoading.value = true;
    try {
      const placeId = props.booking.place_id || props.booking.place?.id;
      const date = props.booking.start_time.slice(0, 10);

      const { data } = await axios.get(`/api/places/${placeId}`, {
        params: { date },
      });

      const placeData = data.data ?? data;
      const freeSlots = placeData.available_slots || [];

      // Добавить время текущей брони к свободным слотам.
      // Времена в БД и слотах — в одном формате (без конвертации TZ).
      // Парсим часы напрямую из ISO-строки.
      const bookingSlots = [];
      const startH = parseInt(props.booking.start_time.slice(11, 13));
      const endH = parseInt(props.booking.end_time.slice(11, 13));

      for (let h = startH; h < endH; h++) {
        bookingSlots.push({
          start: `${String(h).padStart(2, '0')}:00`,
          end: `${String(h + 1).padStart(2, '0')}:00`,
        });
      }

      const allSlots = [...freeSlots, ...bookingSlots];

      // Сортировать и мержить в интервалы
      availableSlots.value = allSlots;
      mergedIntervals.value = mergeSlots(allSlots);
    } catch (e) {
      errorMessage.value = 'Не удалось загрузить доступное время';
    } finally {
      isSlotsLoading.value = false;
    }
  }

  function mergeSlots(slots) {
    if (!slots.length) return [];

    const sorted = [...slots].sort((a, b) => a.start.localeCompare(b.start));
    const result = [];
    let current = { start: sorted[0].start, end: sorted[0].end };

    for (let i = 1; i < sorted.length; i++) {
      const slot = sorted[i];
      if (slot.start <= current.end) {
        if (slot.end > current.end) current.end = slot.end;
      } else {
        result.push({ ...current });
        current = { start: slot.start, end: slot.end };
      }
    }
    result.push({ ...current });

    return result.map(s => ({
      ...s,
      label: `${s.start} - ${s.end}`,
    }));
  }

  function selectInterval(interval) {
    selectedInterval.value = interval;

    // Генерируем часовые точки внутри интервала,
    // но ТОЛЬКО те, куда помещается вся длительность брони
    const points = [];
    let [h, m] = interval.start.split(':').map(Number);
    const [endH, endM] = interval.end.split(':').map(Number);
    const endMinutes = endH * 60 + endM;
    const duration = bookingDurationHours.value;

    while ((h + duration) * 60 + m <= endMinutes) {
      points.push(`${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`);
      h += 1; // шаг 1 час
    }

    timePoints.value = points;
    selectedStartIndex.value = null;
    screen.value = 'slots';
  }

  function selectHour(index) {
    selectedStartIndex.value = index;
  }

  function isSelected(index) {
    if (selectedStartIndex.value === null) return false;
    // Подсветить все часы от выбранного до выбранного + длительность
    return index >= selectedStartIndex.value
      && index < selectedStartIndex.value + bookingDurationHours.value;
  }

  const isValidSelection = computed(() => {
    return selectedStartIndex.value !== null;
  });

  const bookingTime = computed(() => {
    if (!isValidSelection.value) return '';
    const startTime = timePoints.value[selectedStartIndex.value];
    // Вычислить end time: start + duration часов
    const [h, m] = startTime.split(':').map(Number);
    const endH = h + bookingDurationHours.value;
    const endTime = `${String(endH).padStart(2, '0')}:${String(m).padStart(2, '0')}`;
    return `${startTime} - ${endTime}`;
  });

  // Computed для start_time и end_time при отправке на API
  const newStartTime = computed(() => {
    if (!isValidSelection.value) return '';
    return timePoints.value[selectedStartIndex.value];
  });

  const newEndTime = computed(() => {
    if (!isValidSelection.value) return '';
    const [h, m] = newStartTime.value.split(':').map(Number);
    const endH = h + bookingDurationHours.value;
    return `${String(endH).padStart(2, '0')}:${String(m).padStart(2, '0')}`;
  });

  const bookingDate = computed(() => {
    if (!props.booking) return '';
    return props.booking.start_time.slice(0, 10);
  });

  const formattedDate = computed(() => {
    if (!bookingDate.value) return '';
    return formatBookingDate(props.booking.start_time);
  });

  async function confirmReschedule() {
    if (isSubmitting.value || !isValidSelection.value) return;

    isSubmitting.value = true;
    errorMessage.value = '';

    const start_time = `${bookingDate.value}T${newStartTime.value}:00+00:00`;
    const end_time = `${bookingDate.value}T${newEndTime.value}:00+00:00`;

    try {
      await bookingsStore.rescheduleBooking(props.booking.id, {
        start_time,
        end_time,
      });
      emit('rescheduled');
      emit('update:modelValue', false);
    } catch (e) {
      if (e.response?.status === 422) {
        errorMessage.value = e.response.data?.message || 'Выбранное время занято';
        screen.value = 'intervals';
      } else {
        errorMessage.value = 'Произошла ошибка. Попробуйте позже.';
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  function goToConfirm() {
    screen.value = 'confirm';
  }

  function handleBack() {
    errorMessage.value = '';
    if (screen.value === 'confirm') {
      screen.value = 'slots';
    } else if (screen.value === 'slots') {
      screen.value = 'intervals';
    } else {
      emit('update:modelValue', false);
    }
  }
</script>

<template>
  <BaseModal
    :model-value="modelValue"
    :title="screenTitle"
    max-width="520px"
    :show-close-button="false"
    :close-on-backdrop="true"
    @update:model-value="$emit('update:modelValue', $event)"
  >
    <button class="reschedule__back" @click="handleBack">
      <img src="@/assets/images/icons/arrow-left.svg" alt="Назад" />
    </button>

    <div class="reschedule__content">
      <!-- Экран 1: Выбор интервала -->
      <div v-if="screen === 'intervals'">
        <p class="reschedule__subtitle">Выберите пожалуйста подходящее время</p>

        <div v-if="isSlotsLoading" class="reschedule__loading">Загрузка...</div>

        <div v-else-if="!mergedIntervals.length" class="reschedule__empty">
          Нет доступного времени для переноса
        </div>

        <div v-else class="reschedule__intervals">
          <button
            v-for="interval in mergedIntervals"
            :key="interval.start"
            class="reschedule__interval-btn"
            @click="selectInterval(interval)"
          >
            {{ interval.label }}
          </button>
        </div>
      </div>

      <!-- Экран 2: Выбор часа начала (длительность фиксирована) -->
      <div v-else-if="screen === 'slots'">
        <p class="reschedule__subtitle">
          Выберите время начала (длительность: {{ bookingDurationHours }} ч.)
        </p>

        <div
          class="reschedule__slots"
          :style="{ gridTemplateColumns: `repeat(${Math.min(timePoints.length, 5)}, auto)` }"
        >
          <button
            v-for="(time, index) in timePoints"
            :key="time"
            class="reschedule__slot"
            :class="{ active: isSelected(index) }"
            @click="selectHour(index)"
          >
            {{ time }}
          </button>
        </div>
      </div>

      <!-- Экран 3: Подтверждение -->
      <div v-else class="reschedule__confirm-screen">
        <p class="reschedule__subtitle">Проверьте правильность данных</p>
        <p class="reschedule__info">{{ formattedDate }}, {{ bookingTime }}</p>
        <p class="reschedule__info">{{ booking?.place?.name }}</p>
        <p class="reschedule__info">Вместимость: {{ booking?.place?.capacity }}</p>
      </div>

      <p v-if="errorMessage" class="reschedule__error">{{ errorMessage }}</p>
    </div>

    <template #footer>
      <div v-if="screen === 'slots'">
        <button
          class="reschedule__btn"
          :disabled="!isValidSelection"
          @click="goToConfirm"
        >
          Далее
        </button>
      </div>

      <div v-else-if="screen === 'confirm'">
        <button
          class="reschedule__btn"
          :disabled="isSubmitting"
          @click="confirmReschedule"
        >
          {{ isSubmitting ? 'Перенос...' : 'Перенести' }}
        </button>
      </div>
    </template>
  </BaseModal>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;

  .reschedule {
    &__back {
      position: absolute;
      top: 1rem;
      left: 1rem;
      width: 2.5rem;
      height: 2.5rem;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      transition: 0.2s;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      background: transparent;

      &:hover {
        background: $color-input-bg-dark;
      }

      img {
        width: 1.5rem;
        height: 1.5rem;
      }
    }

    &__content {
      min-height: 150px;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
    }

    &__subtitle {
      text-align: center;
      margin-bottom: 1.5rem;
      font-size: $text-base;
      color: $color-text;
    }

    &__loading,
    &__empty {
      text-align: center;
      padding: 2rem;
      color: rgba($color-text, 0.6);
    }

    &__intervals {
      display: flex;
      flex-wrap: wrap;
      gap: 1rem;
      justify-content: center;
    }

    &__interval-btn {
      padding: 0.75rem 2rem;
      font-size: $text-xl;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      background: $color-input-bg;
      cursor: pointer;
      transition: 0.2s;

      &:hover {
        background: $color-input-bg-dark;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
      }
    }

    &__slots {
      display: grid;
      gap: 12px;
      justify-content: center;
    }

    &__slot {
      font-size: $text-xl;
      background: $color-input-bg;
      cursor: pointer;
      padding: 8px;
      border-radius: $radius-sm;
      transition: 0.2s;

      &:hover {
        background: $color-input-bg-dark;
      }

      &.active {
        background: $color-header-bg;
        font-weight: 500;
      }
    }

    &__confirm-screen {
      text-align: center;
    }

    &__info {
      margin-bottom: 0.5rem;
      font-size: $text-base;
    }

    &__error {
      font-size: $text-sm;
      color: #991b1b;
      background: #fee2e2;
      padding: 0.5rem 1rem;
      border-radius: $radius-sm;
      margin-top: 1rem;
      text-align: center;
    }

    &__btn {
      font-size: $text-base;
      padding: 10px 24px;
      border-radius: $radius-sm;
      border: 1px solid $color-border;
      background: $color-input-bg;
      cursor: pointer;
      transition: 0.2s;

      &:hover {
        background: $color-input-bg-dark;
      }

      &:disabled {
        opacity: 0.6;
        cursor: not-allowed;
      }
    }
  }
</style>
