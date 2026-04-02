<script setup>
import { ref, computed, onMounted } from 'vue';
import RequestsTable from '@/components/RequestsTable.vue';
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
            <div v-if="totalPages > 1 && !isLoading" class="requests-history__pagination">
                <button
                    class="requests-history__pagination-btn"
                    :disabled="currentPage === 1"
                    @click="goToPage(currentPage - 1)"
                >
                    <img src="@/assets/images/icons/arrow-left.svg" alt="Назад" />
                </button>

                <button
                    v-for="page in totalPages"
                    :key="page"
                    class="requests-history__pagination-number"
                    :class="{ 'requests-history__pagination-number--active': currentPage === page }"
                    @click="goToPage(page)"
                >
                    {{ page }}
                </button>

                <button
                    class="requests-history__pagination-btn"
                    :disabled="currentPage === totalPages"
                    @click="goToPage(currentPage + 1)"
                >
                    <img src="@/assets/images/icons/arrow-right.svg" alt="Вперед" />
                </button>
            </div>
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

    &__pagination {
        display: flex;
        justify-content: center;
        align-items: center;
        gap: 0.5rem;
        margin-top: 2rem;
    }

    &__pagination-btn {
        width: 2.5rem;
        height: 2.5rem;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        transition: all 0.2s;

        img {
            width: 2.25rem;
            height: 2.25rem;
        }

        &:hover:not(:disabled) {
            transform: scale(1.15);
        }

        &:disabled {
            opacity: 0.4;
            cursor: not-allowed;
        }
    }

    &__pagination-number {
        width: 2.5rem;
        height: 2.5rem;
        display: flex;
        align-items: center;
        justify-content: center;
        background: $color-btn-profile;
        border-radius: $radius-sm;
        font-size: $text-base;
        font-weight: 500;
        color: $color-text;
        cursor: pointer;
        transition: all 0.2s;

        &:hover {
            background: rgba(255, 255, 255, 0.8);
        }

        &--active {
            background: $color-footer-bg;
        }
    }

    @media (max-width: 768px) {
        padding: 1rem;

        &__title {
            font-size: $text-2xl;
        }
    }
}
</style>
