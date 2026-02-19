<script setup>
  import { ref, onMounted, onBeforeUnmount } from 'vue';
  import { loadYandexMaps } from '/utils/loadYandexMaps';

  const mapRef = ref(null);
  let mapInstance = null;

  onMounted(async () => {
    try {
      const maps = await loadYandexMaps('6d245821-6d7d-4508-94ac-5f3bd1ad64e7');
      mapInstance = new maps.Map(mapRef.value, {
        center: [56.47206841422648, 84.96093203201555],
        zoom: 18,
      });
      mapInstance.geoObjects.add(new maps.Placemark([56.47206841422648, 84.96093203201555]));
    } catch (e) {
      console.error('Ошибка загрузки Яндекс.Карт:', e);
    }
  });

  onBeforeUnmount(() => {
    if (mapInstance) {
      mapInstance.destroy();
      mapInstance = null;
    }
  });
</script>

<template>
  <main class="page-main">
    <!-- ===== HERO ===== -->
    <section class="hero">
      <div class="hero__inner">
        <img src="/skyscraper-main.png" alt="skyscraper" class="hero__image" />
        <div class="hero__content">
          <div class="hero__text-block">
            <h1 class="hero__title">Добро пожаловать в бизнес центр "Рабочая точка."</h1>
            <div class="hero__description">
              <p>
                Здесь вы найдёте всё, что нужно для работы без лишних хлопот: современные офисы под
                ключ, переговорные с техникой и тишиной, гибкий коворкинг — и команду, которая
                всегда готова помочь.
              </p>
              <p>
                Ни суеты, ни нервов из-за мелочей — только чёткая организация, уважение к вашему
                времени и пространство, в котором хочется остаться.
              </p>
            </div>
            <a href="#about" class="hero__btn">Подробнее</a>
          </div>
        </div>
      </div>
    </section>

    <!-- ===== ABOUT ===== -->
    <section class="about" id="about">
      <div class="about__container">
        <h2 class="about__title">Почему мы?</h2>
        <div class="about__body">
          <img src="/working-main.png" alt="working" class="about__image" />
          <ul class="about__list">
            <li class="about__item">
              <img src="/flash.svg" alt="" />
              <p>
                Всё под рукой — от быстрого Wi-Fi и современного оборудования до кофе и парковки.
              </p>
            </li>
            <li class="about__item">
              <img src="/flash.svg" alt="" />
              <p>
                Ни минуты впустую — бронируйте онлайн, приходите и сразу начинайте встречу. Всё уже
                готово.
              </p>
            </li>
            <li class="about__item">
              <img src="/flash.svg" alt="" />
              <p>
                Тишина и порядок — никакого шума, хаоса или отвлекающих факторов. Только
                продуктивность.
              </p>
            </li>
            <li class="about__item">
              <img src="/flash.svg" alt="" />
              <p>
                Люди, а не клиенты — мы ценим каждого, кто к нам приходит, и всегда рады помочь
                лично.
              </p>
            </li>
          </ul>
        </div>
      </div>
    </section>

    <!-- ===== SERVICES ===== -->
    <section class="services">
      <div class="services__container">
        <h2 class="services__title">Аренда помещений</h2>
        <div class="services__inner">
          <div class="services__cards">
            <div class="service-card">
              <div class="service-card__shadow"></div>
              <div class="service-card__body">
                <h3 class="service-card__title">Переговорные комнаты</h3>
                <p class="service-card__text">
                  Нужно провести встречу, не отвлекаясь на шум офиса? Наши переговорные созданы
                  именно для этого.
                </p>
              </div>
            </div>
            <div class="service-card">
              <div class="service-card__shadow"></div>
              <div class="service-card__body">
                <h3 class="service-card__title">Офисы</h3>
                <p class="service-card__text">
                  Мы предлагаем гибкие условия аренды — от небольших кабинетов для одного
                  специалиста до просторных помещений для команды.
                </p>
              </div>
            </div>
            <div class="service-card">
              <div class="service-card__shadow"></div>
              <div class="service-card__body">
                <h3 class="service-card__title">Коворкинг</h3>
                <p class="service-card__text">
                  Мы создали место, в котором комфортно работать. Где интернет не подводит, а кофе —
                  всегда горячий.
                </p>
              </div>
            </div>
          </div>
          <img src="/man-main.png" alt="man" class="services__man" />
        </div>
      </div>
    </section>

    <!-- ===== LOCATION ===== -->
    <section class="location">
      <div class="location__container">
        <div class="location__info">
          <div class="location__text">
            <img src="/routing-main.svg" alt="routing" />
            <p>
              Нас легко найти — и ещё легче приехать. Рядом — парковка, остановки общественного
              транспорта и всё, что нужно для комфортного визита. Посмотрите, как к нам добраться —
              и заходите в гости. Мы всегда рады!
            </p>
          </div>
          <button class="location__btn">Проложить маршрут</button>
        </div>
        <div ref="mapRef" class="location__map"></div>
      </div>
    </section>
  </main>
</template>

<style lang="scss" scoped>
  @use '/src/assets/styles/variables' as *;
  @use '/src/assets/styles/mixins' as *;

  // ===== HERO =====
  .hero {
    &__inner {
      @include container;
      display: flex;
      align-items: center;
    }

    &__image {
      max-height: 43.75rem;
      height: 100%;
      object-fit: contain;
      flex-shrink: 0;
    }

    &__content {
      flex: 1;
      display: flex;
      justify-content: flex-end;
    }

    &__text-block {
      max-width: 48rem;
      width: 100%;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 4rem;
      padding-right: 3rem;
    }

    &__title {
      font-family: $font-heading;
      font-size: $text-3xl;
      text-align: center;
      max-width: 26rem;
      line-height: 1.35;
    }

    &__description {
      font-size: $text-xl;
      line-height: 1.8;

      p + p {
        margin-top: 2rem;
      }
    }

    &__btn {
      font-size: $text-xl;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      padding: 0.8rem 3.75rem;
      color: $color-text;
      transition:
        background-color 0.25s ease,
        color 0.25s ease;

      &:hover {
        background-color: $color-text;
        color: #fff;
      }
    }
  }

  // ===== ABOUT =====
  .about {
    margin-top: $section-gap-lg;

    &__container {
      @include container;
    }

    &__title {
      font-family: $font-heading;
      font-size: $text-3xl;
      margin-bottom: 4rem;
    }

    &__body {
      position: relative;
      display: flex;
      align-items: center;
      justify-content: flex-end;
    }

    &__image {
      position: absolute;
      left: 0;
      pointer-events: none;
    }

    &__list {
      display: flex;
      flex-direction: column;
      gap: 2rem;
      max-width: 46rem;
      border: 1px solid $color-border;
      border-radius: $radius-lg;
      padding: 4rem 5rem;
      background: transparent;
      font-size: $text-lg;
      line-height: 1.65;
    }

    &__item {
      display: flex;
      gap: 0.75rem;

      img {
        width: 20px;
        height: 20px;
        object-fit: contain;
        flex-shrink: 0;
        margin-top: 0.2rem;
      }
    }
  }

  // ===== SERVICES =====
  .services {
    margin-top: $section-gap-md;

    &__container {
      @include container;
    }

    &__title {
      font-family: $font-heading;
      font-size: $text-3xl;
      text-align: center;
      margin-bottom: 3.5rem;
    }

    &__inner {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: $gap-lg;
    }

    &__cards {
      display: flex;
      justify-content: center;
      gap: $gap-xl;
    }

    &__man {
      flex-shrink: 0;
    }
  }

  .service-card {
    position: relative;
    display: inline-block;

    &__shadow {
      position: absolute;
      inset: 0;
      border-radius: $card-radius;
      transform: translate(-$card-offset, $card-offset);
      background: linear-gradient(135deg, $color-shadow-from, $color-shadow-to);
    }

    &__body {
      position: relative;
      background-color: $color-card-bg;
      border-radius: $card-radius;
      width: $card-size;
      height: $card-size;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 0 2.5rem;
      text-align: center;
    }

    &__title {
      font-size: $text-2xl;
      font-weight: 500;
      margin-bottom: 1.5rem;
    }

    &__text {
      font-size: $text-lg;
      line-height: 1.6;
    }
  }

  // ===== LOCATION =====
  .location {
    margin-top: $section-gap-md;
    margin-bottom: $section-gap-md;

    &__container {
      @include container;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: $gap-lg;
    }

    &__info {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: $gap-lg;
    }

    &__text {
      display: flex;
      align-items: flex-start;
      gap: $gap-md;
      font-size: $text-xl;
      max-width: 28rem;
      line-height: 1.65;

      img {
        width: 36px;
        height: 36px;
        flex-shrink: 0;
      }
    }

    &__btn {
      font-size: $text-xl;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      padding: 0.5rem 3.75rem;
      color: $color-text;
      transition:
        background-color 0.25s ease,
        color 0.25s ease;

      &:hover {
        background-color: $color-text;
        color: #fff;
      }
    }

    &__map {
      min-width: $map-min-w;
      height: $map-height;
      border-radius: $radius-sm;
      overflow: hidden;
    }
  }
</style>
