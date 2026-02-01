<script setup></script>

<template>
  <div class="flex items-center justify-between max-h-full">
    <img src="/skyscraper-main.png" alt="skyscraper" />

    <div class="flex items-center flex-col gap-28">
      <h1 class="font-heading text-3xl text-center max-w-xl">
        Добро пожаловать в бизнес центр “Рабочая точка.”
      </h1>
      <div class="max-w-2xl text-xl">
        <p class="mb-10">
          Здесь вы найдёте всё, что нужно для работы без лишних хлопот: современные офисы под ключ,
          переговорные с техникой и тишиной, гибкий коворкинг — и команду, которая всегда готова
          помочь.
        </p>
        <p>
          Ни суеты, ни нервов из-за мелочей — только чёткая организация, уважение к вашему времени и
          пространство, в котором хочется остаться.
        </p>
      </div>
      <button class="text-xl border-solid border rounded-xl px-15 py-2">Подробнее</button>
    </div>
  </div>

  <div class="mt-50">
    <h2 class="font-heading text-3xl mb-20 ml-100">Почему мы?</h2>

    <div class="relative flex items-center">
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
  </div>

  <div class="mt-40 mb-40 flex gap-10 items-center">
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
            Мы создали место, в котором комфортно работать. Где не интернет не подводит, а кофе —
            всегда горячий.
          </p>
        </div>
      </div>
    </div>

    <img src="/man-main.png" alt="man" />
  </div>

  <div></div>
</template>
