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

  const errors = ref({
    firstName: '',
    lastName: '',
    patronymic: '',
    email: '',
    password: '',
    repeatPassword: '',
    acceptTerms: '',
  });

  const isLoading = ref(false);
  const showVerificationModal = ref(false);

  function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  function clearErrors() {
    errors.value = {
      firstName: '',
      lastName: '',
      patronymic: '',
      email: '',
      password: '',
      repeatPassword: '',
      acceptTerms: '',
    };
  }

  function validateForm() {
    clearErrors();
    let isValid = true;

    if (!firstName.value.trim()) {
      errors.value.firstName = 'Ошибка: Введите Имя';
      isValid = false;
    }

    if (!lastName.value.trim()) {
      errors.value.lastName = 'Ошибка: Введитя Фамилию';
      isValid = false;
    }

    if (!email.value.trim()) {
      errors.value.email = 'Ошибка: Введите почту';
      isValid = false;
    } else if (!isValidEmail(email.value)) {
      errors.value.email = 'Ошибка: Неверно введена почта';
      isValid = false;
    }

    if (!password.value) {
      errors.value.password = 'Ошибка: Введите пароль';
      isValid = false;
    } else if (password.value.length < 6) {
      errors.value.password = 'Пароль должен содержать минимум 8 символов';
      isValid = false;
    } else if (password.value.length > 65) {
      errors.value.password = 'Пароль может содержать не более 64 символов';
      isValid = false;
    } else if (!/^[a-zA-Z0-9!@#$%^&*()_+=\-]+$/.test(password.value)) {
      errors.value.password =
        'Пароль должен содержать только латинские буквы, цифры и спецсимволы (!@#$%^&*()_+=-)';
      isValid = false;
    } else if (!/[A-Z]/.test(password.value)) {
      errors.value.password = 'Пароль должен содержать хотя бы одну заглавную букву';
      isValid = false;
    } else if (!/[a-z]/.test(password.value)) {
      errors.value.password = 'Пароль должен содержать хотя бы одну строчную букву';
      isValid = false;
    } else if (!/[0-9]/.test(password.value)) {
      errors.value.password = 'Пароль должен содержать хотя бы одну цифру';
      isValid = false;
    }

    if (!repeatPassword.value) {
      errors.value.repeatPassword = 'Ошибка: Введите пароль';
      isValid = false;
    } else if (password.value !== repeatPassword.value) {
      errors.value.repeatPassword = 'Пароли не совпадают';
      isValid = false;
    }

    if (!acceptTerms.value) {
      errors.value.acceptTerms = 'Необходимо принять условия обработки персональных данных';
      isValid = false;
    }

    return isValid;
  }

  async function handleRegister(event) {
    event.preventDefault();

    if (!validateForm()) {
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
        const backendErrors = error.response.data.errors;

        if (backendErrors.first_name) {
          errors.value.firstName = Array.isArray(backendErrors.first_name)
            ? backendErrors.first_name[0]
            : backendErrors.first_name;
        }
        if (backendErrors.last_name) {
          errors.value.lastName = Array.isArray(backendErrors.last_name)
            ? backendErrors.last_name[0]
            : backendErrors.last_name;
        }
        if (backendErrors.email) {
          errors.value.email = Array.isArray(backendErrors.email)
            ? backendErrors.email[0]
            : backendErrors.email;
        }
        if (backendErrors.password) {
          errors.value.password = Array.isArray(backendErrors.password)
            ? backendErrors.password[0]
            : backendErrors.password;
        }
        if (backendErrors.password_confirmation) {
          errors.value.repeatPassword = Array.isArray(backendErrors.password_confirmation)
            ? backendErrors.password_confirmation[0]
            : backendErrors.password_confirmation;
        }
      } else if (error.response?.data?.message) {
        errors.value.email = error.response.data.message;
      } else {
        errors.value.email = 'Произошла ошибка при регистрации. Попробуйте снова.';
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
        <img src="@/assets/images/photos/people-login.png" alt="people" />
      </div>

      <div class="auth__content">
        <h2 class="auth__title">Регистрация</h2>

        <form @submit="handleRegister" class="auth__form">
          <div class="auth__field">
            <label>Имя пользователя*</label>
            <input
              v-model="firstName"
              type="text"
              placeholder="Введите имя"
              :class="{ 'auth__field-error': errors.firstName }"
              :disabled="isLoading"
              required
            />
            <span v-if="errors.firstName" class="auth__error-text">
              {{ errors.firstName }}
            </span>
          </div>

          <div class="auth__field">
            <label>Фамилия пользователя*</label>
            <input
              v-model="lastName"
              type="text"
              placeholder="Введите фамилию"
              :class="{ 'auth__field-error': errors.lastName }"
              :disabled="isLoading"
              required
            />
            <span v-if="errors.lastName" class="auth__error-text">
              {{ errors.lastName }}
            </span>
          </div>

          <div class="auth__field">
            <label>Отчество пользователя(необязательно)</label>
            <input
              v-model="patronymic"
              type="text"
              placeholder="Введите отчество"
              :class="{ 'auth__field-error': errors.patronymic }"
              :disabled="isLoading"
            />
            <span v-if="errors.patronymic" class="auth__error-text">
              {{ errors.patronymic }}
            </span>
          </div>

          <div class="auth__field">
            <label>Эл.почта*</label>
            <input
              v-model="email"
              type="email"
              placeholder="Введите электронную почту"
              :class="{ 'auth__field-error': errors.email }"
              :disabled="isLoading"
              required
            />
            <span v-if="errors.email" class="auth__error-text">
              {{ errors.email }}
            </span>
          </div>

          <div class="auth__field">
            <label>Пароль*</label>
            <div class="auth__input-wrapper">
              <input
                v-model="password"
                :type="showPassword ? 'text' : 'password'"
                placeholder="Введите пароль"
                :class="{ 'auth__field-error': errors.password }"
                :disabled="isLoading"
                required
              />
              <button
                @click="showPassword = !showPassword"
                type="button"
                class="auth__toggle-password"
                :disabled="isLoading"
              >
                <img v-if="showPassword" src="@/assets/images/icons/eye.svg" alt="Скрыть" />
                <img v-else src="@/assets/images/icons/eye-off.svg" alt="Показать" />
              </button>
            </div>
            <span v-if="errors.password" class="auth__error-text">
              {{ errors.password }}
            </span>
          </div>

          <div class="auth__field">
            <label>Подтвердите пароль*</label>
            <div class="auth__input-wrapper">
              <input
                v-model="repeatPassword"
                :type="showRepeatPassword ? 'text' : 'password'"
                placeholder="Введите пароль еще раз"
                :class="{ 'auth__field-error': errors.repeatPassword }"
                :disabled="isLoading"
                required
              />
              <button
                @click="showRepeatPassword = !showRepeatPassword"
                type="button"
                class="auth__toggle-password"
                :disabled="isLoading"
              >
                <img v-if="showRepeatPassword" src="@/assets/images/icons/eye.svg" alt="Скрыть" />
                <img v-else src="@/assets/images/icons/eye-off.svg" alt="Показать" />
              </button>
            </div>
            <span v-if="errors.repeatPassword" class="auth__error-text">
              {{ errors.repeatPassword }}
            </span>
          </div>

          <div class="auth__checkbox-wrapper">
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
            <span v-if="errors.acceptTerms" class="auth__error-text">
              {{ errors.acceptTerms }}
            </span>
          </div>

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
      :initial-email="email"
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
        color: $color-text;
      }

      input {
        padding: 1rem 1.25rem;
        border-radius: $radius-sm;
        border: 1px solid $color-border;
        background: $color-input-bg;
        outline: none;
        width: 100%;
        transition: border-color 0.2s;

        &:focus {
          border-color: $color-text;
        }

        &:disabled {
          opacity: 0.6;
          cursor: not-allowed;
        }

        &.auth__field-error {
          border-color: #ef4444;
        }
      }
    }

    &__error-text {
      color: #ef4444;
      font-size: 0.75rem;
      margin-top: -0.25rem;
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

    &__checkbox-wrapper {
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
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
        white-space: normal;
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
        line-height: 1.4;

        a {
          color: $color-text;
          text-decoration: underline;

          &:hover {
            opacity: 0.7;
          }
        }
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
