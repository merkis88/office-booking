<script setup>
  import { ref, watch } from 'vue';
  import { useRouter } from 'vue-router';
  import { useAuthStore } from '@/store/auth';
  import BaseModal from '@/components/modals/BaseModal.vue';

  const props = defineProps({
    modelValue: {
      type: Boolean,
      default: false,
    },
  });

  const emit = defineEmits(['update:modelValue']);

  const authStore = useAuthStore();
  const router = useRouter();

  const password = ref('');
  const errorMessage = ref('');
  const isDeleting = ref(false);
  const showPassword = ref(false);

  watch(
    () => props.modelValue,
    (newVal) => {
      if (!newVal) {
        password.value = '';
        errorMessage.value = '';
      }
    },
  );

  async function confirmDelete() {
    if (!password.value) {
      errorMessage.value = 'Введите пароль';
      return;
    }

    isDeleting.value = true;
    errorMessage.value = '';

    try {
      await authStore.deleteAccount(password.value);
      emit('update:modelValue', false);
      router.push('/');
    } catch (error) {
      if (error.response?.status === 422) {
        errorMessage.value = 'Неверный пароль';
      } else {
        errorMessage.value = 'Не удалось удалить аккаунт. Повторите попытку.';
      }
    } finally {
      isDeleting.value = false;
    }
  }

  function close() {
    emit('update:modelValue', false);
  }
</script>

<template>
  <BaseModal
    :model-value="modelValue"
    title="Удаление аккаунта"
    max-width="480px"
    :close-on-backdrop="true"
    :show-close-button="true"
    @update:model-value="emit('update:modelValue', $event)"
    @back="close"
  >
    <div class="delete-account">
      <p class="delete-account__warning">
        Это действие необратимо. Все ваши данные, бронирования и пропуска будут удалены.
      </p>

      <label class="delete-account__label">Для подтверждения введите пароль:</label>

      <div class="delete-account__input-wrapper">
        <input
          v-model="password"
          :type="showPassword ? 'text' : 'password'"
          class="delete-account__input"
          placeholder="Пароль"
          @keyup.enter="confirmDelete"
        />

        <button
          type="button"
          class="delete-account__toggle-password"
          @click="showPassword = !showPassword"
        >
          <img v-if="showPassword" src="@/assets/images/icons/eye.svg" alt="Скрыть" />
          <img v-else src="@/assets/images/icons/eye-off.svg" alt="Показать" />
        </button>
      </div>

      <p v-if="errorMessage" class="delete-account__error">
        {{ errorMessage }}
      </p>

      <div class="delete-account__actions">
        <button
          class="delete-account__btn delete-account__btn--danger"
          :disabled="!password || isDeleting"
          @click="confirmDelete"
        >
          {{ isDeleting ? 'Удаление...' : 'Удалить аккаунт' }}
        </button>

        <button class="delete-account__btn delete-account__btn--cancel" @click="close">
          Отмена
        </button>
      </div>
    </div>
  </BaseModal>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;

  .delete-account {
    display: flex;
    flex-direction: column;
    gap: 1rem;

    &__warning {
      color: $color-danger;
      font-size: $text-base;
      line-height: 1.5;
      text-align: center;
    }

    &__label {
      font-size: $text-base;
      color: $color-text;
    }

    &__input {
      padding: 0.875rem 1.25rem;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      background: $color-input-bg;
      font-size: $text-base;
      outline: none;
      transition: $transition-fast;

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
      gap: 1rem;
      justify-content: center;
      margin-top: 0.5rem;
    }

    &__btn {
      padding: 0.75rem 2rem;
      border-radius: $radius-sm;
      font-size: $text-base;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.2s;

      &--danger {
        background: $color-danger;
        color: #ffffff;
        border: 1px solid $color-danger;

        &:hover:not(:disabled) {
          background: $color-danger-dark;
        }

        &:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }
      }

      &--cancel {
        background: $color-input-bg;
        color: $color-text;
        border: 1px solid $color-border;

        &:hover {
          background: $color-input-bg-dark;
        }
      }
    }

    &__input-wrapper {
      position: relative;
      display: flex;
      align-items: center;

      input {
        width: 100%;
        padding-right: 3rem;
      }
    }

    &__toggle-password {
      position: absolute;
      right: 1rem;
      top: 50%;
      transform: translateY(-50%);
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 0.25rem;
      transition: $transition-fast;

      &:hover {
        opacity: 0.6;
      }

      img {
        width: 1.25rem;
        height: 1.25rem;
      }
    }
  }
</style>
