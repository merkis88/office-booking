<script setup>
  import { storeToRefs } from 'pinia';
  import { useAuthStore } from '@/store/auth';

  const authStore = useAuthStore();
  const { user } = storeToRefs(authStore);
</script>

<template>
  <aside class="sidebar">
    <router-link to="/admin" class="sidebar__logo">
      <div class="sidebar__logo-box"></div>
      <span>LOGOTYPE</span>
    </router-link>

    <div class="sidebar__profile">
      <div class="sidebar__avatar"></div>
      <p v-if="user">{{ user.last_name }} {{ user.first_name }} {{ user.patronymic }}</p>
    </div>

    <nav class="sidebar__nav">
      <router-link to="/admin/users" class="sidebar__btn">
        <img src="@/assets/images/icons/admin-user.svg " alt="" />
        Пользователи
      </router-link>

      <router-link to="/admin/places" class="sidebar__btn">
        <img src="@/assets/images/icons/handbag.svg" alt="" />
        Помещения
      </router-link>

      <router-link to="/admin/requests" class="sidebar__btn">
        <img src="@/assets/images/icons/menu-board.svg" alt="" />
        Заявки
      </router-link>

      <router-link to="/admin/notifications" class="sidebar__btn">
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
    width: 260px;
    background: #8b9dad;
    padding: 30px 20px;
    display: flex;
    flex-direction: column;
    gap: 30px;
  }

  .sidebar__logo {
    display: flex;
    align-items: center;
    gap: 10px;
    font-weight: 600;
  }

  .sidebar__logo-box {
    width: 40px;
    height: 40px;
    background: white;
    border-radius: 6px;
  }

  .sidebar__profile {
    text-align: center;
  }

  .sidebar__avatar {
    width: 80px;
    height: 80px;
    background: #d9d9d9;
    border-radius: 10px;
    margin: 0 auto 10px;
  }

  .sidebar__nav {
    display: flex;
    flex-direction: column;
    gap: 14px;
  }

  .sidebar__btn {
    padding: 12px 20px;
    border: 1px solid black;
    border-radius: 8px;
    text-align: center;
    transition: 0.2s;
    display: flex;
    align-items: center;
    gap: 2rem;
    justify-content: flex-start;
  }

  .sidebar__btn:hover {
    background: rgba(255, 255, 255, 0.3);
  }

  .sidebar__logout {
    display: flex;
    justify-content: center;
    margin-top: 20px;
    text-align: center;
    gap: 0;
  }

  .sidebar__avatar img {
    width: 80px;
    height: 80px;
    object-fit: cover;
    border-radius: 10px;
  }

  .sidebar__name {
    font-size: 14px;
    margin-top: 8px;
    line-height: 1.3;
  }
</style>
