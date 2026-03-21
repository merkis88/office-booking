<script setup>
  import { ref } from 'vue';
  import { useAuthStore } from '@/store/auth';
  import { useRouter } from 'vue-router';

  const authStore = useAuthStore();
  const router = useRouter();

  const currentPassword = ref('');
  const showCurrentPassword = ref(false);
  const password = ref('');
  const showPassword = ref(false);
  const confirmPassword = ref('');
  const showConfirmPassword = ref(false);
  const error = ref('');
  const loading = ref(false);

  const handleSubmit = async () => {
    error.value = '';

    if (!password.value) {
      error.value = 'Ошибка: Введите новый пароль';
      return;
    }

    if (password.value.length < 8) {
      error.value = 'Пароль должен содержать минимум 8 символов';
      return;
    }

    if (password.value.length > 64) {
      error.value = 'Пароль может содержать не более 64 символов';
      return;
    }

    if (/[а-яА-ЯёЁ]/.test(password.value)) {
      error.value = 'Пароль не должен содержать кирилицу';
      return;
    }

    if (!/^[a-zA-Z0-9!@#$%^&*()_+=\-]+$/.test(password.value)) {
      error.value =
        'Пароль должен содержать только латинские буквы, цифры и спецсимволы (!@#$%^&*()_+=-)';
      return;
    }

    if (!/[A-Z]/.test(password.value)) {
      error.value = 'Пароль должен содержать хотя бы одну заглавную букву';
      return;
    }

    if (!/[a-z]/.test(password.value)) {
      error.value = 'Пароль должен содержать хотя бы одну строчную букву';
      return;
    }

    if (!/[0-9]/.test(password.value)) {
      error.value = 'Пароль должен содержать хотя бы одну цифру';
      return;
    }

    if (!confirmPassword.value) {
      error.value = 'Ошибка: Подтвердите новый пароль';
      return;
    }

    if (password.value !== confirmPassword.value) {
      error.value = 'Ошибка: Пароли не совпадают';
      return;
    }

    if (currentPassword.value === password.value) {
      error.value = 'Новый пароль должен отличаться от текущего';
      return;
    }

    loading.value = true;

    try {
      await authStore.changePassword(currentPassword.value, password.value, confirmPassword.value);
      await authStore.logout();
      await router.push('/authorization');
    } catch (err) {
      const serverError = err?.response?.data;

      if (serverError?.errors) {
        const firstError = Object.values(serverError.errors)[0];
        error.value = Array.isArray(firstError) ? firstError[0] : firstError;
      } else if (serverError?.message) {
        error.value = serverError.message;
      } else {
        error.value = 'Ошибка:Произошла ошибка. Попробуйте снова.';
      }
    } finally {
      loading.value = false;
    }
  };
</script>

<template>
  <div class="auth">
    <div class="auth__card">
      <div class="auth__image">
        <div class="auth__gradient"></div>
        <img src="@/assets/images/photos/people-login.png" alt="people" />
      </div>

      <div class="auth__content">
        <h2 class="auth__title">Смена пароля</h2>

        <form class="auth__form" @submit.prevent="handleSubmit">
          <div class="auth__field">
            <label>Текущий пароль*</label>
            <div class="auth__input-wrapper">
              <input
                v-model="currentPassword"
                :type="showCurrentPassword ? 'text' : 'password'"
                placeholder="Введите текущий пароль"
                required
              />
              <button
                @click="showCurrentPassword = !showCurrentPassword"
                type="button"
                class="auth__toggle-password"
              >
                <img v-if="showCurrentPassword" src="@/assets/images/icons/eye.svg" alt="Скрыть" />
                <img v-else src="@/assets/images/icons/eye-off.svg" alt="Показать" />
              </button>
            </div>
          </div>

          <div class="auth__field">
            <label>Новый пароль*</label>
            <div class="auth__input-wrapper">
              <input
                v-model="password"
                :type="showPassword ? 'text' : 'password'"
                placeholder="Введите пароль"
                required
              />
              <button
                @click="showPassword = !showPassword"
                type="button"
                class="auth__toggle-password"
              >
                <img v-if="showPassword" src="@/assets/images/icons/eye.svg" alt="Скрыть" />
                <img v-else src="@/assets/images/icons/eye-off.svg" alt="Показать" />
              </button>
            </div>
          </div>

          <div class="auth__field">
            <label>Подтвердите пароль*</label>
            <div class="auth__input-wrapper">
              <input
                v-model="confirmPassword"
                :type="showConfirmPassword ? 'text' : 'password'"
                placeholder="Введите пароль"
                required
              />
              <button
                @click="showConfirmPassword = !showConfirmPassword"
                type="button"
                class="auth__toggle-password"
              >
                <img v-if="showConfirmPassword" src="@/assets/images/icons/eye.svg" alt="Скрыть" />
                <img v-else src="@/assets/images/icons/eye-off.svg" alt="Показать" />
              </button>
            </div>
            <p v-if="error" class="auth__error">{{ error }}</p>
          </div>

          <button type="submit" class="auth__btn auth__btn--primary" :disabled="loading">
            {{ loading ? 'Сохранение...' : 'Подтвердить' }}
          </button>
        </form>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '/src/assets/styles/variables' as *;

  .auth {
    min-height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 2rem 1rem;

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
      border-radius: $radius-lg;
      z-index: 1;
    }

    &__content {
      width: 100%;
      max-width: 28rem;
      margin: auto;
      padding: 3rem 2rem;
      display: flex;
      flex-direction: column;
      gap: 1rem;
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
      align-items: center;
    }

    &__field {
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
      width: 100%;
      max-width: 30rem;

      label {
        font-size: $text-sm;
      }

      input {
        padding: 1.5rem 1.25rem;
        border-radius: $radius-sm;
        border: 1px solid $color-border;
        background: $color-input-bg;
        outline: none;
        width: 100%;

        &:focus {
          border-color: $color-text;
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

      &:hover {
        opacity: 0.6;
      }

      img {
        width: 1.25rem;
        height: 1.25rem;
      }
    }

    &__error {
      color: #e53e3e;
      font-size: $text-sm;
      margin: 1px 0;
      text-align: start;
    }

    &__links {
      display: flex;
      justify-content: space-between;
      width: 100%;
      max-width: 30rem;
      font-size: $text-sm;
      padding: 0 0.8rem;

      a {
        transition: 0.2s;

        &:hover {
          opacity: 0.6;
        }
      }
    }

    &__btn {
      background: $color-input-bg;
      border-radius: $radius-sm;
      font-size: $text-lg;
      transition: 0.25s;
      border: solid 1px $color-border;
      cursor: pointer;
      padding: 0.8rem 2rem;
      width: auto;
      min-width: 15rem;

      &:hover:not(:disabled) {
        background: $color-input-bg-dark;
      }

      &:disabled {
        opacity: 0.6;
        cursor: not-allowed;
      }

      &--secondary {
        margin-top: 0.5rem;

        &:hover {
          background: rgba($color-input-bg, 0.3);
        }
      }

      @media (max-width: 768px) {
        min-width: auto;
        width: 100%;
      }
    }

    @media (max-width: 768px) {
      &__field {
        max-width: 100%;
      }

      &__links {
        max-width: 100%;
      }

      &__btn {
        padding: 0.75rem 2rem;
        width: 100%;
      }
    }
  }
</style>
