<script setup>
  import { ref, computed } from 'vue';
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

  const emit = defineEmits(['update:modelValue', 'cancelled']);

  const bookingsStore = useBookingsStore();
  const isSubmitting = ref(false);
  const error = ref('');

  const formattedDate = computed(() => {
    if (!props.booking) return '';
    return new Date(props.booking.start_time).toLocaleDateString('ru-RU');
  });

  const formattedTime = computed(() => {
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
</script>

<template>
  <BaseModal
    :model-value="modelValue"
    title="Отменить бронирование?"
    max-width="480px"
    :close-on-backdrop="true"
    @update:model-value="handleClose"
  >
    <div class="cancel-modal">
      <template v-if="booking">
        <div class="cancel-modal__info">
          <p class="cancel-modal__place">{{ booking.place?.name }}</p>
          <p class="cancel-modal__time">
            {{ formattedDate }}, {{ formattedTime }}
          </p>
        </div>

        <p class="cancel-modal__warning">
          Это действие нельзя отменить.
        </p>

        <p v-if="error" class="cancel-modal__error">{{ error }}</p>

        <div class="cancel-modal__actions">
          <button
            class="cancel-modal__btn cancel-modal__btn--danger"
            :disabled="isSubmitting"
            @click="handleConfirm"
          >
            {{ isSubmitting ? 'Отмена...' : 'Отменить бронирование' }}
          </button>
          <button
            class="cancel-modal__btn"
            :disabled="isSubmitting"
            @click="handleClose"
          >
            Нет
          </button>
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
      font-weight: 600;
      color: $color-text;
      margin-bottom: 0.25rem;
    }

    &__time {
      font-size: $text-base;
      color: rgba($color-text, 0.7);
    }

    &__warning {
      font-size: $text-sm;
      color: #991b1b;
      margin-bottom: 1.5rem;
    }

    &__error {
      font-size: $text-sm;
      color: #991b1b;
      background: #fee2e2;
      padding: 0.5rem 1rem;
      border-radius: $radius-sm;
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

      &--danger {
        color: #991b1b;
        border-color: #991b1b;

        &:hover {
          background: #fee2e2;
        }
      }
    }
  }
</style>
