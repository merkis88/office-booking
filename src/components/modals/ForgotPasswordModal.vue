<script setup>
  import BaseModal from '@/components/modals/BaseModal.vue';
  import { ref, watch } from 'vue';
  import { useAuthStore } from '@/store/auth.js';

  const authStore = useAuthStore();

  const props = defineProps({
    modelValue: {
      type: Boolean,
      default: false,
    },
    initialEmail: {
      type: String,
      default: '',
    },
  });

  const emit = defineEmits(['update:modelValue', 'close']);

  const email = ref('');
  const isLoading = ref(false);
  const errorMessage = ref('');
  const isSuccess = ref(true);

  watch(
    () => props.modelValue,
    (newVal) => {
      if (newVal) {
        email.value = props.initialEmail;
        errorMessage.value = '';
        isSuccess.value = false;
        isLoading.value = false;
      }
    },
  );

  function closeModal() {
    emit('update:modelValue', false);
    emit('close');
  }

  function handleClose() {
    emit('update:modelValue', false);
    emit('close');
  }

  function isValidEmail(emailValue) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(emailValue);
  }

  async function handleResendPassword() {
    errorMessage.value = '';
    isSuccess.value = false;

    if (!email.value.trim()) {
      errorMessage.value = 'Пожалуйста, введите email';
      return;
    }

    if (!isValidEmail(email.value)) {
      errorMessage.value = 'Пожалуйста, введите корректный email';
      return;
    }

    isLoading.value = true;

    try {
      const data = await authStore.forgotPassword(email.value);

      isSuccess.value = true;
    } catch (error) {
      console.error('Ошибка отправки:', error);

      if (error.response?.data?.errors?.email) {
        errorMessage.value = Array.isArray(error.response.data.errors.email)
          ? error.response.data.errors.email[0]
          : error.response.data.errors.email;
      } else if (error.response?.data?.message) {
        errorMessage.value = error.response.data.message;
      } else {
        errorMessage.value = 'Не удалось отправить код. Попробуйте позже.';
      }

      isSuccess.value = false;
    } finally {
      isLoading.value = false;
    }
  }
</script>

<template>
  <BaseModal
    :model-value="modelValue"
    @update:model-value="$emit('update:modelValue', $event)"
    title="Забыли пароль?"
    max-width="500px"
    :close-on-backdrop="false"
    :show-close-button="true"
    @close="handleClose"
  >
    <div v-if="!isSuccess" class="verification-content">
      <div class="verification-content__header">
        <p class="verification-content__title">Введите адрес эл. почты от аккаунта, мы отправим</p>
        <p class="verification-title">Вам временный пароль для входа в аккаунт</p>
      </div>

      <div class="field-group">
        <label class="field-label">Эл.почта*</label>
        <input
          v-model="email"
          type="email"
          placeholder="Введите электронную почту"
          class="email-input"
          :class="{ 'email-input--error': errorMessage }"
          :disabled="isLoading"
        />
        <span v-if="errorMessage" class="error-text">
          {{ errorMessage }}
        </span>
      </div>
    </div>

    <template v-if="!isSuccess" #footer>
      <button
        class="submit-btn"
        @click="handleResendPassword"
        :disabled="isLoading || !email.trim()"
      >
        {{ isLoading ? 'Отправка...' : 'Отправить' }}
      </button>
    </template>

    <div v-if="isSuccess" class="verification-content">
      <div class="verification-content__header">
        <img src="/sms-tracking.svg" alt="Успех" class="success-icon" />
        <p class="verification-content__title">
          Мы отправили вам временный пароль для входа в аккаунт, проверьте пожалуйста свой почтовый
          ящик
        </p>
        <button @click="closeModal">Авторизация</button>
      </div>
    </div>
  </BaseModal>
</template>

<style scoped lang="scss">
  @use '@/assets/styles/variables' as *;
  @use '@/assets/styles/mixins' as *;

  .verification-content {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;

    &__header {
      display: flex;
      align-items: center;
      flex-direction: column;
      gap: 1rem;
    }

    &__title {
      text-align: center;
      max-width: 25rem;
      line-height: 1.5;
      margin: 0;
      font-size: $text-lg;
    }

    img {
      width: 3rem;
    }

    button {
      font-size: $text-lg;
      margin: 1rem 0;
    }
  }

  .verification-title {
    margin: 0;
  }

  .success-icon {
    width: 4rem;
    height: 4rem;
    margin-bottom: 1rem;
  }

  .field-group {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .field-label {
    font-size: $text-sm;
    font-weight: 500;
    color: $color-text;
    text-align: start;
  }

  .email-input {
    width: 100%;
    padding: 1rem 1.25rem;
    border-radius: $radius-sm;
    border: 1px solid $color-border;
    background: $color-input-bg;
    outline: none;
    font-size: $text-base;
    color: $color-text;
    transition: all 0.2s;

    &:focus {
      border-color: $color-text;
    }

    &:disabled {
      opacity: 0.6;
      cursor: not-allowed;
    }

    &--error {
      border-color: #ef4444;
    }
  }

  .error-text {
    color: #ef4444;
    font-size: 0.75rem;
    margin-top: -0.25rem;
  }

  .submit-btn {
    width: 100%;
    max-width: 200px;
    padding: 0.75rem 1.5rem;
    background: $color-input-bg;
    border: 1px solid $color-border;
    border-radius: $radius-sm;
    font-size: $text-base;
    font-weight: 500;
    color: $color-text;
    transition: all 0.2s;
    cursor: pointer;

    &:hover:not(:disabled) {
      background: white;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }

    &:disabled {
      opacity: 0.6;
      cursor: not-allowed;
    }
  }

  @media (max-width: 480px) {
    .verification-content__title {
      max-width: 100%;
    }
  }
</style>
