<script setup>
  import { useAuthStore } from '@/store/auth';

  const authStore = useAuthStore();
</script>

<template>
  <main class="services-page">
    <section class="service-section">
      <div class="service-section__container">
        <div class="service-section__image-wrap">
          <div class="service-section__bg"></div>
          <img src="/meeting-room.jpg" alt="Переговорные комнаты" class="service-section__image" />
        </div>

        <div class="service-section__content">
          <h2 class="service-section__title">Переговорные комнаты</h2>
          <p class="service-section__text">
            Переговорные комнаты нашего бизнес-центра — это тихое, продуманное и технически
            оснащённое пространство, где царит продуктивность, уважение к времени и внимание к
            деталям.
          </p>
          <p class="service-section__text">
            Здесь нет отвлекающих деталей, неожиданных перебоев с техникой и прочей мелочовки —
            только комфортная обстановка, в которой легко принимать важные решения и строить
            долгосрочные партнёрства.
          </p>
          <router-link to="/meeting_rooms" class="service-section__btn">Арендовать</router-link>
        </div>
      </div>
    </section>

    <section class="service-section service-section--offices">
      <div class="service-section__container">
        <div class="service-section__content">
          <h2 class="service-section__title service-section__title--center">Офисы</h2>
          <p class="service-section__text">
            Офисы в нашем бизнес-центре — это не просто аренда квадратных метров. Это инвестиция в
            имидж, продуктивность и спокойствие вашей команды. Здесь вы принимаете клиентов с
            уверенностью, проводите встречи без отвлекающих факторов и возвращаетесь домой с
            ощущением, что день прошёл по-настоящему продуктивно.
          </p>
          <p class="service-section__text">
            Каждое помещение продумано до мелочей. Мы берём на себя заботу об инфраструктуре — вы
            сосредотачиваетесь на главном: на своём бизнесе.
          </p>
          <a href="#" class="service-section__btn">Арендовать</a>
        </div>

        <div class="service-section__image-wrap">
          <div class="service-section__bg"></div>
          <img src="/office.jpg" alt="Офисы" class="service-section__image" />
        </div>
      </div>
    </section>

    <section class="service-section">
      <div class="service-section__container">
        <div class="service-section__image-wrap">
          <div class="service-section__bg"></div>
          <img src="/coworking.jpg" alt="Коворкинг" class="service-section__image" />
        </div>

        <div class="service-section__content">
          <h2 class="service-section__title">Коворкинг</h2>
          <p class="service-section__text">
            Коворкинг в нашем бизнес-центре — это возможность работать там, где всё настроено на
            эффективность. Никаких отвлекающих факторов, никакого шума — только продуманная среда
            для тех, кто ценит концентрацию и профессиональную атмосферу.
          </p>
          <p class="service-section__text">
            Это пространство, где вы чувствуете себя как в своём офисе — даже если пришли впервые.
            Где каждая деталь способствует вдохновению, а окружение добавляет мотивацию на
            результат.
          </p>
          <a href="#" class="service-section__btn">Арендовать</a>
        </div>
      </div>
    </section>
  </main>
</template>

<style lang="scss" scoped>
  @use '/src/assets/styles/variables' as *;
  @use '/src/assets/styles/mixins' as *;

  .services-page {
    padding: 5rem 0 6rem;
  }

  .service-section {
    padding: 5rem 0;

    &__container {
      @include container;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 5rem;
    }

    &--reverse &__container {
      flex-direction: row-reverse;
    }

    &__image-wrap {
      position: relative;
      flex-shrink: 0;
      width: 44%;
      padding: 0 2.5rem;
    }

    &__image {
      width: 100%;
      height: 33.75rem;
      object-fit: cover;
      border-radius: 1rem;
      position: relative;
      z-index: 1;
    }

    &__bg {
      position: absolute;
      width: 50rem;
      top: 20%;
      bottom: 20%;
      left: -20%;
      right: 0;
      background: linear-gradient(to right, #f5c9a0, #f4a0a0);
      border-radius: 1rem;
      z-index: 0;
    }

    &__content {
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 1.5rem;
      max-width: 30rem;
    }

    &__title {
      text-align: center;
      font-family: $font-heading;
      font-size: $text-3xl;
      font-weight: 500;
      line-height: 1.3;
      margin-bottom: 0.5rem;

      &--center {
        text-align: center;
      }
    }

    &__text {
      font-size: $text-lg;
      line-height: 1.75;
      color: $color-text;
    }

    &__btn {
      display: inline-block;
      align-self: center;
      margin-top: 1rem;
      font-size: $text-xl;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      padding: 0.5rem 3rem;
      color: $color-text;
      cursor: pointer;
      transition:
        background-color 0.25s ease,
        color 0.25s ease;

      &:hover {
        background-color: $color-text;
        color: #fff;
      }
    }
  }
</style>
