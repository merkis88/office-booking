<script setup>
  import { ref, computed, watch } from 'vue';
  import { useBookingsStore } from '@/store/bookings';
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
  const isSubmitting = ref(false);
  const error = ref('');

  const newDate = ref('');
  const newStartTime = ref('');
  const newEndTime = ref('');

  watch(
    () => props.modelValue,
    (isOpen) => {
      if (isOpen && props.booking) {
        const start = new Date(props.booking.start_time);
        const end = new Date(props.booking.end_time);
        newDate.value = start.toISOString().slice(0, 10);
        newStartTime.value = start.toLocaleTimeString('ru-RU', {
          hour: '2-digit',
          minute: '2-digit',
          hour12: false,
        });
        newEndTime.value = end.toLocaleTimeString('ru-RU', {
          hour: '2-digit',
          minute: '2-digit',
          hour12: false,
        });
        error.value = '';
      }
    },
  );

  const currentFormattedDate = computed(() => {
    if (!props.booking) return '';
    return new Date(props.booking.start_time).toLocaleDateString('ru-RU');
  });

  const currentFormattedTime = computed(() => {
    if (!props.booking) return '';
    const start = new Date(props.booking.start_time).toLocaleTimeString('ru-RU', {
      hour: '2-digit',
      minute: '2-digit',
    });
    const end = new Date(props.booking.end_time).toLocaleTimeString('ru-RU', {
      hour: '2-digit',
      minute: '2-digit',
    });
    return `${start} - ${end}`;
  });

  const isActiveStatus = computed(() => {
    return props.booking?.status === 'active';
  });

  const todayStr = computed(() => {
    return new Date().toISOString().slice(0, 10);
  });

  const validationError = computed(() => {
    if (!newDate.value || !newStartTime.value || !newEndTime.value) {
      return 'Заполните все поля';
    }
    if (newDate.value < todayStr.value) {
      return 'Дата не может быть в прошлом';
    }
    if (newStartTime.value >= newEndTime.value) {
      return 'Время окончания должно быть позже времени начала';
    }
    return '';
  });

  const canSubmit = computed(() => {
    return !validationError.value && !isSubmitting.value;
  });

  async function handleSubmit() {
    if (!canSubmit.value || !props.booking) return;

    isSubmitting.value = true;
    error.value = '';

    try {
      const start_time = `${newDate.value}T${newStartTime.value}:00+00:00`;
      const end_time = `${newDate.value}T${newEndTime.value}:00+00:00`;

      await bookingsStore.rescheduleBooking(props.booking.id, {
        start_time,
        end_time,
      });
      emit('rescheduled');
      emit('update:modelValue', false);
    } catch (e) {
      if (e.response?.status === 422) {
        const msg = e.response.data?.message || '';
        if (msg.toLowerCase().includes('overlap') || msg.toLowerCase().includes('пересек')) {
          error.value = 'Выбранное время пересекается с другим бронированием';
        } else {
          error.value = msg || 'Не удалось перенести бронирование';
        }
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
</script>

<template>
  <BaseModal
    :model-value="modelValue"
    title="Перенести бронирование"
    max-width="520px"
    :close-on-backdrop="true"
    @update:model-value="handleClose"
  >
    <div class="reschedule-modal">
      <template v-if="booking">
        <div class="reschedule-modal__current">
          <span class="reschedule-modal__label">Текущее:</span>
          <span class="reschedule-modal__value">
            {{ currentFormattedDate }}, {{ currentFormattedTime }}
          </span>
        </div>

        <div class="reschedule-modal__form">
          <div class="reschedule-modal__field">
            <label class="reschedule-modal__field-label">Новая дата:</label>
            <input
              v-model="newDate"
              type="date"
              class="reschedule-modal__input"
              :min="todayStr"
            />
          </div>

          <div class="reschedule-modal__field">
            <label class="reschedule-modal__field-label">Новое время начала:</label>
            <input
              v-model="newStartTime"
              type="time"
              class="reschedule-modal__input"
              step="3600"
            />
          </div>

          <div class="reschedule-modal__field">
            <label class="reschedule-modal__field-label">Новое время окончания:</label>
            <input
              v-model="newEndTime"
              type="time"
              class="reschedule-modal__input"
              step="3600"
            />
          </div>
        </div>

        <p v-if="isActiveStatus" class="reschedule-modal__notice">
          После переноса бронирование потребует повторного подтверждения (статус изменится на "ожидает").
        </p>

        <p v-if="error" class="reschedule-modal__error">{{ error }}</p>
        <p
          v-else-if="validationError && (newDate || newStartTime || newEndTime)"
          class="reschedule-modal__validation"
        >
          {{ validationError }}
        </p>

        <div class="reschedule-modal__actions">
          <button
            class="reschedule-modal__btn reschedule-modal__btn--primary"
            :disabled="!canSubmit"
            @click="handleSubmit"
          >
            {{ isSubmitting ? 'Перенос...' : 'Перенести' }}
          </button>
          <button
            class="reschedule-modal__btn"
            :disabled="isSubmitting"
            @click="handleClose"
          >
            Отмена
          </button>
        </div>
      </template>
    </div>
  </BaseModal>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;

  .reschedule-modal {
    &__current {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      margin-bottom: 1.5rem;
      padding: 0.75rem 1rem;
      background: $color-input-bg;
      border-radius: $radius-sm;
    }

    &__label {
      font-size: $text-base;
      font-weight: 500;
      color: rgba($color-text, 0.6);
    }

    &__value {
      font-size: $text-base;
      color: $color-text;
      font-weight: 500;
    }

    &__form {
      display: flex;
      flex-direction: column;
      gap: 1rem;
      margin-bottom: 1.5rem;
    }

    &__field {
      display: flex;
      flex-direction: column;
      gap: 0.375rem;
    }

    &__field-label {
      font-size: $text-sm;
      font-weight: 500;
      color: $color-text;
    }

    &__input {
      padding: 0.625rem 0.75rem;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      background: $color-input-bg;
      font-size: $text-base;
      outline: none;
      transition: 0.2s;

      &:focus {
        background: $color-input-bg-dark;
      }
    }

    &__notice {
      font-size: $text-sm;
      color: #92400e;
      background: #fef3c7;
      padding: 0.5rem 1rem;
      border-radius: $radius-sm;
      margin-bottom: 1rem;
    }

    &__error {
      font-size: $text-sm;
      color: #991b1b;
      background: #fee2e2;
      padding: 0.5rem 1rem;
      border-radius: $radius-sm;
      margin-bottom: 1rem;
    }

    &__validation {
      font-size: $text-sm;
      color: #92400e;
      margin-bottom: 1rem;
    }

    &__actions {
      display: flex;
      justify-content: center;
      gap: 1rem;
    }

    &__btn {
      padding: 0.625rem 1.5rem;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      background: $color-input-bg;
      font-size: $text-base;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.2s;

      &:hover {
        background: $color-input-bg-dark;
        transform: translateY(-1px);
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
      }

      &:active {
        transform: translateY(0);
      }

      &:disabled {
        opacity: 0.6;
        cursor: not-allowed;
        transform: none;
        box-shadow: none;
      }

      &--primary {
        background: $color-header-bg;
        color: $color-text;

        &:hover {
          background: $color-footer-bg;
        }
      }
    }
  }
</style>
