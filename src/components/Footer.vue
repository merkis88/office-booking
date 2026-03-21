<script setup></script>

<template>
  <div class="footer">
    <div class="footer__inner">
      <section class="footer__brand">
        <div class="footer__logo">
          <img src="@/assets/images/logo.svg" alt="logo" />
          <span>LOGOTYPE</span>
        </div>
        <div class="footer__description">
          <p>Здесь работают люди, которые создают, растут и вдохновляют друг друга.</p>
          <p>Присоединяйтесь!</p>
        </div>
        <div class="footer__hours">
          <p>Режим работы:</p>
          <p>Пн - Вс с 09:00 до 22:00</p>
        </div>
      </section>

      <section class="footer__nav">
        <div class="footer__link">
          <img src="@/assets/images/icons/user-footer.svg" alt="" />
          <a href="">Личный кабинет</a>
        </div>
        <div class="footer__link">
          <img src="@/assets/images/icons/handbag-footer.svg" alt="" />
          <a href="">Услуги</a>
        </div>
        <div class="footer__link">
          <img src="@/assets/images/icons/bank-transfer-footer.svg" alt="" />
          <a href="">Пропуск</a>
        </div>
        <div class="footer__link">
          <img src="@/assets/images/icons/routing-footer.svg" alt="" />
          <a href="">Как добраться</a>
        </div>
      </section>

      <section class="footer__contacts">
        <div class="footer__link">
          <img src="@/assets/images/icons/call-calling-footer.svg" alt="" />
          <a href="">+7 930 454 54 04</a>
        </div>
        <div class="footer__link">
          <img src="@/assets/images/icons/send-2-footer.svg" alt="" />
          <a href="">@operatingPoint.</a>
        </div>
        <div class="footer__link">
          <img src="@/assets/images/icons/sms-edit-footer.svg" alt="" />
          <a href="">operatingPoint.@mail.ru</a>
        </div>
        <div class="footer__link">
          <img src="@/assets/images/icons/location-marker-footer.svg" alt="" />
          <a href="">Говорова 35</a>
        </div>
      </section>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '/src/assets/styles/variables' as *;
  @use '/src/assets/styles/mixins' as *;

  .footer {
    background-color: $color-footer-bg;
    color: $color-footer-text;
    border-radius: $radius-lg $radius-lg 0 0;

    &__inner {
      @include container;
      display: flex;
      align-items: flex-start;
      justify-content: space-between;
      gap: $gap-lg;
      padding-top: $footer-pad-y;
      padding-bottom: $footer-pad-y;
    }

    &__brand {
      display: flex;
      flex-direction: column;
      gap: $gap-md;
      max-width: 22rem;
    }

    &__logo {
      display: flex;
      align-items: center;
      gap: $gap-xs;
      cursor: pointer;

      img {
        width: 28px;
        height: 28px;
        object-fit: contain;
      }

      span {
        font-size: $text-lg;
        font-weight: 600;
        letter-spacing: 0.05em;
      }
    }

    &__description,
    &__hours {
      font-size: $text-xl;
      line-height: 1.7;

      p + p {
        margin-top: 0.2rem;
      }
    }

    &__nav,
    &__contacts {
      display: flex;
      flex-direction: column;
      gap: $gap-md;
    }

    &__link {
      display: flex;
      align-items: center;
      gap: $gap-xs;
      font-size: $text-xl;
      cursor: pointer;
      transition: opacity 0.2s ease;

      &:hover {
        opacity: 0.75;
      }

      img {
        width: 22px;
        height: 22px;
        object-fit: contain;
        flex-shrink: 0;
      }
    }
  }
</style>
