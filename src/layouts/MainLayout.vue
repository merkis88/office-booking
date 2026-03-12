<script setup>
  import Header from '@/components/Header.vue';
  import Footer from '@/components/Footer.vue';
</script>

<template>
  <div class="layout">
    <Header />

    <main class="layout__content">
      <router-view />
    </main>

    <Footer />
  </div>
</template>

<style scoped>
  .layout {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
  }

  .layout__content {
    flex: 1;
  }
</style>
