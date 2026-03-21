<script setup>
  import { ref } from 'vue';
  import { useAuthStore } from '@/store/auth';
  import { useRoute } from 'vue-router';
  import router from '@/router/index.js';
  import NotificationsPanel from '@/components/NotificationsPanel.vue';

  const authStore = useAuthStore();
  const route = useRoute();
  const isAdminMenuOpen = ref(false); // ✅ Состояние меню

  async function handleLogout() {
    await authStore.logout();
    await router.push('/authorization');
  }

  const isActive = (path) => {
    return route.path === path || route.path.startsWith(path);
  };

  function toggleAdminMenu() {
    isAdminMenuOpen.value = !isAdminMenuOpen.value;
  }

  function closeAdminMenu() {
    isAdminMenuOpen.value = false;
  }
</script>

<template>
  <div class="header">
    <div class="header__container">
      <router-link to="/">
        <div class="header__logo">
          <img src="@/assets/images/logo.svg" alt="logo" />
          <span>LOGOTYPE</span>
        </div>
      </router-link>

      <ul class="header__nav">
        <router-link to="/service" :class="{ 'header__link--active': isActive('/service') }">
          <li>Аренда помещений</li>
        </router-link>

        <router-link to="/reviews" :class="{ 'header__link--active': isActive('/reviews') }">
          <li>Отзывы</li>
        </router-link>

        <router-link
          to="/requests"
          v-if="authStore.isAuthenticated"
          :class="{ 'header__link--active': isActive('/requests') }"
        >
          <li>Заявки</li>
        </router-link>

        <router-link
          to="/profile"
          v-if="authStore.isAuthenticated"
          :class="{ 'header__link--active': isActive('/profile') }"
        >
          <li>Личный кабинет</li>
        </router-link>

        <router-link
          to="/authorization"
          v-if="!authStore.isAuthenticated"
          :class="{ 'header__link--active': isActive('/authorization') }"
        >
          <li>Авторизация</li>
        </router-link>

        <router-link
          to="/registration"
          v-if="!authStore.isAuthenticated"
          :class="{ 'header__link--active': isActive('/registration') }"
        >
          <li>Регистрация</li>
        </router-link>

        <div v-if="authStore.isAdmin" class="header__admin-menu">
          <button
            class="header__burger"
            @click="toggleAdminMenu"
            :class="{ 'header__burger--active': isAdminMenuOpen }"
            aria-label="Меню администратора"
          >
            <span></span>
            <span></span>
            <span></span>
          </button>

          <transition name="fade">
            <div v-if="isAdminMenuOpen" class="header__admin-dropdown">
              <router-link to="/admin" @click="closeAdminMenu" class="header__button">
                Административная панель
              </router-link>
            </div>
          </transition>
        </div>

        <router-link to="/authorization" v-if="authStore.isAuthenticated">
          <li class="header__button" @click="handleLogout">Выход</li>
        </router-link>

        <NotificationsPanel v-if="authStore.isAuthenticated" />
      </ul>
    </div>
  </div>

  <transition name="fade">
    <div v-if="isAdminMenuOpen" class="header__overlay" @click="closeAdminMenu"></div>
  </transition>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;
  @use '@/assets/styles/mixins' as *;

  .header {
    margin-top: 1.5rem;
    position: relative;
    z-index: 100;

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

      a {
        color: $color-text;
        transition: opacity 0.2s ease;

        &:hover {
          opacity: 0.6;
        }

        &.header__link--active {
          color: #d6e7f6;
          filter: drop-shadow(0 4px 4px rgba(0, 0, 0, 0.2));
        }
      }

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

    &__admin-menu {
      position: relative;
    }

    &__burger {
      width: 2.5rem;
      height: 2.5rem;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      gap: 0.4rem;
      background: transparent;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      cursor: pointer;
      transition: all 0.3s ease;
      padding: 0.5rem;

      &:hover {
        background: rgba($color-text, 0.05);
      }

      span {
        width: 1.5rem;
        height: 2px;
        background: $color-text;
        transition: all 0.3s ease;
        border-radius: 2px;
      }

      &--active {
        span {
          &:nth-child(1) {
            transform: rotate(45deg) translate(5px, 6px);
          }
          &:nth-child(2) {
            opacity: 0;
          }
          &:nth-child(3) {
            transform: rotate(-45deg) translate(5px, -6px);
          }
        }
      }
    }

    &__admin-dropdown {
      position: absolute;
      top: calc(100% + 0.5rem);
      right: 0;
      background: $color-header-bg;
      border: 1px solid $color-border;
      border-radius: $radius-md;
      padding: 1rem;
      min-width: 300px;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
      z-index: 1000;
    }

    &__admin-close {
      position: absolute;
      top: 0.5rem;
      right: 0.5rem;
      width: 2rem;
      height: 2rem;
      display: flex;
      align-items: center;
      justify-content: center;
      background: transparent;
      border: none;
      color: $color-text;
      cursor: pointer;
      transition: all 0.2s;

      &:hover {
        color: #d6e7f6;
        transform: rotate(90deg);
      }
    }

    &__overlay {
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: transparent;
      z-index: 99;
    }
  }

  .fade-enter-active,
  .fade-leave-active {
    transition: opacity 0.2s ease;
  }

  .fade-enter-from,
  .fade-leave-to {
    opacity: 0;
  }
</style>
