<script setup>
  import { watch, computed } from 'vue';
  import { useBookingsStore } from '@/store/bookings';
  import BaseModal from '@/components/modals/BaseModal.vue';
  import StatusBadge from '@/components/StatusBadge.vue';

  const props = defineProps({
    bookingId: {
      type: Number,
      default: null,
    },
    modelValue: {
      type: Boolean,
      default: false,
    },
  });

  const emit = defineEmits(['update:modelValue', 'cancel', 'reschedule', 'extend']);

  const bookingsStore = useBookingsStore();

  watch(
    () => props.modelValue,
    (isOpen) => {
      if (isOpen && props.bookingId) {
        bookingsStore.fetchBooking(props.bookingId);
      }
    },
  );

  const booking = computed(() => bookingsStore.currentBooking);
  const isLoading = computed(() => bookingsStore.bookingLoading);
  const error = computed(() => bookingsStore.bookingError);

  const placeTypeLabels = {
    office: 'Офис',
    coworking: 'Коворкинг',
    meeting_room: 'Переговорная',
  };

  const passTypeLabels = {
    qr: 'QR-код',
    card: 'Карта',
  };

  const formattedDate = computed(() => {
    if (!booking.value) return '';
    return new Date(booking.value.start_time).toLocaleDateString('ru-RU');
  });

  const formattedTime = computed(() => {
    if (!booking.value) return '';
    const start = new Date(booking.value.start_time).toLocaleTimeString('ru-RU', {
      hour: '2-digit',
      minute: '2-digit',
    });
    const end = new Date(booking.value.end_time).toLocaleTimeString('ru-RU', {
      hour: '2-digit',
      minute: '2-digit',
    });
    return `${start} - ${end}`;
  });

  const isActive = computed(() => {
    return booking.value?.status === 'active';
  });

  const isFuture = computed(() => {
    if (!booking.value) return false;
    return new Date(booking.value.start_time) > new Date();
  });

  const showActions = computed(() => {
    return isActive.value;
  });

  const canCancel = computed(() => {
    return isActive.value && isFuture.value;
  });

  const canReschedule = computed(() => {
    return isActive.value;
  });

  const canExtend = computed(() => {
    return isActive.value;
  });

  function handleRetry() {
    if (props.bookingId) {
      bookingsStore.fetchBooking(props.bookingId);
    }
  }

  function handleCancel() {
    emit('cancel', booking.value);
  }

  function handleReschedule() {
    emit('reschedule', booking.value);
  }

  function handleExtend() {
    emit('extend', booking.value);
  }
</script>

<template>
  <BaseModal
    :model-value="modelValue"
    title="Детали бронирования"
    max-width="560px"
    :close-on-backdrop="true"
    @update:model-value="emit('update:modelValue', $event)"
  >
    <div class="booking-details">
      <!-- Loading -->
      <div v-if="isLoading" class="booking-details__loading">
        <div class="booking-details__skeleton">
          <div class="booking-details__skeleton-line booking-details__skeleton-line--wide" />
          <div class="booking-details__skeleton-line" />
          <div class="booking-details__skeleton-line" />
          <div class="booking-details__skeleton-line booking-details__skeleton-line--narrow" />
          <div class="booking-details__skeleton-line" />
          <div class="booking-details__skeleton-line booking-details__skeleton-line--narrow" />
        </div>
      </div>

      <!-- Error -->
      <div v-else-if="error" class="booking-details__error">
        <p class="booking-details__error-text">{{ error }}</p>
        <button class="booking-details__retry-btn" @click="handleRetry">
          Повторить
        </button>
      </div>

      <!-- Content -->
      <template v-else-if="booking">
        <div class="booking-details__section">
          <h4 class="booking-details__section-title">Помещение</h4>
          <div class="booking-details__row">
            <span class="booking-details__label">Название:</span>
            <span class="booking-details__value">{{ booking.place?.name }}</span>
          </div>
          <div class="booking-details__row">
            <span class="booking-details__label">Тип:</span>
            <span class="booking-details__value">
              {{ placeTypeLabels[booking.place?.type] || booking.place?.type }}
            </span>
          </div>
          <div class="booking-details__row">
            <span class="booking-details__label">Вместимость:</span>
            <span class="booking-details__value">{{ booking.place?.capacity }} человек</span>
          </div>
        </div>

        <div class="booking-details__section">
          <h4 class="booking-details__section-title">Время аренды</h4>
          <div class="booking-details__row">
            <span class="booking-details__label">Дата:</span>
            <span class="booking-details__value">{{ formattedDate }}</span>
          </div>
          <div class="booking-details__row">
            <span class="booking-details__label">Время:</span>
            <span class="booking-details__value">{{ formattedTime }}</span>
          </div>
          <div class="booking-details__row">
            <span class="booking-details__label">Статус:</span>
            <StatusBadge :status="booking.status" />
          </div>
        </div>

        <div class="booking-details__section">
          <h4 class="booking-details__section-title">Дополнительно</h4>
          <div class="booking-details__row">
            <span class="booking-details__label">Тип пропуска:</span>
            <span class="booking-details__value">
              {{ passTypeLabels[booking.pass_type] || booking.pass_type || 'Не указан' }}
            </span>
          </div>
          <div class="booking-details__row">
            <span class="booking-details__label">Парковка:</span>
            <span class="booking-details__value">
              {{ booking.parking_place_id ? `Место #${booking.parking_place_id}` : 'Не арендована' }}
            </span>
          </div>
        </div>

        <div v-if="showActions" class="booking-details__actions">
          <button
            v-if="canReschedule"
            class="booking-details__action-btn"
            @click="handleReschedule"
          >
            Перенести
          </button>
          <button
            v-if="canExtend"
            class="booking-details__action-btn"
            @click="handleExtend"
          >
            Продлить
          </button>
          <button
            v-if="canCancel"
            class="booking-details__action-btn booking-details__action-btn--danger"
            @click="handleCancel"
          >
            Отменить
          </button>
        </div>
      </template>
    </div>
  </BaseModal>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;

  .booking-details {
    &__loading {
      padding: 1rem 0;
    }

    &__skeleton {
      display: flex;
      flex-direction: column;
      gap: 1rem;
    }

    &__skeleton-line {
      height: 1.25rem;
      background: $color-input-bg;
      border-radius: $radius-xxs;
      animation: pulse 1.5s ease-in-out infinite;
      width: 80%;

      &--wide {
        width: 100%;
      }

      &--narrow {
        width: 50%;
      }
    }

    &__error {
      text-align: center;
      padding: 2rem 0;
    }

    &__error-text {
      color: #991b1b;
      font-size: $text-base;
      margin-bottom: 1rem;
    }

    &__retry-btn {
      padding: 0.5rem 2rem;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      background: $color-input-bg;
      font-size: $text-base;
      cursor: pointer;
      transition: all 0.2s;

      &:hover {
        background: $color-input-bg-dark;
      }
    }

    &__section {
      margin-bottom: 1.5rem;

      &:last-of-type {
        margin-bottom: 0;
      }
    }

    &__section-title {
      font-family: $font-title;
      font-size: $text-lg;
      font-weight: 500;
      color: $color-text;
      margin-bottom: 0.75rem;
    }

    &__row {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      padding: 0.375rem 0;
    }

    &__label {
      color: rgba($color-text, 0.6);
      font-size: $text-base;
      min-width: 7.5rem;
      flex-shrink: 0;
    }

    &__value {
      font-size: $text-base;
      color: $color-text;
      font-weight: 500;
    }

    &__actions {
      display: flex;
      justify-content: center;
      gap: 1rem;
      margin-top: 2rem;
      padding-top: 1.5rem;
      border-top: 1px solid rgba($color-border, 0.2);
    }

    &__action-btn {
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

      &--danger {
        color: #991b1b;
        border-color: #991b1b;

        &:hover {
          background: #fee2e2;
        }
      }
    }
  }

  @keyframes pulse {
    0%,
    100% {
      opacity: 1;
    }
    50% {
      opacity: 0.4;
    }
  }
</style>
