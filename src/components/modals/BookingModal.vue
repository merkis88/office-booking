<script setup>
  import { ref, computed, watch } from 'vue';
  import axios from 'axios';
  import { useAuthStore } from '@/store/auth';
  import BaseModal from '@/components/modals/BaseModal.vue';

  const authStore = useAuthStore();

  const props = defineProps({
    slots: Array,
    place: Object,
    date: String,
    modelValue: Boolean,
  });

  const emit = defineEmits(['close', 'confirm', 'update:modelValue']);

  const isConfirmScreen = computed(() => screen.value === 'confirm');

  const screen = ref('slots');
  const isLoading = ref(false);

  const startIndex = ref(null);
  const endIndex = ref(null);

  const sortedSlots = computed(() => {
    if (!props.slots) return [];
    return [...props.slots].sort((a, b) => a.start.localeCompare(b.start));
  });

  const timePoints = computed(() => {
    if (!sortedSlots.value.length) return [];

    const points = sortedSlots.value.map((s) => s.start);
    const last = sortedSlots.value[sortedSlots.value.length - 1];
    points.push(last.end);

    return points;
  });

  function toggleSlot(index) {
    if (startIndex.value === null) {
      startIndex.value = index;
      return;
    }

    if (endIndex.value === null) {
      if (index === startIndex.value) {
        startIndex.value = null;
        return;
      }

      endIndex.value = index;
      return;
    }

    startIndex.value = index;
    endIndex.value = null;
  }

  function isSelected(index) {
    if (startIndex.value === null) return false;

    if (endIndex.value === null) {
      return index === startIndex.value;
    }

    const min = Math.min(startIndex.value, endIndex.value);
    const max = Math.max(startIndex.value, endIndex.value);

    return index >= min && index <= max;
  }

  const isValidRange = computed(() => {
    return (
      startIndex.value !== null &&
      endIndex.value !== null &&
      Math.abs(endIndex.value - startIndex.value) >= 1
    );
  });

  const selectedSlots = computed(() => {
    if (startIndex.value === null) return [];

    if (endIndex.value === null) {
      return [sortedSlots.value[startIndex.value]];
    }

    const min = Math.min(startIndex.value, endIndex.value);
    const max = Math.max(startIndex.value, endIndex.value);

    return sortedSlots.value.slice(min, max + 1);
  });

  const bookingTime = computed(() => {
    if (!isValidRange.value) return '';

    const min = Math.min(startIndex.value, endIndex.value);
    const max = Math.max(startIndex.value, endIndex.value);

    return `${timePoints.value[min]} - ${timePoints.value[max]}`;
  });

  const formattedDate = computed(() => {
    if (!props.date) return '';

    return new Date(props.date).toLocaleDateString('ru-RU');
  });

  function formatDateTime(date, time) {
    const [h, m] = time.split(':');

    const d = new Date(date);
    d.setHours(Number(h));
    d.setMinutes(Number(m));
    d.setSeconds(0);

    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    const hour = String(d.getHours()).padStart(2, '0');
    const min = String(d.getMinutes()).padStart(2, '0');

    const offset = -d.getTimezoneOffset();
    const sign = offset >= 0 ? '+' : '-';
    const absOffset = Math.abs(offset);
    const offsetHours = String(Math.floor(absOffset / 60)).padStart(2, '0');
    const offsetMinutes = String(absOffset % 60).padStart(2, '0');

    return `${year}-${month}-${day}T${hour}:${min}:00${sign}${offsetHours}:${offsetMinutes}`;
  }

  async function confirmBooking() {
    if (isLoading.value) return;

    isLoading.value = true;

    const min = Math.min(startIndex.value, endIndex.value);
    const max = Math.max(startIndex.value, endIndex.value);

    const startTime = formatDateTime(props.date, timePoints.value[min]);
    const endTime = formatDateTime(props.date, timePoints.value[max]);

    const body = {
      place_id: props.place.id,
      start_time: startTime,
      end_time: endTime,
      pass_type: 'qr',
    };

    console.log(startTime, endTime);

    try {
      const { data } = await axios.post('/api/bookings', body);

      emit('confirm', data.data);
      emit('update:modelValue', false);
    } catch (error) {
      console.error(error);

      alert(error.response?.data?.message || 'Ошибка бронирования');
    } finally {
      isLoading.value = false;
    }
  }

  function goToConfirm() {
    if (!selectedSlots.value.length) return;
    screen.value = 'confirm';
  }

  function backToSlots() {
    screen.value = 'slots';
  }

  function handleBack() {
    if (isConfirmScreen.value) {
      backToSlots();
    } else {
      closeModal();
    }
  }

  function closeModal() {
    emit('update:modelValue', false);
    emit('close');
  }

  const columnsCount = computed(() => {
    return Math.min(timePoints.value.length, 5);
  });

  watch(
    () => props.modelValue,
    (open) => {
      if (!open) {
        startIndex.value = null;
        endIndex.value = null;
        screen.value = 'slots';
      }
    },
  );
</script>

<template>
  <BaseModal
    :model-value="modelValue"
    @update:model-value="$emit('update:modelValue', $event)"
    :title="screen === 'confirm' ? 'Подтверждение' : 'Выберите время'"
    max-width="520px"
    :show-close-button="false"
    :close-on-backdrop="true"
    @close="closeModal"
  >
    <button class="booking-modal__back" @click="handleBack">
      <img src="/arrow.svg" alt="Назад" />
    </button>

    <div class="booking-modal__content">
      <div v-if="screen === 'slots'">
        <div
          class="booking-modal__slots"
          :style="{ gridTemplateColumns: `repeat(${columnsCount}, auto)` }"
        >
          <button
            v-for="(time, index) in timePoints"
            :key="time"
            class="booking-modal__slot"
            :class="{ active: isSelected(index) }"
            @click="toggleSlot(index)"
          >
            {{ time }}
          </button>
        </div>
      </div>

      <div v-else class="booking-modal__confirm-screen">
        <p class="booking-modal__subtitle">Проверьте правильность данных</p>

        <p class="booking-modal__info">{{ formattedDate }}, {{ bookingTime }}</p>

        <p class="booking-modal__info">
          {{ place?.name }}
        </p>

        <p class="booking-modal__info">Вместимость: {{ place?.capacity }}</p>
      </div>
    </div>

    <template #footer>
      <div v-if="screen === 'slots'">
        <button class="booking-modal__confirm" :disabled="!isValidRange" @click="goToConfirm">
          Забронировать
        </button>
      </div>

      <div v-else class="booking-modal__actions">
        <button class="booking-modal__btn" :disabled="isLoading" @click="confirmBooking">
          {{ isLoading ? 'Бронирование...' : 'Подтвердить' }}
        </button>
      </div>
    </template>
  </BaseModal>
</template>

<style scoped lang="scss">
  @use '@/assets/styles/variables' as *;

  .booking-modal {
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

    &__confirm {
      font-size: $text-base;
      padding: 10px 24px;
      border-radius: $radius-sm;
      border: 1px solid $color-border;
      background: $color-input-bg;
      cursor: pointer;
    }

    &__confirm-screen {
      text-align: center;
    }

    &__subtitle {
      margin-bottom: 1rem;
    }

    &__info {
      margin-bottom: 0.5rem;
    }

    &__actions {
      display: flex;
      gap: 1rem;
    }

    &__content {
      min-height: 150px;
      display: flex;
      flex-direction: column;
      justify-content: center;
    }

    &__back {
      position: absolute;
      top: 1rem;
      left: 1rem;

      width: 2.5rem;
      height: 2.5rem;

      display: flex;
      align-items: center;
      justify-content: center;

      border-radius: $radius-sm;
      border: 1px solid $color-border;
      background: $color-input-bg;

      cursor: pointer;
      transition: 0.2s;

      &:hover {
        background: $color-input-bg-dark;
        transform: translateY(-2px);
      }

      img {
        width: 1.2rem;
        height: 1.2rem;
      }
    }

    &__btn {
      font-size: $text-base;
      padding: 10px 20px;
      border-radius: $radius-sm;
      border: 1px solid $color-border;
      background: $color-input-bg;
      cursor: pointer;

      &:disabled {
        opacity: 0.6;
      }
    }
  }
</style>
