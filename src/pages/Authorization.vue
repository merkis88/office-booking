<script setup>
  import { ref } from 'vue';
  import { useRouter } from 'vue-router';
  import { useAuthStore } from '@/store/auth';
  import EmailVerificationModal from '@/components/modals/EmailVerificationModal.vue';
  import ForgotPasswordModal from '@/components/modals/ForgotPasswordModal.vue';

  const router = useRouter();
  const authStore = useAuthStore();

  const email = ref('');
  const password = ref('');
  const error = ref('');
  const loading = ref(false);
  const showPassword = ref(false);

  const showVerificationModal = ref(false);
  const showForgotPasswordModal = ref(false);

  async function handleLogin() {
    error.value = '';
    loading.value = true;

    try {
      await authStore.login(email.value, password.value);
      await router.push('/');
    } catch (e) {
      error.value = e.response?.data?.message || 'Неверный email или пароль';
    } finally {
      loading.value = false;
    }
  }

  function openVerificationModal() {
    showVerificationModal.value = true;
  }

  function openForgotPasswordModal() {
    showForgotPasswordModal.value = true;
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
        <h2 class="auth__title">Авторизация</h2>

        <form class="auth__form" @submit.prevent="handleLogin">
          <div class="auth__field">
            <label>Эл. почта*</label>
            <input v-model="email" type="email" placeholder="Введите электронную почту" required />
          </div>

          <div class="auth__field">
            <label>Пароль*</label>
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
            <p v-if="error" class="auth__error">{{ error }}</p>
          </div>

          <div class="auth__links">
            <button type="button" @click="openForgotPasswordModal">Забыли пароль?</button>
            <router-link to="/registration">Зарегистрироваться</router-link>
          </div>

          <button type="submit" class="auth__btn auth__btn--primary" :disabled="loading">
            {{ loading ? 'Вход...' : 'Войти' }}
          </button>
        </form>

        <button type="button" class="auth__btn auth__btn--secondary" @click="openVerificationModal">
          Подтвердить аккаунт
        </button>
      </div>
    </div>

    <EmailVerificationModal
      v-model="showVerificationModal"
      :initial-email="email"
      @verified="handleVerified"
      @close="handleModalClose"
    />
  </div>

  <ForgotPasswordModal
    v-model="showForgotPasswordModal"
    :initial-email="email"
    @close="handleModalClose"
  />
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
