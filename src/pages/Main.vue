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
  <section class="w-full">
    <div class="flex items-center">
      <img src="/skyscraper-main.png" alt="skyscraper" class="h-full max-h-175 object-contain" />

      <div class="flex-1 flex justify-end">
        <div class="max-w-3xl w-full flex flex-col items-center gap-28 pr-20">
          <h1 class="font-heading text-3xl text-center max-w-xl">
            Добро пожаловать в бизнес центр “Рабочая точка.”
          </h1>

          <div class="max-w-2xl text-xl">
            <p class="mb-10">
              Здесь вы найдёте всё, что нужно для работы без лишних хлопот: современные офисы под
              ключ, переговорные с техникой и тишиной, гибкий коворкинг — и команду, которая всегда
              готова помочь.
            </p>
            <p>
              Ни суеты, ни нервов из-за мелочей — только чёткая организация, уважение к вашему
              времени и пространство, в котором хочется остаться.
            </p>
          </div>

          <a
            href="#about"
            class="text-xl border cursor-pointer border-gray-400 rounded-xl px-15 py-2"
          >
            Подробнее
          </a>
        </div>
      </div>
    </div>
  </section>

  <section class="mt-50" id="about">
    <h2 class="font-heading text-3xl mb-20 ml-100">Почему мы?</h2>

    <div class="relative flex items-center justify-center">
      <img src="/working-main.png" alt="working" class="absolute left-35" />

      <ul
        class="ml-auto flex flex-col gap-9 max-w-3xl border border-gray-400 rounded-2xl py-25 px-35 bg-transparent text-lg"
      >
        <li class="flex gap-3">
          <img src="/flash.svg" alt="" />
          <p>Всё под рукой — от быстрого Wi-Fi и современного оборудования до кофе и парковки.</p>
        </li>

        <li class="flex gap-3">
          <img src="/flash.svg" alt="" />
          <p>
            Ни минуты впустую — бронируйте онлайн, приходите и сразу начинайте встречу. Всё уже
            готово.
          </p>
        </li>

        <li class="flex gap-3">
          <img src="/flash.svg" alt="" />
          <p>
            Тишина и порядок — никакого шума, хаоса или отвлекающих факторов. Только продуктивность.
          </p>
        </li>

        <li class="flex gap-3">
          <img src="/flash.svg" alt="" />
          <p>
            Люди, а не клиенты — мы ценим каждого, кто к нам приходит, и всегда рады помочь лично.
          </p>
        </li>
      </ul>
    </div>
  </section>

  <section class="mt-40 flex gap-10 items-center justify-center">
    <div class="flex justify-between text-center gap-15">
      <div class="relative inline-block">
        <div
          class="absolute inset-0 rounded-xl -translate-x-3.5 translate-y-3.5 bg-linear-to-br from-orange-200 to-red-300"
        ></div>
        <div
          class="relative bg-zinc-300 rounded-xl h-80 w-80 flex flex-col items-center justify-center px-10"
        >
          <h3 class="text-2xl mb-7">Переговорные комнаты</h3>
          <p class="text-lg">
            Нужно провести встречу, не отвлекаясь на шум офиса? Наши переговорные созданы именно для
            этого.
          </p>
        </div>
      </div>

      <div class="relative inline-block">
        <div
          class="absolute inset-0 rounded-xl -translate-x-3.5 translate-y-3.5 bg-linear-to-br from-orange-200 to-red-300"
        ></div>
        <div
          class="relative bg-zinc-300 rounded-xl h-80 w-80 flex flex-col items-center justify-center px-10"
        >
          <h3 class="text-2xl mb-7">Офисы</h3>
          <p class="text-lg">
            Мы предлагаем гибкие условия аренды — от небольших кабинетов для одного специалиста до
            просторных помещений для команды.
          </p>
        </div>
      </div>

      <div class="relative inline-block">
        <div
          class="absolute inset-0 rounded-xl -translate-x-3.5 translate-y-3.5 bg-linear-to-br from-orange-200 to-red-300"
        ></div>
        <div
          class="relative bg-zinc-300 rounded-xl h-80 w-80 flex flex-col items-center justify-center px-10"
        >
          <h3 class="text-2xl mb-7">Коворкинг</h3>
          <p class="text-lg">
            Мы создали место, в котором комфортно работать. Где интернет не подводит, а кофе —
            всегда горячий.
          </p>
        </div>
      </div>
    </div>

    <img src="/man-main.png" alt="man" />
  </section>

  <section class="mt-40 mb-40 flex gap-10 items-center justify-center">
    <div class="flex flex-col gap-10 items-center">
      <div class="flex justify-between gap-10 items-start text-2xl">
        <img src="/routing-main.svg" alt="routing" />
        <p>
          Нас легко найти — и ещё легче приехать. Рядом — парковка, остановки общественного
          транспорта и всё, что нужно для комфортного визита. Посмотрите, как к нам добраться — и
          заходите в гости. Мы всегда рады!
        </p>
      </div>
      <button class="text-xl border border-gray-400 rounded-xl px-15 py-2">
        Проложить маршрут
      </button>
    </div>
    <div ref="mapRef" class="min-w-3xl h-145"></div>
  </section>
</template>
