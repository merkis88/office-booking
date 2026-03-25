<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/store/auth';
import { useServicesStore } from '@/store/services';
import ChangeStatusModal from '@/components/modals/ChangeStatusModal.vue';
import axios from 'axios';

const router = useRouter();
const authStore = useAuthStore();
const servicesStore = useServicesStore();

const requests = ref([]);
const isLoading = ref(false);
const searchQuery = ref('');
const selectedStatus = ref('all');
const showStatusDropdown = ref(false);

const currentPage = ref(1);
const lastPage = ref(1);
const perPage = ref(6);
const total = ref(0);

const showStatusModal = ref(false);
const requestToEdit = ref(null);

const topScrollRef = ref(null);
const tableScrollRef = ref(null);

const statusOptions = [
    { value: 'all', label: 'Все статусы' },
    { value: 'pending', label: 'В ожидании' },
    { value: 'in_progress', label: 'В работе' },
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

    const result = await servicesStore.updateServiceStatus(requestToEdit.value.id, data.status);

    if (!result.success) {
        throw new Error(result.error);
    }

    await loadRequests();
    requestToEdit.value = null;
}

function syncScrollFromTop() {
    if (topScrollRef.value && tableScrollRef.value) {
        tableScrollRef.value.scrollLeft = topScrollRef.value.scrollLeft;
    }
}

function syncScrollFromTable() {
    if (topScrollRef.value && tableScrollRef.value) {
        topScrollRef.value.scrollLeft = tableScrollRef.value.scrollLeft;
    }
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
                perPage.value = data.meta.per_page;
                total.value = data.meta.total;
            }
        } else if (Array.isArray(data)) {
            requests.value = data;
        }
    } catch (error) {
        console.error('Ошибка загрузки заявок:', error);
        requests.value = [];
    } finally {
        isLoading.value = false;
    }
}

function getStatusClass(status) {
    const statusClasses = {
        pending: 'status--pending',
        in_progress: 'status--in-progress',
        completed: 'status--completed',
        rejected: 'status--rejected',
    };
    return statusClasses[status] || '';
}

onMounted(async () => {
    if (!authStore.isAdmin) {
        router.push('/');
        return;
    }

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
            <div class="user-requests__header">
                <div class="user-requests__controls">
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

            <h1 class="user-requests__title">Заявки пользователей</h1>

            <div v-if="!isLoading && requests.length > 0" class="user-requests__results-count">
                Найдено: {{ filteredRequests.length }} из {{ requests.length }}
            </div>

            <div
                v-if="!isLoading && filteredRequests.length > 0"
                ref="topScrollRef"
                class="user-requests__top-scroll"
                @scroll="syncScrollFromTop"
            >
                <div class="user-requests__top-scroll-content"></div>
            </div>

            <div class="user-requests__table-wrapper">
                <div v-if="isLoading" class="user-requests__loading">
                    <div class="user-requests__spinner"></div>
                </div>

                <div v-else-if="filteredRequests.length === 0" class="user-requests__empty">
                    <p>{{ requests.length === 0 ? 'Заявок пока нет' : 'Ничего не найдено' }}</p>
                    <button
                        v-if="requests.length > 0"
                        class="user-requests__reset-btn"
                        @click="resetFilters"
                    >
                        Сбросить фильтры
                    </button>
                </div>

                <div
                    v-else
                    ref="tableScrollRef"
                    class="user-requests__scroll-container"
                    @scroll="syncScrollFromTable"
                >
                    <table class="user-requests__table">
                        <thead>
                        <tr>
                            <th>Тип заявки</th>
                            <th>Фамилия</th>
                            <th>Имя</th>
                            <th>Отчество</th>
                            <th>Email</th>
                            <th>Должность</th>
                            <th>Компания</th>
                            <th>Тип помещения</th>
                            <th>Кабинет№</th>
                            <th>Дата бронирования</th>
                            <th>Время бронирования</th>
                            <th>Дата заявки</th>
                            <th>Время заявки</th>
                            <th>Комментарий</th>
                            <th>Статус</th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr v-for="request in filteredRequests" :key="request.id" class="user-requests__row">
                            <td>{{ request.service_type?.name || '—' }}</td>
                            <td>{{ request.user?.last_name || '—' }}</td>
                            <td>{{ request.user?.first_name || '—' }}</td>
                            <td>{{ request.user?.patronymic || '—' }}</td>
                            <td>{{ request.user?.email || '—' }}</td>
                            <td>{{ request.user?.post || '—' }}</td>
                            <td>{{ request.user?.company || '—' }}</td>
                            <td>{{ request.booking?.place?.type_name || '—' }}</td>
                            <td>№{{ request.booking?.place?.number_place || '—' }}</td>
                            <td>{{ request.booking?.start_time?.split(' ')[0] || '—' }}</td>
                            <td>
                                {{ request.booking?.start_time?.split(' ')[1] || '—' }} -
                                {{ request.booking?.end_time?.split(' ')[1] || '—' }}
                            </td>
                            <td>{{ request.service_date || '—' }}</td>
                            <td>{{ request.service_time || '—' }}</td>
                            <td>{{ request.comment || '—' }}</td>
                            <td>
                                <div class="user-requests__actions">
                    <span
                        class="user-requests__status"
                        :class="getStatusClass(request.status)"
                    >
                      {{ request.status_name || '—' }}
                    </span>
                                    <button
                                        v-if="request.status !== 'rejected' && request.status !== 'completed'"
                                        class="user-requests__action-btn"
                                        @click.stop="openStatusModal(request)"
                                        aria-label="Изменить статус"
                                    >
                                        <img src="@/assets/images/icons/edit.svg" alt="Изменить статус" />
                                    </button>
                                </div>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <div v-if="totalPages > 1 && !isLoading" class="user-requests__pagination">
                <button
                    class="user-requests__pagination-btn"
                    :disabled="currentPage === 1"
                    @click="goToPage(currentPage - 1)"
                >
                    <img src="@/assets/images/icons/arrow-left.svg" alt="Назад" />
                </button>

                <button
                    v-for="page in totalPages"
                    :key="page"
                    class="user-requests__pagination-number"
                    :class="{ 'user-requests__pagination-number--active': currentPage === page }"
                    @click="goToPage(page)"
                >
                    {{ page }}
                </button>

                <button
                    class="user-requests__pagination-btn"
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

    &__reset-btn {
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

        &:hover {
            background: rgba(255, 255, 255, 0.8);
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
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

    &__top-scroll {
        overflow-x: auto;
        overflow-y: hidden;
        margin-bottom: 0.5rem;
        height: 14px;

        &::-webkit-scrollbar {
            height: 14px;
        }

        &::-webkit-scrollbar-track {
            background: #b2c1cb;
            border-radius: 10px;
        }

        &::-webkit-scrollbar-thumb {
            background: transparent;
            border: 2px solid $color-text;
            border-radius: 10px;
            background-clip: padding-box;

            &:hover {
                background: rgba(255, 255, 255, 0.3);
                border-color: $color-text;
            }

            &:active {
                background: rgba(255, 255, 255, 0.5);
            }
        }

        scrollbar-width: thin;
        scrollbar-color: transparent #b2c1cb;
    }

    &__top-scroll-content {
        width: 3500px;
        height: 1px;
    }

    &__table-wrapper {
        background: rgba(255, 255, 255, 0.7);
        border-radius: $radius-sm;
        padding: 1.5rem;
        margin-bottom: 2rem;
    }

    &__loading {
        display: flex;
        justify-content: center;
        padding: 3rem;
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
        text-align: center;
        padding: 3rem;
        font-size: $text-lg;
        color: rgba($color-text, 0.6);
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 1rem;
    }

    &__scroll-container {
        overflow-x: auto;
        overflow-y: visible;
        max-width: 100%;

        &::-webkit-scrollbar {
            display: none;
        }

        scrollbar-width: none;
        -ms-overflow-style: none;
    }

    &__table {
        width: 100%;
        min-width: 3000px;
        border-collapse: separate;
        border-spacing: 0 0.75rem;

        thead {
            tr {
                th {
                    padding: 1rem 1.5rem;
                    text-align: left;
                    font-size: $text-base;
                    font-weight: 500;
                    color: $color-text;
                    white-space: nowrap;
                }
            }
        }

        tbody {
            tr {
                background: transparent;
                cursor: pointer;
                transition: all 0.2s;

                td {
                    padding: 1rem;
                    font-size: $text-base;
                    color: $color-text;
                    white-space: nowrap;
                    border-top: 1px solid $color-text;
                    border-bottom: 1px solid $color-text;

                    &:first-child {
                        border-left: 1px solid $color-text;
                        border-top-left-radius: $radius-sm;
                        border-bottom-left-radius: $radius-sm;
                    }

                    &:last-child {
                        border-right: 1px solid $color-text;
                        border-top-right-radius: $radius-sm;
                        border-bottom-right-radius: $radius-sm;
                    }
                }
            }
        }
    }

    &__status {
        padding: 0.375rem 0.75rem;
        border-radius: $radius-xs;
        font-size: $text-sm;
        font-weight: 500;
        white-space: nowrap;

        &.status--pending {
            background: #fff3cd;
            color: #856404;
        }

        &.status--in-progress {
            background: #d1ecf1;
            color: #0c5460;
        }

        &.status--completed {
            background: #d4edda;
            color: #155724;
        }

        &.status--rejected {
            background: #f8d7da;
            color: #721c24;
        }
    }

    &__actions {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 0.5rem;
    }

    &__action-btn {
        background: transparent;
        border: none;
        border-radius: $radius-xs;
        cursor: pointer;
        transition: all 0.2s;
        padding: 0.25rem;

        img {
            width: 24px;
            height: 24px;
        }

        &:hover {
            background: rgba($color-text, 0.1);
        }
    }

    &__pagination {
        display: flex;
        justify-content: center;
        align-items: center;
        gap: 0.5rem;
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

@keyframes spin {
    to {
        transform: rotate(360deg);
    }
}
</style>
