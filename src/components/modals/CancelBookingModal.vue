<script setup>
  import { ref, computed } from 'vue';
  import { useBookingsStore } from '@/store/bookings';
  import { formatBookingDate, formatBookingTime } from '@/utils/dateFormat';
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

  const emit = defineEmits(['update:modelValue', 'cancelled']);

  const bookingsStore = useBookingsStore();
  const isSubmitting = ref(false);
  const error = ref('');

  const formattedDate = computed(() => {
    if (!props.booking) return '';
    return formatBookingDate(props.booking.start_time);
  });

  const formattedTime = computed(() => {
    if (!props.booking) return '';
    const start = formatBookingTime(props.booking.start_time);
    const end = formatBookingTime(props.booking.end_time);
    return `${start} - ${end}`;
  });

  async function handleConfirm() {
    if (!props.booking) return;

    isSubmitting.value = true;
    error.value = '';

    try {
      await bookingsStore.cancelBooking(props.booking.id);
      emit('cancelled');
      emit('update:modelValue', false);
    } catch (e) {
      if (e.response?.status === 422) {
        error.value = e.response.data?.message || 'Не удалось отменить бронирование';
      } else {
        error.value = 'Произошла ошибка. Попробуйте позже.';
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  function handleClose() {
    error.value = '';
    emit('update:modelValue', false);
  }

  const placeTypeLabel = computed(() => {
    const types = {
      office: 'Офис',
      coworking: 'Коворкинга',
      meeting: 'Переговорная',
    };
    return types[props.booking.place.type];
  });
</script>

<template>
  <BaseModal
    :model-value="modelValue"
    title="Отмена брони"
    max-width="480px"
    :close-on-backdrop="true"
    :show-close-button="true"
    @update:model-value="handleClose"
    @back="handleClose"
  >
    <div class="cancel-modal">
      <template v-if="booking">
        <p class="cancel-modal__warning">Вы действительно хотите отменить бронь?</p>

        <div class="cancel-modal__info">
          <p class="cancel-modal__place">{{ placeTypeLabel }} "{{ booking.place?.name }}"</p>
          <p class="cancel-modal__time">{{ formattedDate }}, {{ formattedTime }}</p>
        </div>

        <p v-if="error" class="cancel-modal__error">{{ error }}</p>

        <div class="cancel-modal__actions">
          <button class="btn btn--danger" :disabled="isSubmitting" @click="handleConfirm">
            {{ isSubmitting ? 'Отмена...' : 'Отменить бронь' }}
          </button>
          <button class="btn" :disabled="isSubmitting" @click="handleClose">Не отменять</button>
        </div>
      </template>
    </div>
  </BaseModal>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;

  .cancel-modal {
    text-align: center;

    &__info {
      margin-bottom: 1.5rem;
    }

    &__place {
      font-size: $text-lg;
      color: $color-text;
      margin-bottom: 0.25rem;
    }

    &__time {
      font-size: $text-base;
      color: rgba($color-text, 0.7);
    }

    &__warning {
      font-size: $text-base;
      color: $color-danger;
      margin-bottom: 1rem;
    }

    &__error {
      font-size: $text-sm;
      color: $color-danger;
      background: rgba($color-danger, 0.1);
      padding: 0.5rem 1rem;
      border-radius: $radius-sm;
      margin-bottom: 1rem;
    }

    &__actions {
      display: flex;
      justify-content: center;
      gap: 1rem;
    }
  }
</style>
