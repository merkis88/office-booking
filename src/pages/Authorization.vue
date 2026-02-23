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
            <input v-model="password" type="password" placeholder="Введите пароль" required />
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
      font-family: $font-heading;
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
      }

      input {
        padding: 1rem 1.25rem;
        border-radius: $radius-sm;
        border: 1px solid $color-border;
        background: $color-input-bg;
        outline: none;

        &:focus {
          border-color: $color-text;
        }
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
      font-size: $text-sm;
      font-weight: 600;

      a {
        transition: 0.2s;

        &:hover {
          opacity: 0.6;
        }
      }
    }

    &__btn {
      margin-top: 1rem;
      background: $color-input-bg;
      padding: 0.75rem;
      border-radius: $radius-sm;
      font-size: $text-lg;
      font-weight: 600;
      transition: 0.25s;

      &:hover {
        background: $color-input-bg-dark;
      }
    }
  }
</style>
