<script setup></script>

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
        <li>Личный кабинет</li>
        <router-link to="/authorization"><li>Авторизация</li></router-link>
        <router-link to="/registration"><li>Регистрация</li></router-link>
      </ul>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '/src/assets/styles/variables' as *;
  @use '/src/assets/styles/mixins' as *;

  .header {
    margin-top: 3.5rem;
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
  }
</style>