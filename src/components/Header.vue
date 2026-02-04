<script setup></script>

<template>
  <div class="flex justify-between bg-zinc-300 p-9 rounded-2xl">
    <router-link to="/">
      <div class="flex items-center justify-between gap-2 cursor-pointer">
        <img src="/logo.svg" alt="logo" />
        <a>LOGOTYPE</a>
      </div>
    </router-link>
    <ul class="flex items-center justify-between gap-10 text-lg cursor-pointer">
      <li>Услуги</li>
      <li>Пропуск</li>
      <li>Личный кабинет</li>
      <router-link to="/authorization"><li>Авторизация</li></router-link>
      <router-link to="/registration"><li>Регистрация</li></router-link>
    </ul>
  </div>
</template>
