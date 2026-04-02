<script setup>
import { computed, onMounted, ref } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/store/auth';
import { usePlacesStore } from '@/store/places';
import { storeToRefs } from 'pinia';
import ArchivedPlaceCard from '@/components/ArchivedPlaceCard.vue';
import AppPagination from '@/components/AppPagination.vue';

const router = useRouter();
const authStore = useAuthStore();
const placesStore = usePlacesStore();

const { places, isLoading } = storeToRefs(placesStore);

const errorMessage = ref('');
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
    errorMessage.value = '';
    try {
        await placesStore.deletePlace(placeId);
    } catch (error) {
        errorMessage.value = error.response?.data?.message || 'Не удалось удалить помещение';
    }
}

async function handleRestorePlace(placeId) {
    errorMessage.value = '';
    try {
        await placesStore.restorePlace(placeId);
        await loadArchivedPlaces();
    } catch (error) {
        errorMessage.value = error.response?.data?.message || 'Не удалось восстановить помещение';
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

            <p v-if="errorMessage" class="error-message">{{ errorMessage }}</p>

            <div v-if="isLoading" class="loading">
                <div class="spinner"></div>
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

            <div v-else class="empty-state">
                <p>Архив пуст</p>
                <p class="empty-state__hint">Архивные помещения появятся здесь</p>
            </div>

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

</style>
