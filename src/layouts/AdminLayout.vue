<script setup>
  import Sidebar from '@/components/admin/Sidebar.vue';
</script>

<template>
  <div class="admin-layout">
    <Sidebar />

    <main class="admin-layout__content">
      <router-view />
    </main>
  </div>
</template>

<style scoped>
  .admin-layout {
    display: flex;
    min-height: 100vh;
  }

  .admin-layout__content {
    flex: 1;
    padding: 40px;
  }
</style>
