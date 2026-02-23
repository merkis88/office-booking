<script setup></script>

<template>
  <div class="auth">
    <div class="auth__card">
      <div class="auth__image">
        <div class="auth__gradient"></div>
        <img src="/people-login.png" alt="people" />
      </div>

      <div class="auth__content">
        <h2 class="auth__title">Регистрация</h2>

        <form class="auth__form">
          <div class="auth__field">
            <label>Эл. почта*</label>
            <input type="email" placeholder="Введите электронную почту" required />
          </div>

          <div class="auth__field">
            <label>Пароль*</label>
            <input type="password" placeholder="Введите пароль" required />
          </div>

          <div class="auth__field">
            <label>Подтвердите пароль*</label>
            <input type="password" placeholder="Введите пароль" required />
          </div>

          <label class="auth__checkbox">
            <input type="checkbox" class="auth__checkbox-input" />
            <span class="auth__checkbox-box"></span>
            <span class="auth__checkbox-text">
              Я принимаю условия обработки персональных данных
            </span>
          </label>

          <button class="auth__btn">Зарегистрироваться</button>

          <div class="auth__bottom">
            <span>Уже есть аккаунт?</span>
            <router-link to="/authorization">Авторизация</router-link>
          </div>
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
        white-space: nowrap;
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

    &__bottom {
      display: flex;
      justify-content: center;
      gap: 0.4rem;
      font-size: $text-sm;

      a {
        font-weight: 600;
        transition: 0.2s;

        &:hover {
          opacity: 0.6;
        }
      }
    }
  }
</style>
