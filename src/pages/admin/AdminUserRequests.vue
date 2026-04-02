<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useServicesStore } from '@/store/services';
import ChangeStatusModal from '@/components/modals/ChangeStatusModal.vue';
import RequestsTable from '@/components/RequestsTable.vue';
import AppPagination from '@/components/AppPagination.vue';
import axios from 'axios';

const router = useRouter();
const servicesStore = useServicesStore();

const requests = ref([]);
const isLoading = ref(false);
const searchQuery = ref('');
const selectedStatus = ref('all');
const showStatusDropdown = ref(false);

const currentPage = ref(1);
const lastPage = ref(1);
const total = ref(0);

const showStatusModal = ref(false);
const requestToEdit = ref(null);

const statusOptions = [
    { value: 'all', label: 'Все статусы' },
    { value: 'pending', label: 'В ожидании' },
    { value: 'in_progress', label: 'В работе' },
    { value: 'completed', label: 'Выполнено' },
    { value: 'rejected', label: 'Отклонено' },
];

const selectedStatusLabel = computed(() => {
    const option = statusOptions.find((opt) => opt.value === selectedStatus.value);
    return option ? option.label : 'Все статусы';
});

const filteredRequests = computed(() => {
    let result = requests.value;

    if (selectedStatus.value !== 'all') {
        result = result.filter((request) => request.status === selectedStatus.value);
    }

    if (searchQuery.value.trim()) {
        const query = searchQuery.value.toLowerCase();
        result = result.filter((request) => {
            const serviceTypeName = request.service_type?.name?.toLowerCase() || '';
            const lastName = request.user?.last_name?.toLowerCase() || '';
            const firstName = request.user?.first_name?.toLowerCase() || '';
            const email = request.user?.email?.toLowerCase() || '';

            return (
                serviceTypeName.includes(query) ||
                lastName.includes(query) ||
                firstName.includes(query) ||
                email.includes(query)
            );
        });
    }

    return result;
});

const totalPages = computed(() => lastPage.value);

function goToPage(page) {
    if (page >= 1 && page <= totalPages.value) {
        currentPage.value = page;
        loadRequests();
    }
}

function toggleStatusDropdown() {
    showStatusDropdown.value = !showStatusDropdown.value;
}

function selectStatus(value) {
    selectedStatus.value = value;
    showStatusDropdown.value = false;
}

function resetFilters() {
    selectedStatus.value = 'all';
    searchQuery.value = '';
}

function openStatusModal(request) {
    requestToEdit.value = request;
    showStatusModal.value = true;
}

async function handleChangeStatus(data) {
    if (!requestToEdit.value) return;

    await servicesStore.updateServiceStatus(requestToEdit.value.id, data.status);
    await loadRequests();
    requestToEdit.value = null;
}

async function loadRequests() {
    isLoading.value = true;

    try {
        const { data } = await axios.get('/api/admin/services', {
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
    <ChangeStatusModal
        v-model="showStatusModal"
        :request="requestToEdit"
        @change-status="handleChangeStatus"
    />

    <div class="user-requests">
        <div class="user-requests__container">
            <!-- Верхняя панель с фильтрами -->
            <div class="user-requests__header">
                <div class="user-requests__controls">
                    <!-- Dropdown фильтр по статусу -->
                    <div class="user-requests__dropdown">
                        <button class="user-requests__dropdown-btn" @click="toggleStatusDropdown">
                            <img src="@/assets/images/icons/filter.svg" alt="" />
                            <span>{{ selectedStatusLabel }}</span>
                        </button>

                        <Transition name="dropdown">
                            <div v-if="showStatusDropdown" class="user-requests__dropdown-menu">
                                <button
                                    v-for="option in statusOptions"
                                    :key="option.value"
                                    class="user-requests__dropdown-item"
                                    :class="{ 'user-requests__dropdown-item--active': selectedStatus === option.value }"
                                    @click="selectStatus(option.value)"
                                >
                                    {{ option.label }}
                                </button>
                            </div>
                        </Transition>
                    </div>

                    <!-- Поиск -->
                    <div class="user-requests__search">
                        <img src="@/assets/images/icons/search.svg" alt="" />
                        <input
                            v-model="searchQuery"
                            type="text"
                            class="user-requests__search-input"
                            placeholder="Поиск..."
                        />
                    </div>
                </div>
            </div>

            <!-- Заголовок -->
            <h1 class="user-requests__title">Заявки пользователей</h1>

            <!-- Счетчик результатов -->
            <div v-if="!isLoading && requests.length > 0" class="user-requests__results-count">
                Найдено: {{ filteredRequests.length }} из {{ requests.length }}
            </div>

            <!-- Таблица -->
            <RequestsTable
                :requests="filteredRequests"
                :is-loading="isLoading"
                :show-edit-button="true"
                @edit-status="openStatusModal"
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

.user-requests {
    min-height: 100vh;
    padding: 2rem;

    &__container {
        @include container;
        max-width: 1400px;
    }

    &__header {
        margin-bottom: 2rem;
    }

    &__controls {
        display: flex;
        gap: 1rem;
    }

    &__dropdown {
        position: relative;
    }

    &__dropdown-btn {
        display: flex;
        align-items: center;
        gap: 0.75rem;
        padding: 0.75rem 1.5rem;
        background: $color-btn-profile;
        border: 1px solid $color-text;
        border-radius: $radius-sm;
        font-size: $text-base;
        font-weight: 500;
        color: $color-text;
        cursor: pointer;
        transition: all 0.2s;
        font-family: $font-base;
        white-space: nowrap;

        img {
            width: 20px;
            height: 20px;
        }

        &:hover {
            background: rgba(255, 255, 255, 0.8);
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
    }

    &__dropdown-menu {
        position: absolute;
        top: calc(100% + 0.5rem);
        left: 0;
        background: $color-btn-profile;
        border: 1px solid $color-text;
        border-radius: $radius-sm;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        min-width: 200px;
        z-index: 100;
        overflow: hidden;
    }

    &__dropdown-item {
        width: 100%;
        padding: 0.875rem 1.5rem;
        text-align: left;
        background: transparent;
        border: none;
        font-size: $text-base;
        color: $color-text;
        cursor: pointer;
        transition: all 0.2s;
        font-family: $font-base;
        border-bottom: 1px solid rgba($color-text, 0.1);

        &:last-child {
            border-bottom: none;
        }

        &:hover {
            background: rgba(255, 255, 255, 0.5);
        }

        &--active {
            background: rgba($color-text, 0.1);
            font-weight: 600;
        }
    }

    &__search {
        position: relative;
        flex: 1;
        max-width: 400px;

        img {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            width: 20px;
            height: 20px;
            opacity: 0.5;
        }
    }

    &__search-input {
        width: 100%;
        padding: 0.75rem 1rem 0.75rem 3rem;
        background: $color-btn-profile;
        border: 1px solid $color-text;
        border-radius: $radius-sm;
        font-size: $text-base;
        color: $color-text;
        font-family: $font-base;

        &:focus {
            outline: none;
            box-shadow: 0 0 0 3px rgba($color-text, 0.1);
        }

        &::placeholder {
            color: rgba($color-text, 0.5);
        }
    }

    &__results-count {
        text-align: center;
        font-size: $text-sm;
        color: rgba($color-text, 0.7);
        margin-bottom: 1rem;
    }

    &__title {
        font-family: $font-title;
        font-size: $text-3xl;
        font-weight: 400;
        color: $color-text;
        text-align: center;
        margin-bottom: 1.5rem;
    }

    @media (max-width: 768px) {
        padding: 1rem;

        &__controls {
            flex-direction: column;
        }

        &__search {
            max-width: 100%;
        }

        &__title {
            font-size: $text-2xl;
        }
    }
}

.dropdown-enter-active,
.dropdown-leave-active {
    transition: all 0.2s ease;
}

.dropdown-enter-from,
.dropdown-leave-to {
    opacity: 0;
    transform: translateY(-10px);
}
</style>
