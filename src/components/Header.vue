<script setup>
  import { useAuthStore } from '@/store/auth';
  import router from '@/router/index.js';

  const authStore = useAuthStore();

  async function handleLogout() {
    await authStore.logout();
    await router.push('/authorization');
  }
</script>

<template>
  <div class="header">
    <div class="header__container">
      <router-link to="/">
        <div class="header__logo">
          <img src="/logo.svg" alt="logo" />
          <span>LOGOTYPE</span>
        </div>
      </router-link>

      <ul class="header__nav">
        <router-link to="/service"><li>Аренда помещений</li></router-link>
        <li>Отзывы</li>
        <router-link to="/profile" v-if="authStore.isAuthenticated">
          <li>Личный кабинет</li>
        </router-link>
        <router-link to="/authorization" v-if="!authStore.isAuthenticated">
          <li>Авторизация</li>
        </router-link>
        <router-link to="/registration" v-if="!authStore.isAuthenticated">
          <li>Регистрация</li>
        </router-link>
        <router-link to="/authorization" v-if="authStore.isAuthenticated">
          <li class="header__button" @click="handleLogout">Выход</li>
        </router-link>
        <router-link to="/" v-if="authStore.isAuthenticated">
          <li><img class="header__img" src="/notification.svg" alt="" /></li>
        </router-link>
      </ul>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;
  @use '@/assets/styles/mixins' as *;

  .header {
    margin-top: 1.5rem;
    &__container {
      @include container;
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: $header-pad-y $header-pad-x;
      background-color: $color-header-bg;
      border-radius: $radius-md;
    }

    &__logo {
      display: flex;
      align-items: center;
      gap: $gap-xs;
      cursor: pointer;

      img {
        width: 32px;
        height: 32px;
        object-fit: contain;
      }

      span {
        font-size: $text-lg;
        font-weight: 600;
        letter-spacing: 0.05em;
      }
    }

    &__nav {
      display: flex;
      align-items: center;
      gap: 2.5rem;
      font-size: $text-lg;
      list-style: none;

      li {
        cursor: pointer;
        transition: opacity 0.2s ease;

        &:hover {
          opacity: 0.6;
        }
      }
    }

    &__button {
      border: solid 1px $color-border;
      border-radius: 0.4rem;
      padding: 0.2rem 0.8rem;
    }

    &__img {
      height: 35px;
    }
  }
</style>