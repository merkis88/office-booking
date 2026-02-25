<script setup>
  import router from '@/router/index.js';
  import { ref } from 'vue';
  import { useAuthStore } from '@/store/auth';
  import EmailVerificationModal from '@/components/modals/EmailVerificationModal.vue';

  const authStore = useAuthStore();

  const firstName = ref('');
  const lastName = ref('');
  const patronymic = ref('');
  const email = ref('');
  const password = ref('');
  const repeatPassword = ref('');
  const showPassword = ref(false);
  const showRepeatPassword = ref(false);
  const acceptTerms = ref(false);

  const errorMessage = ref('');
  const isLoading = ref(false);
  const showVerificationModal = ref(false);

  function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  async function handleRegister(event) {
    event.preventDefault();
    errorMessage.value = '';

    if (!firstName.value.trim()) {
      errorMessage.value = 'Пожалуйста, введите имя';
      return;
    }

    if (!lastName.value.trim()) {
      errorMessage.value = 'Пожалуйста, введите фамилию';
      return;
    }

    if (!email.value.trim()) {
      errorMessage.value = 'Пожалуйста, введите email';
      return;
    }

    if (!isValidEmail(email.value)) {
      errorMessage.value = 'Пожалуйста, введите корректный email';
      return;
    }

    if (!password.value) {
      errorMessage.value = 'Пожалуйста, введите пароль';
      return;
    }

    if (password.value.length < 8) {
      errorMessage.value = 'Пароль должен содержать минимум 8 символов';
      return;
    }

    if (password.value !== repeatPassword.value) {
      errorMessage.value = 'Пароли не совпадают';
      return;
    }

    if (!acceptTerms.value) {
      errorMessage.value = 'Необходимо принять условия обработки персональных данных';
      return;
    }

    isLoading.value = true;

    try {
      const registrationData = {
        first_name: firstName.value.trim(),
        last_name: lastName.value.trim(),
        email: email.value.trim(),
        password: password.value,
        password_confirmation: repeatPassword.value,
      };

      if (patronymic.value.trim()) {
        registrationData.patronymic = patronymic.value.trim();
      }

      const result = await authStore.register(registrationData);

      if (result.success) {
        showVerificationModal.value = true;
      }
    } catch (error) {
      console.error('Ошибка регистрации:', error);

      if (error.response?.data?.errors) {
        const errors = error.response.data.errors;
        const firstError = Object.values(errors)[0];
        errorMessage.value = Array.isArray(firstError) ? firstError[0] : firstError;
      } else if (error.response?.data?.message) {
        errorMessage.value = error.response.data.message;
      } else {
        errorMessage.value = 'Произошла ошибка при регистрации. Попробуйте снова.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  function handleVerified() {
    showVerificationModal.value = false;
    router.push('/');
  }

  function handleModalClose() {
    showVerificationModal.value = false;
  }
</script>

<template>
  <div class="auth">
    <div class="auth__card">
      <div class="auth__image">
        <div class="auth__gradient"></div>
        <img src="/people-login.png" alt="people" />
      </div>

      <div class="auth__content">
        <h2 class="auth__title">Регистрация</h2>

        <div v-if="errorMessage" class="auth__error">
          {{ errorMessage }}
        </div>

        <form @submit="handleRegister" class="auth__form">
          <div class="auth__field">
            <label>Имя пользователя*</label>
            <input
              v-model="firstName"
              type="text"
              placeholder="Введите имя"
              :disabled="isLoading"
              required
            />
          </div>

          <div class="auth__field">
            <label>Фамилия пользователя*</label>
            <input
              v-model="lastName"
              type="text"
              placeholder="Введите фамилию"
              :disabled="isLoading"
              required
            />
          </div>

          <div class="auth__field">
            <label>Отчество пользователя (необязательно)</label>
            <input
              v-model="patronymic"
              type="text"
              placeholder="Введите отчество"
              :disabled="isLoading"
            />
          </div>

          <div class="auth__field">
            <label>Эл. почта*</label>
            <input
              v-model="email"
              type="email"
              placeholder="Введите электронную почту"
              :disabled="isLoading"
              required
            />
          </div>

          <div class="auth__field">
            <label>Пароль*</label>
            <div class="auth__input-wrapper">
              <input
                v-model="password"
                :type="showPassword ? 'text' : 'password'"
                placeholder="Введите пароль"
                :disabled="isLoading"
                required
              />
              <button
                @click="showPassword = !showPassword"
                type="button"
                class="auth__toggle-password"
                :disabled="isLoading"
              >
                <img v-if="showPassword" src="/eye.svg" alt="Скрыть" />
                <img v-else src="/eye-off.svg" alt="Показать" />
              </button>
            </div>
          </div>

          <div class="auth__field">
            <label>Подтвердите пароль*</label>
            <div class="auth__input-wrapper">
              <input
                v-model="repeatPassword"
                :type="showRepeatPassword ? 'text' : 'password'"
                placeholder="Введите пароль еще раз"
                :disabled="isLoading"
                required
              />
              <button
                @click="showRepeatPassword = !showRepeatPassword"
                type="button"
                class="auth__toggle-password"
                :disabled="isLoading"
              >
                <img v-if="showRepeatPassword" src="/eye.svg" alt="Скрыть" />
                <img v-else src="/eye-off.svg" alt="Показать" />
              </button>
            </div>
          </div>

          <label class="auth__checkbox">
            <input
              v-model="acceptTerms"
              type="checkbox"
              class="auth__checkbox-input"
              :disabled="isLoading"
            />
            <span class="auth__checkbox-box"></span>
            <span class="auth__checkbox-text">
              Я принимаю условия обработки персональных данных
            </span>
          </label>

          <div class="auth__info">
            <span class="auth__info-text">
              Нажимая на кнопку "Зарегистрироваться", я соглашаюсь с условиями
              <router-link to="/privacy-policy">Политики конфиденциальности</router-link>
            </span>
          </div>

          <button type="submit" class="auth__btn" :disabled="isLoading">
            {{ isLoading ? 'Регистрация...' : 'Зарегистрироваться' }}
          </button>

          <div class="auth__bottom">
            <router-link to="/authorization">Уже есть аккаунт? Авторизация</router-link>
          </div>
        </form>
      </div>
    </div>
    <EmailVerificationModal
      v-model="showVerificationModal"
      :email="email"
      @verified="handleVerified"
      @close="handleModalClose"
    />
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;
  @use '@/assets/styles/mixins' as *;

  .auth {
    margin: 150px 0;
    min-height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;

    &__card {
      width: 100%;
      max-width: 72rem;
      min-height: 40rem;
      background: $color-footer-bg;
      border-radius: $radius-lg;
      overflow: hidden;
      display: flex;
      box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
    }

    &__image {
      position: relative;
      width: 50%;
      display: none;

      @media (min-width: 1024px) {
        display: block;
      }

      img {
        position: absolute;
        inset: 0;
        margin: auto;
        max-width: 100%;
        max-height: 100%;
        object-fit: contain;
        z-index: 2;
      }
    }

    &__gradient {
      position: absolute;
      inset: 0;
      background: linear-gradient(to bottom, $color-shadow-from, $color-shadow-to);
      z-index: 1;
      border-radius: $radius-lg;
    }

    &__content {
      width: 100%;
      max-width: 28rem;
      margin: auto;
      padding: 3rem 2rem;
    }

    &__title {
      font-family: $font-title;
      font-weight: normal;
      font-size: $text-3xl;
      text-align: center;
      margin-bottom: 2rem;
    }

    &__error {
      padding: 1rem;
      margin-bottom: 1.5rem;
      background: rgba(239, 68, 68, 0.1);
      border: 1px solid rgba(239, 68, 68, 0.3);
      border-radius: $radius-sm;
      color: rgb(239, 68, 68);
      font-size: $text-sm;
      text-align: center;
    }

    &__form {
      display: flex;
      flex-direction: column;
      gap: 1.5rem;
    }

    &__field {
      display: flex;
      flex-direction: column;
      gap: 0.5rem;

      label {
        font-size: $text-sm;
      }

      input {
        padding: 1rem 1.25rem;
        border-radius: $radius-sm;
        border: 1px solid $color-border;
        background: $color-input-bg;
        outline: none;
        width: 100%;

        &:focus {
          border-color: $color-text;
        }

        &:disabled {
          opacity: 0.6;
          cursor: not-allowed;
        }
      }
    }

    &__input-wrapper {
      position: relative;
      display: flex;
      align-items: center;

      input {
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
      color: $color-text;
      transition: opacity 0.2s;

      &:hover:not(:disabled) {
        opacity: 0.6;
      }

      &:disabled {
        opacity: 0.4;
        cursor: not-allowed;
      }

      img {
        width: 1.25rem;
        height: 1.25rem;
      }
    }

    &__checkbox {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      font-size: $text-sm;
      line-height: 1.3;
      cursor: pointer;
      user-select: none;

      &-input {
        display: none;

        &:disabled + .auth__checkbox-box {
          opacity: 0.6;
          cursor: not-allowed;
        }
      }

      &-box {
        width: 18px;
        height: 18px;
        border-radius: 4px;
        border: 1.5px solid $color-border;
        background: #fff;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        transition: all 0.2s ease;
      }

      &-text {
        white-space: nowrap;
      }

      &-input:checked + &-box {
        background: linear-gradient(135deg, $color-shadow-from, $color-shadow-to);
        border-color: $color-text;

        &::after {
          content: '\2713';
          font-size: 13px;
          font-weight: 700;
          color: $color-text;
        }
      }

      &:hover &-box {
        border-color: $color-text;
      }
    }

    &__info {
      text-align: center;

      &-text {
        font-size: $text-sm;
      }
    }

    &__btn {
      margin-top: 1rem;
      background: $color-input-bg;
      padding: 0.75rem;
      border-radius: $radius-sm;
      font-size: $text-lg;
      transition: 0.25s;

      &:hover:not(:disabled) {
        background: $color-input-bg-dark;
      }

      &:disabled {
        opacity: 0.6;
        cursor: not-allowed;
      }
    }

    &__bottom {
      display: flex;
      justify-content: center;
      gap: 0.4rem;
      font-size: $text-sm;

      a {
        transition: 0.2s;

        &:hover {
          opacity: 0.6;
        }
      }
    }
  }
</style>
