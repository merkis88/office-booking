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

  const emit = defineEmits(['update:modelValue', 'extended']);

  const bookingsStore = useBookingsStore();
  const isSubmitting = ref(false);
  const error = ref('');

  const selectedPreset = ref(null);
  const customMinutes = ref('');

  const presets = [
    { label: '+10 мин', value: '10m' },
    { label: '+1 час', value: '1h' },
    { label: '+1 день', value: '1d' },
  ];

  watch(
    () => props.modelValue,
    (isOpen) => {
      if (isOpen) {
        selectedPreset.value = null;
        customMinutes.value = '';
        error.value = '';
      }
    },
  );

  const currentEndTime = computed(() => {
    if (!props.booking) return '';
    return new Date(props.booking.end_time).toLocaleTimeString('ru-RU', {
      hour: '2-digit',
      minute: '2-digit',
    });
  });

  function selectPreset(preset) {
    selectedPreset.value = preset;
    customMinutes.value = '';
    error.value = '';
  }

  function onCustomMinutesInput() {
    selectedPreset.value = null;
    error.value = '';
  }

  const canSubmit = computed(() => {
    if (isSubmitting.value) return false;
    if (selectedPreset.value) return true;
    const mins = parseInt(customMinutes.value, 10);
    return mins >= 1 && mins <= 1440;
  });

  async function handleSubmit() {
    if (!canSubmit.value || !props.booking) return;

    isSubmitting.value = true;
    error.value = '';

    try {
      let payload;
      if (selectedPreset.value) {
        payload = { preset: selectedPreset.value };
      } else {
        payload = { minutes: parseInt(customMinutes.value, 10) };
      }

      await bookingsStore.extendBooking(props.booking.id, payload);
      emit('extended');
      emit('update:modelValue', false);
    } catch (e) {
      if (e.response?.status === 422) {
        const msg = e.response.data?.message || '';
        if (msg.toLowerCase().includes('overlap') || msg.toLowerCase().includes('пересек')) {
          error.value = 'Продление невозможно — пересечение с другим бронированием';
        } else if (msg.toLowerCase().includes('завершил') || msg.toLowerCase().includes('past')) {
          error.value = 'Бронирование уже завершилось';
        } else {
          error.value = msg || 'Не удалось продлить бронирование';
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
    title="Продлить бронирование"
    max-width="480px"
    :close-on-backdrop="true"
    @update:model-value="handleClose"
  >
    <div class="extend-modal">
      <template v-if="booking">
        <div class="extend-modal__info">
          <p class="extend-modal__place">{{ booking.place?.name }}</p>
          <p class="extend-modal__time">
            Текущее окончание: {{ currentEndTime }}
          </p>
        </div>

        <div class="extend-modal__section">
          <p class="extend-modal__section-label">Быстрое продление:</p>
          <div class="extend-modal__presets">
            <button
              v-for="preset in presets"
              :key="preset.value"
              class="extend-modal__preset"
              :class="{ 'extend-modal__preset--active': selectedPreset === preset.value }"
              @click="selectPreset(preset.value)"
            >
              {{ preset.label }}
            </button>
          </div>
        </div>

        <div class="extend-modal__section">
          <p class="extend-modal__section-label">Или укажите количество минут:</p>
          <div class="extend-modal__custom">
            <input
              v-model="customMinutes"
              type="number"
              min="1"
              max="1440"
              class="extend-modal__input"
              placeholder="Количество минут"
              @input="onCustomMinutesInput"
            />
            <span class="extend-modal__unit">мин</span>
          </div>
        </div>

        <p v-if="error" class="extend-modal__error">{{ error }}</p>

        <div class="extend-modal__actions">
          <button
            class="extend-modal__btn extend-modal__btn--primary"
            :disabled="!canSubmit"
            @click="handleSubmit"
          >
            {{ isSubmitting ? 'Продление...' : 'Продлить' }}
          </button>
          <button
            class="extend-modal__btn"
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

  .extend-modal {
    &__info {
      text-align: center;
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

    &__section {
      margin-bottom: 1.25rem;
    }

    &__section-label {
      font-size: $text-sm;
      font-weight: 500;
      color: $color-text;
      margin-bottom: 0.5rem;
    }

    &__presets {
      display: flex;
      gap: 0.5rem;
    }

    &__preset {
      padding: 0.5rem 1.25rem;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      background: $color-input-bg;
      font-size: $text-base;
      cursor: pointer;
      transition: all 0.2s;

      &:hover {
        background: $color-input-bg-dark;
      }

      &--active {
        background: $color-header-bg;
        font-weight: 600;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.15);
      }
    }

    &__custom {
      display: flex;
      align-items: center;
      gap: 0.5rem;
    }

    &__input {
      padding: 0.625rem 0.75rem;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      background: $color-input-bg;
      font-size: $text-base;
      outline: none;
      width: 10rem;
      transition: 0.2s;

      &:focus {
        background: $color-input-bg-dark;
      }

      /* Hide number spinners */
      &::-webkit-outer-spin-button,
      &::-webkit-inner-spin-button {
        -webkit-appearance: none;
        margin: 0;
      }

      -moz-appearance: textfield;
    }

    &__unit {
      font-size: $text-base;
      color: rgba($color-text, 0.6);
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
      margin-top: 0.5rem;
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
