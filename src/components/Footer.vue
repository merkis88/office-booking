<script setup>
    function openRoute() {
        const lat = 56.4586;
        const lon = 84.94734;
        const url = `https://yandex.ru/maps/?ll=${lon},${lat}&z=18&mode=routes&rtext=~${lat},${lon}&rtt=auto`;
        window.open(url, '_blank');
    }

    const contacts = {
        phone: '+79304545404',
        phoneDisplay: '+7 930 454 54 04',
        telegram: 'operatingPoint',
        email: 'info@rtochka.ru',
        address: 'г. Томск, ул. Учебная, д. 15',
    };

    function openTelegram() {
        window.open(`https://t.me/${contacts.telegram}`, '_blank');
    }

    function openEmail() {
        window.location.href = `mailto:${contacts.email}`;
    }
</script>

<template>
  <div class="footer">
    <div class="footer__inner">
      <section class="footer__brand">
        <div class="footer__logo">
            <img src="@/assets/images/logo.png" alt="logo" />
            <span>Рабочая точка.</span>
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
        <router-link to="/profile" class="footer__link">
          <img src="@/assets/images/icons/user-footer.svg" alt="" />
          <a href="">Личный кабинет</a>
        </router-link>
        <router-link to="/service" class="footer__link">
          <img src="@/assets/images/icons/handbag-footer.svg" alt="" />
          <a href="">Аренда помещений</a>
        </router-link>
        <router-link to="/reviews" class="footer__link">
          <img src="@/assets/images/icons/message-text.svg " alt="" />
          <a href="">Отзывы</a>
        </router-link>
        <button class="footer__link" @click="openRoute">
          <img src="@/assets/images/icons/routing-footer.svg" alt="" />
          <a href="">Как добраться</a>
        </button>
      </section>

        <section class="footer__contacts">
            <div class="footer__link">
                <img src="@/assets/images/icons/call-calling-footer.svg" alt="Телефон" />
                <a :href="`tel:${contacts.phone}`">{{ contacts.phoneDisplay }}</a>
            </div>

            <div class="footer__link" @click="openTelegram">
                <img src="@/assets/images/icons/send-2-footer.svg" alt="Telegram" />
                <a href="javascript:void(0)">@{{ contacts.telegram }}</a>
            </div>

            <div class="footer__link" @click="openEmail" style="cursor: pointer;">
                <img src="@/assets/images/icons/sms-edit-footer.svg" alt="Email" />
                <span>{{ contacts.email }}</span>
            </div>

            <div class="footer__link" @click="openRoute">
                <img src="@/assets/images/icons/location-marker-footer.svg" alt="Адрес" />
                <a href="javascript:void(0)">{{ contacts.address }}</a>
            </div>
        </section>
    </div>
  </div>
</template>

<style lang="scss" scoped>
    @use '@/assets/styles/variables' as *;
    @use '@/assets/styles/mixins' as *;

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
            width: 62px;
            height: 80px;
            object-fit: contain;
        }

        span {
            font-family: $font-logo;
            font-size: $text-2xl;
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
