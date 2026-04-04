<script setup>
  import { storeToRefs } from 'pinia';
  import { useAuthStore } from '@/store/auth';
  import { useRoute } from 'vue-router';
  import defaultAvatar from '@/assets/images/photos/default-avatar.png';

  function onImageError(event) {
    event.target.src = defaultAvatar;
  }

  const route = useRoute();

  function isActive(path) {
    return route.path.startsWith(path);
  }

  const authStore = useAuthStore();
  const { user } = storeToRefs(authStore);
</script>

<template>
  <aside class="sidebar">
    <router-link to="/admin" class="sidebar__logo">
      <img src="@/assets/images/logo.png" alt="logo" />
      <span>Рабочая точка.</span>
    </router-link>

    <div class="sidebar__profile">
      <div class="sidebar__avatar">
        <img :src="user?.photo_url || defaultAvatar" alt="Аватар" @error="onImageError" />
      </div>
      <p v-if="user">{{ user.last_name }} {{ user.first_name }} {{ user.patronymic }}</p>
    </div>

    <nav class="sidebar__nav">
      <router-link
        to="/admin/users"
        class="sidebar__btn"
        :class="{ 'sidebar__btn--active': isActive('/admin/users') }"
      >
        <img src="@/assets/images/icons/admin-user.svg " alt="" />
        Пользователи
      </router-link>

      <router-link
        to="/admin/places"
        class="sidebar__btn"
        :class="{ 'sidebar__btn--active': isActive('/admin/places') }"
      >
        <img src="@/assets/images/icons/handbag.svg" alt="" />
        Помещения
      </router-link>

      <router-link
        to="/admin/requests/types"
        class="sidebar__btn"
        :class="{ 'sidebar__btn--active': isActive('/admin/requests') }"
      >
        <img src="@/assets/images/icons/menu-board.svg" alt="" />
        Заявки
      </router-link>

      <router-link
        to="/admin/notifications"
        class="sidebar__btn"
        :class="{ 'sidebar__btn--active': isActive('/admin/notifications') }"
      >
        <img src="@/assets/images/icons/notification-admin.svg" alt="" />
        Уведомления
      </router-link>

      <router-link to="/" class="sidebar__btn sidebar__logout">
        <img src="" alt="" />
        Выход
      </router-link>
    </nav>
  </aside>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;

  .sidebar {
    width: 390px;
    background: #8b9dad;
    padding: 30px 20px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 30px;

    &__logo {
      display: flex;
      align-items: center;
      gap: $gap-xs;
      cursor: pointer;

      img {
        object-fit: contain;
      }

      span {
        font-family: $font-logo;
        font-size: $text-2xl;
      }
    }

    &__logo-box {
      width: 40px;
      height: 40px;
      background: white;
      border-radius: 6px;
    }

    &__profile {
      text-align: center;
    }

    &__avatar {
      width: 80px;
      height: 80px;
      margin: 0 auto 10px;

      img {
        width: 80px;
        height: 80px;
        object-fit: cover;
        border-radius: 50%;
      }
    }

    &__nav {
      display: flex;
      flex-direction: column;
      gap: 14px;
    }

    &__btn {
      padding: 12px 20px;
      border: 1px solid black;
      border-radius: 8px;
      text-align: center;
      transition: $transition-fast;
      display: flex;
      align-items: center;
      gap: 2rem;
      justify-content: flex-start;

      &:hover {
        background: rgba(255, 255, 255, 0.3);
      }

      &--active {
        background: rgba(255, 255, 255, 0.5);
      }
    }

    &__logout {
      display: flex;
      justify-content: center;
      margin-top: 20px;
      text-align: center;
      gap: 0;
    }

    &__name {
      font-size: 14px;
      margin-top: 8px;
      line-height: 1.3;
    }
  }
</style>
