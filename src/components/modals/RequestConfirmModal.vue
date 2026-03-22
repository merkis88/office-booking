<script setup>
  import BaseModal from './BaseModal.vue';

  const props = defineProps({
    isOpen: {
      type: Boolean,
      required: true,
    },
    requestData: {
      type: Object,
      required: true,
    },
  });

  const emit = defineEmits(['close', 'confirm', 'cancel']);

  function handleConfirm() {
    emit('confirm');
  }

  function handleCancel() {
    emit('cancel');
    emit('close');
  }

  function handleClose() {
    emit('close');
  }

  function formatDate(dateStr) {
    if (!dateStr) return '';
    const [year, month, day] = dateStr.split('-');
    return `${day}.${month}.${year}`;
  }

  function formatTime(timeStr) {
    if (!timeStr) return '';
    const [hours] = timeStr.split(':');
    const endHours = (parseInt(hours) + 1).toString().padStart(2, '0');
    return `${timeStr} - ${endHours}:00`;
  }
</script>

<template>
  <BaseModal
    :model-value="isOpen"
    @update:model-value="handleClose"
    title="Подтверждение"
    max-width="600px"
    :close-on-backdrop="false"
  >
    <div class="confirm-modal">
      <p class="confirm-modal__text">Пожалуйста, проверьте правильность указанных данных</p>

      <div class="confirm-modal__info">
        <div class="confirm-modal__row">
          <span class="confirm-modal__label">Дата и время:</span>
          <span class="confirm-modal__value">
            {{ formatDate(requestData.service_date) }}, {{ formatTime(requestData.service_time) }}
          </span>
        </div>

        <div class="confirm-modal__row">
          <span class="confirm-modal__label">Тип заявки:</span>
          <span class="confirm-modal__value">{{ requestData.service_type_label }}</span>
        </div>

        <div class="confirm-modal__row">
          <span class="confirm-modal__label">Помещение:</span>
          <span class="confirm-modal__value">{{ requestData.booking_label }}</span>
        </div>

        <div v-if="requestData.comment" class="confirm-modal__row">
          <span class="confirm-modal__label">Комментарий:</span>
          <span class="confirm-modal__value">{{ requestData.comment }}</span>
        </div>
      </div>

      <div class="confirm-modal__actions">
        <button class="confirm-modal__btn confirm-modal__btn--confirm" @click="handleConfirm">
          Подтвердить
        </button>
        <button class="confirm-modal__btn confirm-modal__btn--cancel" @click="handleCancel">
          Отмена
        </button>
      </div>
    </div>
  </BaseModal>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;

  .confirm-modal {
    display: flex;
    flex-direction: column;
    gap: 2rem;
    align-items: center;

    &__text {
      font-size: $text-lg;
      text-align: center;
      color: $color-text;
      margin: 0;
    }

    &__info {
      width: 100%;
      display: flex;
      flex-direction: column;
      gap: 1rem;
      padding: 1.5rem;
      background: rgba($color-input-bg, 0.5);
      border-radius: $radius-sm;
      border: 1px solid $color-border;
    }

    &__row {
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
    }

    &__label {
      font-size: $text-sm;
      color: rgba($color-text, 0.7);
      font-weight: 500;
    }

    &__value {
      font-size: $text-base;
      color: $color-text;
      font-weight: 600;
    }

    &__actions {
      display: flex;
      gap: 1rem;
      width: 100%;
      justify-content: center;
    }

    &__btn {
      padding: 1rem 3rem;
      border-radius: $radius-sm;
      font-size: $text-base;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s;
      border: 1px solid $color-border;
      min-width: 180px;

      &--confirm {
        background: $color-btn-profile;
        color: $color-text;

        &:hover {
          background: $color-input-bg-dark;
          box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
          transform: translateY(-2px);
        }
      }

      &--cancel {
        background: transparent;
        color: $color-text;

        &:hover {
          background: rgba($color-text, 0.05);
          transform: translateY(-2px);
        }
      }

      &:active {
        transform: translateY(0);
      }
    }

    @media (max-width: 768px) {
      &__actions {
        flex-direction: column;
        width: 100%;
      }

      &__btn {
        width: 100%;
        min-width: auto;
      }
    }
  }
</style>
