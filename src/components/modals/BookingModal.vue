<script setup>
  import { ref, computed, watch } from 'vue';
  import axios from 'axios';
  import { useAuthStore } from '@/store/auth';

  const authStore = useAuthStore();

  const props = defineProps({
    slots: Array,
    place: Object,
    date: String,
    modelValue: Boolean,
  });

  const emit = defineEmits(['close', 'confirm', 'update:modelValue']);

  const screen = ref('slots');
  const isLoading = ref(false);

  const startIndex = ref(null);
  const endIndex = ref(null);

  const sortedSlots = computed(() => {
    if (!props.slots) return [];
    return [...props.slots].sort((a, b) => a.start.localeCompare(b.start));
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

  const selectedSlots = computed(() => {
    if (startIndex.value === null) return [];

    if (endIndex.value === null) {
      return [sortedSlots.value[startIndex.value]];
    }

    const min = Math.min(startIndex.value, endIndex.value);
    const max = Math.max(startIndex.value, endIndex.value);

    return sortedSlots.value.slice(min, max + 1);
  });

  const selectedStart = computed(() => selectedSlots.value[0]);

  const selectedEnd = computed(() => {
    return selectedSlots.value[selectedSlots.value.length - 1];
  });

  function addOneHour(time) {
    const [h, m] = time.split(':');
    const hour = String(Number(h) + 1).padStart(2, '0');
    return `${hour}:${m}`;
  }

  const bookingTime = computed(() => {
    if (!selectedStart.value) return '';

    const start = selectedStart.value.start;
    const end = addOneHour(selectedEnd.value.start);

    return `${start} - ${end}`;
  });

  const formattedDate = computed(() => {
    if (!props.date) return '';

    const d = new Date(props.date);

    return d.toLocaleDateString('ru-RU', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
    });
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

    return `${year}-${month}-${day}T${hour}:${min}:00+00:00`;
  }

  async function confirmBooking() {
    if (isLoading.value) return;

    isLoading.value = true;

    const startTime = formatDateTime(props.date, selectedStart.value.start);
    const endTime = formatDateTime(props.date, addOneHour(selectedEnd.value.start));

    const body = {
      place_id: props.place.id,
      start_time: startTime,
      end_time: endTime,
      pass_type: 'qr',
      user_id: authStore.user?.id,
    };

    try {
      const { data } = await axios.post('/api/bookings', body);

      emit('confirm', data.data);
      emit('update:modelValue', false);
    } catch (error) {
      console.error(error);

      if (error.response?.data?.message) {
        alert(error.response.data.message);
      } else {
        alert('Ошибка бронирования');
      }
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
  <div v-if="modelValue" class="booking-modal">
    <div class="booking-modal__box">
      <!-- экран выбора слотов -->
      <template v-if="screen === 'slots'">
        <button class="booking-modal__back" @click="emit('update:modelValue', false)">
          <img src="/arrow-left.svg" alt="" />
        </button>

        <div class="booking-modal__slots">
          <button
            v-for="(slot, index) in sortedSlots"
            :key="slot.start"
            class="booking-modal__slot"
            :class="{ active: isSelected(index) }"
            @click="toggleSlot(index)"
          >
            {{ slot.start }}
          </button>
        </div>

        <button
          class="booking-modal__confirm"
          :disabled="!selectedSlots.length"
          @click="goToConfirm"
        >
          Забронировать
        </button>
      </template>

      <!-- экран подтверждения -->
      <template v-else>
        <h2 class="booking-modal__title">Подтверждение</h2>

        <p class="booking-modal__subtitle">Проверьте правильность данных</p>

        <p class="booking-modal__info">{{ formattedDate }}, {{ bookingTime }}</p>

        <p class="booking-modal__info">
          {{ place?.name }}
        </p>

        <p class="booking-modal__info">Вместимость: {{ place?.capacity }}</p>

        <div class="booking-modal__actions">
          <button class="booking-modal__btn" :disabled="isLoading" @click="confirmBooking">
            {{ isLoading ? 'Бронирование...' : 'Подтвердить' }}
          </button>

          <button class="booking-modal__btn" :disabled="isLoading" @click="backToSlots">
            Отмена
          </button>
        </div>
      </template>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  .booking-modal {
    position: fixed;
    inset: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    background: rgba(0, 0, 0, 0.25);
    z-index: 1000;

    &__box {
      background: #c3ced7;
      border-radius: 24px;
      border: 2px solid #6b7d8c;
      padding: 28px 32px;
      width: 520px;
      max-width: 90vw;
    }

    &__back {
      background: none;
      border: none;
      padding: 0;
      cursor: pointer;

      img {
        width: 36px;
        height: 36px;
        display: block;
      }
    }

    &__slots {
      display: grid;
      grid-template-columns: repeat(5, 1fr);
      gap: 16px 24px;
      margin-bottom: 28px;
    }

    &__slot {
      font-size: 22px;
      border: none;
      background: transparent;
      cursor: pointer;
      padding: 6px 0;
      border-radius: 6px;
      transition: 0.15s;

      &:hover {
        background: rgba(0, 0, 0, 0.08);
      }

      &.active {
        background: #8ea3b5;
      }
    }

    &__confirm {
      display: block;
      margin: auto;
      padding: 10px 28px;
      font-size: 20px;
      border-radius: 8px;
      border: 2px solid #333;
      cursor: pointer;
      background: transparent;
      transition: 0.15s;

      &:hover {
        background: #8ea3b5;
        color: white;
      }
    }
  }

  .booking-modal {
    animation: fadeIn 0.2s ease;

    &__box {
      animation: scaleIn 0.2s ease;
    }

    &__title {
      font-size: 32px;
      text-align: center;
      margin-bottom: 16px;
    }

    &__subtitle {
      text-align: center;
      margin-bottom: 24px;
    }

    &__info {
      text-align: center;
      font-size: 20px;
      margin-bottom: 12px;
    }

    &__actions {
      display: flex;
      justify-content: center;
      gap: 40px;
      margin-top: 30px;
    }

    &__btn {
      padding: 12px 30px;
      border: 1px solid black;
      border-radius: 10px;
      background: none;
      cursor: pointer;
    }

    &__btn:disabled {
      opacity: 0.6;
      cursor: not-allowed;
    }
  }

  @keyframes fadeIn {
    from {
      opacity: 0;
    }
    to {
      opacity: 1;
    }
  }

  @keyframes scaleIn {
    from {
      transform: scale(0.9);
      opacity: 0;
    }
    to {
      transform: scale(1);
      opacity: 1;
    }
  }
</style>
