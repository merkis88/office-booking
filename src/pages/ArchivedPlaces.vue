<script setup>
import { computed, onMounted, ref } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/store/auth';
import { usePlacesStore } from '@/store/places';
import { storeToRefs } from 'pinia';
import ArchivedPlaceCard from '@/components/ArchivedPlaceCard.vue';

const router = useRouter();
const authStore = useAuthStore();
const placesStore = usePlacesStore();

const { places, isLoading } = storeToRefs(placesStore);

const currentPage = ref(1);
const itemsPerPage = 6;

const totalPages = computed(() => {
    return Math.ceil(places.value.length / itemsPerPage);
});

const paginatedPlaces = computed(() => {
    const start = (currentPage.value - 1) * itemsPerPage;
    const end = start + itemsPerPage;
    return places.value.slice(start, end);
});

function goToPage(page) {
    if (page >= 1 && page <= totalPages.value) {
        currentPage.value = page;
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }
}

async function loadArchivedPlaces() {
    await placesStore.fetchArchivedPlaces();
    currentPage.value = 1;
}

async function handleDeletePlace(placeId) {
    const result = await placesStore.deletePlace(placeId);

    if (result.success) {
        console.log('Помещение удалено');
    } else {
        alert(result.error);
    }
}

async function handleRestorePlace(placeId) {
    const result = await placesStore.restorePlace(placeId);

    if (result.success) {
        await loadArchivedPlaces();
    } else {
        alert(result.error);
    }
}

onMounted(async () => {
    if (!authStore.isAdmin) {
        router.push('/');
        return;
    }

    await loadArchivedPlaces();
});
</script>

<template>
    <div class="archived-places">
        <div class="archived-places__container">
            <div class="archived-places__header">
                <h1 class="archived-places__title">Архив помещений</h1>
            </div>

            <div v-if="isLoading" class="archived-places__loading">
                <div class="archived-places__spinner"></div>
                <p>Загрузка...</p>
            </div>

            <div v-else-if="paginatedPlaces.length > 0" class="archived-places__grid">
                <ArchivedPlaceCard
                    v-for="place in paginatedPlaces"
                    :key="place.id"
                    :place="place"
                    @delete-place="handleDeletePlace"
                    @restore-place="handleRestorePlace"
                />
            </div>

            <div v-else class="archived-places__empty">
                <p>Архив пуст</p>
                <p class="archived-places__empty-hint">Архивные помещения появятся здесь</p>
            </div>

            <div v-if="totalPages > 1 && !isLoading" class="archived-places__pagination">
                <button
                    class="archived-places__pagination-btn"
                    :disabled="currentPage === 1"
                    @click="goToPage(currentPage - 1)"
                >
                    <img src="@/assets/images/icons/arrow-left.svg" alt="Назад" />
                </button>

                <button
                    v-for="page in totalPages"
                    :key="page"
                    class="archived-places__pagination-number"
                    :class="{ 'archived-places__pagination-number--active': currentPage === page }"
                    @click="goToPage(page)"
                >
                    {{ page }}
                </button>

                <button
                    class="archived-places__pagination-btn"
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

.archived-places {
    min-height: 100vh;
    padding: 4rem 2rem;

    &__container {
        @include container;
        max-width: 1400px;
    }

    &__header {
        margin-bottom: 3rem;
    }

    &__title {
        font-family: $font-title;
        font-size: $text-3xl;
        font-weight: 500;
        color: $color-text;
        text-align: center;
    }

    &__grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(500px, 1fr));
        gap: 2rem;
        margin-bottom: 3rem;
    }

    &__loading {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        min-height: 400px;
        gap: 1rem;
    }

    &__spinner {
        width: 40px;
        height: 40px;
        border: 3px solid rgba($color-text, 0.2);
        border-top-color: $color-text;
        border-radius: 50%;
        animation: spin 0.8s linear infinite;
    }

    &__empty {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        min-height: 400px;
        font-size: $text-lg;
        color: $color-text;
        gap: 1rem;
    }

    &__empty-hint {
        font-size: $text-base;
        color: rgba($color-text, 0.6);
    }

    &__pagination {
        display: flex;
        justify-content: center;
        align-items: center;
        gap: 0.5rem;
    }

    &__pagination-btn {
        img {
            width: 2.5rem;
            height: 2.5rem;
        }

        &:hover:not(:disabled) {
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        &:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
    }

    &__pagination-number {
        width: 2.5rem;
        height: 2.5rem;
        display: flex;
        align-items: center;
        justify-content: center;
        border: 1px solid $color-border;
        border-radius: $radius-xs;
        background: $color-input-bg;
        color: $color-text;
        font-size: $text-base;
        cursor: pointer;
        transition: all 0.2s;
        font-weight: 500;

        &:hover {
            background: $color-input-bg-dark;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        &--active {
            background: $color-header-bg;
            font-weight: 600;
            border-color: $color-text;
        }
    }

    @media (max-width: 768px) {
        padding: 2rem 1rem;

        &__title {
            font-size: $text-2xl;
        }

        &__grid {
            grid-template-columns: 1fr;
        }
    }
}

@keyframes spin {
    to {
        transform: rotate(360deg);
    }
}
</style>
