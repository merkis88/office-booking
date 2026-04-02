<script setup>
import { ref, computed, onMounted } from 'vue';
import RequestsTable from '@/components/RequestsTable.vue';
import AppPagination from '@/components/AppPagination.vue';
import axios from 'axios';

const requests = ref([]);
const isLoading = ref(false);

const currentPage = ref(1);
const lastPage = ref(1);
const total = ref(0);

const totalPages = computed(() => lastPage.value);

function goToPage(page) {
    if (page >= 1 && page <= totalPages.value) {
        currentPage.value = page;
        loadRequests();
    }
}

async function loadRequests() {
    isLoading.value = true;

    try {
        const { data } = await axios.get('/api/admin/services/completed', {
            params: { page: currentPage.value },
        });

        if (data.success && Array.isArray(data.data)) {
            requests.value = data.data;

            if (data.meta) {
                currentPage.value = data.meta.current_page;
                lastPage.value = data.meta.last_page;
                total.value = data.meta.total;
            }
        } else if (Array.isArray(data)) {
            requests.value = data;
        }
    } catch {
        requests.value = [];
    } finally {
        isLoading.value = false;
    }
}

onMounted(async () => {
    await loadRequests();
});
</script>

<template>
    <div class="requests-history">
        <div class="requests-history__container">
            <!-- Заголовок -->
            <h1 class="requests-history__title">История заявок</h1>

            <!-- Таблица (без кнопки редактирования) -->
            <RequestsTable
                :requests="requests"
                :is-loading="isLoading"
                :show-edit-button="false"
            />

            <!-- Пагинация -->
            <AppPagination
                v-if="!isLoading"
                :current-page="currentPage"
                :total-pages="totalPages"
                @update:current-page="goToPage"
            />
        </div>
    </div>
</template>

<style lang="scss" scoped>
@use '@/assets/styles/variables' as *;
@use '@/assets/styles/mixins' as *;

.requests-history {
    min-height: 100vh;
    padding: 2rem;

    &__container {
        @include container;
        max-width: 1400px;
    }

    &__title {
        font-family: $font-title;
        font-size: $text-3xl;
        font-weight: 400;
        color: $color-text;
        text-align: center;
        margin-bottom: 2rem;
    }

    @media (max-width: 768px) {
        padding: 1rem;

        &__title {
            font-size: $text-2xl;
        }
    }
}
</style>
