<script setup>
  import Header from './components/Header.vue';
  import Footer from './components/Footer.vue';
</script>

<style lang="sass">
  @import "assets/sass/main.sass"
</style>

<template>
  <div class="font-base mx-70 mt-10">
    <Header />
    <router-view></router-view>
  </div>
  <Footer />
</template>
