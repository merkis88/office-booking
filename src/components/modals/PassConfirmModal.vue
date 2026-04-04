<script setup>
  import { ref, watch } from 'vue';
  import BaseModal from '@/components/modals/BaseModal.vue';

  const props = defineProps({
    modelValue: {
      type: Boolean,
      default: false,
    },
    email: {
      type: String,
      required: true,
    },
    error: {
      type: String,
      default: '',
    },
  });

  const emit = defineEmits(['update:modelValue', 'confirm']);

  const isLoading = ref(false);

  watch(
    () => props.modelValue,
    (val) => {
      if (!val) isLoading.value = false;
    },
  );

  function close() {
    emit('update:modelValue', false);
  }

  async function confirm() {
    isLoading.value = true;
    emit('confirm', {
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
    title="Подтверждение"
    max-width="480px"
    :close-on-backdrop="true"
    @update:model-value="emit('update:modelValue', $event)"
  >
    <div class="pass-confirm-modal">
      <p class="pass-confirm-modal__text">
        Пожалуйста, проверьте правильность указанных данных
        <br />
        <strong>{{ email }}</strong>
      </p>

      <p v-if="error" class="pass-confirm-modal__error">{{ error }}</p>

      <div class="pass-confirm-modal__actions">
        <button class="pass-confirm-modal__btn" :disabled="isLoading" @click="confirm">
          {{ isLoading ? 'Отправка...' : 'Подтвердить' }}
        </button>
        <button class="pass-confirm-modal__btn pass-confirm-modal__btn--cancel" @click="close">
          Отмена
        </button>
      </div>
    </div>
  </BaseModal>
</template>

<style scoped lang="scss">
  @use '@/assets/styles/variables' as *;

  .pass-confirm-modal {
    display: flex;
    flex-direction: column;
    gap: 1rem;
    text-align: center;

    &__text {
      font-size: $text-base;
    }

    &__error {
      color: $color-danger;
      font-size: $text-sm;
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
      background: $color-btn-profile;
      color: $color-text;

      &:disabled {
        opacity: 0.5;
        cursor: not-allowed;
      }
    }

    &__btn--cancel {
      background: $color-input-bg;
      border: 1px solid $color-border;
    }
  }
</style>
