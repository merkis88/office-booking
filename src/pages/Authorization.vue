<script setup>
  import { ref } from 'vue';
  import { useRouter } from 'vue-router';
  import { useAuthStore } from '@/store/auth';

  const router = useRouter();
  const authStore = useAuthStore();

  const email = ref('');
  const password = ref('');
  const error = ref('');
  const loading = ref(false);
  const showPassword = ref(false);

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
</script>

<template>
  <div class="auth">
    <div class="auth__card">
      <div class="auth__image">
        <div class="auth__gradient"></div>
        <img src="/people-login.png" alt="people" />
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
                <img v-if="showPassword" src="/eye.svg" alt="Скрыть" />
                <img v-else src="/eye-off.svg" alt="Показать" />
              </button>
            </div>
            <p v-if="error" class="auth__error">{{ error }}</p>
          </div>
          <div class="auth__links">
            <a href="#">Забыли пароль?</a>
            <router-link to="/registration">Зарегистрироваться</router-link>
          </div>

          <button class="auth__btn" :disabled="loading">
            {{ loading ? 'Вход...' : 'Войти' }}
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
      min-width: 30rem;

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

      svg {
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
      min-width: 30rem;
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
      padding: 0.75rem 6rem;
      border-radius: $radius-sm;
      font-size: $text-lg;
      transition: 0.25s;
      border: solid 1px $color-border;

      &:hover {
        background: $color-input-bg-dark;
      }
    }
  }
</style>
