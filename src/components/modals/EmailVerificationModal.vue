<script setup>
  import { ref, watch, nextTick } from 'vue';
  import BaseModal from './BaseModal.vue';
  import { useAuthStore } from '@/store/auth';

  const authStore = useAuthStore();

  const props = defineProps({
    modelValue: {
      type: Boolean,
      default: false,
    },
    email: {
      type: String,
      required: true,
    },
  });

  const emit = defineEmits(['update:modelValue', 'verified', 'close']);

  // Состояния
  const code = ref(['', '', '', '', '', '']);
  const inputRefs = ref([]);
  const errorMessage = ref('');
  const successMessage = ref('');
  const isLoading = ref(false);
  const isResending = ref(false);

  // Следим за открытием модалки
  watch(
    () => props.modelValue,
    (newVal) => {
      if (newVal) {
        // Сбрасываем форму при открытии
        code.value = ['', '', '', '', '', ''];
        errorMessage.value = '';
        successMessage.value = '';
        // Фокусируем первый инпут
        nextTick(() => {
          if (inputRefs.value[0]) {
            inputRefs.value[0].focus();
          }
        });
      }
    },
  );

  // Обработка ввода кода
  function handleInput(index, event) {
    const value = event.target.value;

    // Разрешаем только цифры
    if (!/^\d*$/.test(value)) {
      event.target.value = code.value[index];
      return;
    }

    code.value[index] = value;

    // Автопереход на следующий инпут
    if (value && index < 5) {
      inputRefs.value[index + 1]?.focus();
    }

    // Автоматическая отправка при заполнении всех полей
    if (code.value.every((digit) => digit !== '')) {
      handleVerify();
    }
  }

  // Обработка удаления
  function handleKeyDown(index, event) {
    if (event.key === 'Backspace' && !code.value[index] && index > 0) {
      inputRefs.value[index - 1]?.focus();
    }
  }

  // Обработка вставки кода
  function handlePaste(event) {
    event.preventDefault();
    const pastedData = event.clipboardData.getData('text').replace(/\D/g, '');

    for (let i = 0; i < Math.min(pastedData.length, 6); i++) {
      code.value[i] = pastedData[i];
    }

    // Фокусируем следующий пустой инпут или последний
    const nextEmptyIndex = code.value.findIndex((digit) => digit === '');
    const focusIndex = nextEmptyIndex !== -1 ? nextEmptyIndex : 5;
    inputRefs.value[focusIndex]?.focus();

    // Если код полностью вставлен, отправляем
    if (pastedData.length >= 6) {
      handleVerify();
    }
  }

  // Отправка кода на проверку
  async function handleVerify() {
    errorMessage.value = '';
    successMessage.value = '';

    const verificationCode = code.value.join('');

    if (verificationCode.length !== 6) {
      errorMessage.value = 'Пожалуйста, введите полный код';
      return;
    }

    isLoading.value = true;

    try {
      const data = await authStore.verifyEmail(props.email, verificationCode);

      // Проверяем успешность верификации
      if (data.success) {
        successMessage.value = data.message || 'Email успешно подтвержден';

        // Задержка для показа сообщения, затем закрываем модалку
        setTimeout(() => {
          emit('verified', data);
          emit('update:modelValue', false);
        }, 1000);
      } else {
        errorMessage.value = data.message || 'Ошибка верификации';
        code.value = ['', '', '', '', '', ''];
        inputRefs.value[0]?.focus();
      }
    } catch (error) {
      console.error('Ошибка верификации:', error);

      // Обработка ошибок от backend
      if (error.response?.data?.success === false) {
        // Если есть конкретная ошибка для поля code
        if (error.response.data.errors?.code) {
          errorMessage.value = error.response.data.errors.code[0];
        } else {
          errorMessage.value = error.response.data.message || 'Ошибка подтверждения';
        }
      } else if (error.response?.status === 422) {
        errorMessage.value = 'Неверный код. Попробуйте еще раз.';
      } else if (error.response?.status === 410) {
        errorMessage.value = 'Код истек. Запросите новый код.';
      } else {
        errorMessage.value = 'Произошла ошибка. Попробуйте снова.';
      }

      // Очищаем поля при ошибке
      code.value = ['', '', '', '', '', ''];
      inputRefs.value[0]?.focus();
    } finally {
      isLoading.value = false;
    }
  }

  async function handleResendCode() {
    errorMessage.value = '';
    successMessage.value = '';
    isResending.value = true;

    try {
      const data = await authStore.resendVerificationCode(props.email);

      successMessage.value = data.message || 'Код отправлен повторно на вашу почту';

      code.value = ['', '', '', '', '', ''];
      inputRefs.value[0]?.focus();

      setTimeout(() => {
        successMessage.value = '';
      }, 3000);
    } catch (error) {
      console.error('Ошибка повторной отправки:', error);
      errorMessage.value =
        error.response?.data?.message || 'Не удалось отправить код. Попробуйте позже.';
    } finally {
      isResending.value = false;
    }
  }

  function handleClose() {
    emit('update:modelValue', false);
    emit('close');
  }
</script>

<template>
  <BaseModal
    :model-value="modelValue"
    @update:model-value="$emit('update:modelValue', $event)"
    title="Подтверждение аккаунта"
    max-width="500px"
    :close-on-backdrop="false"
    :show-close-button="true"
    @close="handleClose"
  >
    <div class="verification-content">
      <div class="info-message">
        <p>Мы отправили код подтверждения на адрес:</p>
        <p class="email-display">{{ email }}</p>
        <p class="hint-text">Введите 6-значный код из письма</p>
      </div>

      <div class="field-group">
        <label class="field-label">Код</label>
        <div class="code-inputs">
          <input
            v-for="(digit, index) in code"
            :key="index"
            :ref="(el) => (inputRefs[index] = el)"
            v-model="code[index]"
            type="text"
            inputmode="numeric"
            maxlength="1"
            class="code-input"
            :class="{ error: errorMessage}"
            @input="handleInput(index, $event)"
            @keydown="handleKeyDown(index, $event)"
            @paste="handlePaste"
            :disabled="isLoading"
          />
        </div>
      </div>

      <div v-if="successMessage" class="success-message">
        {{ successMessage }}
      </div>

      <div v-if="errorMessage" class="error-message">
        {{ errorMessage }}
      </div>

      <div class="resend-section">
        <span class="resend-text">Не пришел код?</span>
        <button @click="handleResendCode" class="resend-link" :disabled="isResending">
          {{ isResending ? 'Отправка...' : 'Отправить повторно' }}
        </button>
      </div>
    </div>

    <template #footer>
      <button
        @click="handleVerify"
        class="submit-btn"
        :disabled="isLoading || code.some((d) => d === '')"
      >
        {{ isLoading ? 'Проверка...' : 'Отправить' }}
      </button>
    </template>
  </BaseModal>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;
  @use '@/assets/styles/mixins' as *;

  .verification-content {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
  }

  .info-message {
    text-align: center;
    color: $color-text;
  }

  .info-message p {
    margin: 0;
    font-size: $text-sm;
    line-height: 1.5;
  }

  .email-display {
    font-weight: 600;
    font-size: $text-base;
    color: $color-text;
    margin: 0.5rem 0;
  }

  .hint-text {
    color: $color-text;
    opacity: 0.7;
    font-size: $text-sm;
    margin-top: 0.5rem;
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
    margin-left: 3rem;
  }

  .code-inputs {
    display: flex;
    gap: 0.75rem;
    justify-content: center;
  }

  .code-input {
    width: 3rem;
    height: 3rem;
    text-align: center;
    font-size: 1.5rem;
    font-weight: 500;
    border: 1px solid #000000;
    background: $color-bg;
    border-radius: $radius-xs;
    color: $color-text;
    transition: all 0.2s;
  }

  .code-input:focus {
    outline: none;
    border: 2px solid #000000;
    background: $color-bg;
    box-shadow: 0 0 0 3px rgba(150, 192, 220, 0.1);
  }

  .code-input.error {
    border-color: #ef4444;
    animation: shake 0.3s;
  }

  .code-input:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  @keyframes shake {
    0%,
    100% {
      transform: translateX(0);
    }
    25% {
      transform: translateX(-5px);
    }
    75% {
      transform: translateX(5px);
    }
  }

  .success-message {
    padding: 0.75rem;
    background: rgba(16, 185, 129, 0.1);
    border: 1px solid rgba(16, 185, 129, 0.3);
    border-radius: $radius-sm;
    color: #059669;
    font-size: $text-sm;
    text-align: center;
    animation: slideDown 0.3s ease;
  }

  .error-message {
    padding: 0.75rem;
    background: rgba(239, 68, 68, 0.1);
    border: 1px solid rgba(239, 68, 68, 0.3);
    border-radius: $radius-sm;
    color: #dc2626;
    font-size: $text-sm;
    text-align: center;
    animation: slideDown 0.3s ease;
  }

  @keyframes slideDown {
    from {
      opacity: 0;
      transform: translateY(-10px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  .resend-section {
    text-align: center;
    font-size: $text-sm;
  }

  .resend-text {
    color: $color-text;
    opacity: 0.7;
    margin-right: 1rem;
  }

  .resend-link {
    color: #2563eb;
    font-weight: 500;
    transition: color 0.2s;
    text-decoration: underline;
  }

  .resend-link:hover:not(:disabled) {
    color: #1e40af;
  }

  .resend-link:disabled {
    opacity: 0.6;
    cursor: not-allowed;
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
  }

  .submit-btn:hover:not(:disabled) {
    background: white;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  }

  .submit-btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  @media (max-width: 480px) {
    .code-inputs {
      gap: 0.5rem;
    }

    .code-input {
      width: 2.5rem;
      height: 2.5rem;
      font-size: 1.25rem;
    }
  }
</style>
