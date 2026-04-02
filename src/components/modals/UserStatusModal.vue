<script setup>
  import { ref, watch, computed } from 'vue';
  import BaseModal from '@/components/modals/BaseModal.vue';

  const props = defineProps({
    modelValue: {
      type: Boolean,
      default: false,
    },
    user: {
      type: Object,
      default: null,
    },
    error: {
      type: String,
      default: '',
    },
  });

  const emit = defineEmits(['update:modelValue', 'confirm']);

  const reason = ref('');
  const isLoading = ref(false);

  const isBlocked = computed(() => props.user?.is_blocked);

  watch(
    () => props.modelValue,
    (val) => {
      if (!val) {
        reason.value = '';
        isLoading.value = false;
      }
    },
  );

  function close() {
    emit('update:modelValue', false);
  }

  async function confirm() {
    if (!props.user) return;

    if (!isBlocked.value && !reason.value.trim()) return;

    isLoading.value = true;

    emit('confirm', {
      user: props.user,
      reason: reason.value,
      done: () => {
        isLoading.value = false;
        close();
      },
      fail: () => {
        isLoading.value = false;
      },
    });
  }
</script>

<template>
  <BaseModal
    :model-value="modelValue"
    :title="isBlocked ? 'Разблокировать' : 'Заблокировать'"
    max-width="480px"
    :close-on-backdrop="true"
    @update:model-value="emit('update:modelValue', $event)"
  >
    <div class="user-status-modal">
      <template v-if="isBlocked">
        <p class="user-status-modal__text">
          Вы действительно хотите добавить пользователя в белый список?
        </p>
      </template>

      <template v-else>
        <p class="user-status-modal__text">
          Вы действительно хотите добавить пользователя в чёрный список? Укажите причину:
        </p>

        <input
          v-model="reason"
          type="text"
          class="user-status-modal__input"
          placeholder="Причина блокировки"
          @keyup.enter="confirm"
        />
      </template>

      <p v-if="error" class="user-status-modal__error">
        {{ error }}
      </p>

      <div class="user-status-modal__actions">
        <button
          class="user-status-modal__btn"
          :class="isBlocked ? 'user-status-modal__btn--success' : 'user-status-modal__btn--danger'"
          :disabled="isLoading || (!isBlocked && !reason)"
          @click="confirm"
        >
          <span v-if="isLoading">
            {{ isBlocked ? 'Разблокировка...' : 'Блокировка...' }}
          </span>
          <span v-else>
            {{ isBlocked ? 'Разблокировать' : 'Заблокировать' }}
          </span>
        </button>

        <button class="user-status-modal__btn user-status-modal__btn--cancel" @click="close">
          Отмена
        </button>
      </div>
    </div>
  </BaseModal>
</template>

<style scoped lang="scss">
  @use '@/assets/styles/variables' as *;

  .user-status-modal {
    display: flex;
    flex-direction: column;
    gap: 1rem;

    &__text {
      text-align: center;
      font-size: $text-base;
    }

    &__input {
      padding: 0.875rem 1.25rem;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      background: $color-input-bg;
      font-size: $text-base;
      outline: none;

      &:focus {
        background: $color-input-bg-dark;
      }
    }

    &__error {
      color: $color-danger;
      font-size: $text-sm;
      text-align: center;
    }

    &__actions {
      display: flex;
      justify-content: center;
      gap: 1rem;
    }

    &__btn {
      padding: 0.75rem 2rem;
      border-radius: $radius-sm;
      font-size: $text-base;
      cursor: pointer;

      &--danger {
        background: $color-danger;
        color: #fff;
      }

      &--success {
        background: $color-success;
        color: #fff;
      }

      &--cancel {
        background: $color-input-bg;
        border: 1px solid $color-border;
      }

      &:disabled {
        opacity: 0.5;
        cursor: not-allowed;
      }
    }
  }
</style>
