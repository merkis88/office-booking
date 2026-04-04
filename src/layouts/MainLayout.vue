<script setup>
import Header from '@/components/Header.vue';
import Footer from '@/components/Footer.vue';


import { onMounted, watch, computed  } from 'vue';
import { useRoute } from 'vue-router';
import { useAuthStore } from '@/store/auth';
import { useNotificationsStore } from '@/store/notifications';

const route = useRoute();
const authStore = useAuthStore();
const notificationsStore = useNotificationsStore();
const showFooter = computed(() => route.name !== 'NotFound');

async function loadNotifications() {
    if (authStore.isAuthenticated) {
        await notificationsStore.fetchNotifications();
    }
}

onMounted(() => {
    loadNotifications();
});

watch(
    () => route.path,
    () => {
        loadNotifications();
    },
);
</script>

<template>
    <div class="layout">
        <Header />

        <main class="layout__content">
            <router-view />
        </main>

        <Footer v-if="showFooter" />    </div>
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
