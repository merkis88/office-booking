<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/store/auth';
import { useServicesStore } from '@/store/services';
import { storeToRefs } from 'pinia';
import DeleteConfirmModal from '@/components/modals/DeleteConfirmModal.vue';
import CreateServiceTypeModal from '@/components/modals/CreateServiceTypeModal.vue';
import EditServiceTypeModal from '@/components/modals/EditServiceTypeModal.vue';

const router = useRouter();
const authStore = useAuthStore();
const servicesStore = useServicesStore();

const { serviceTypes, isLoading } = storeToRefs(servicesStore);

const currentPage = ref(1);
const itemsPerPage = 10;

// ✅ Состояние модальных окон
const showDeleteModal = ref(false);
const showCreateModal = ref(false);
const showEditModal = ref(false);
const typeToDelete = ref(null);
const typeToEdit = ref(null);

const totalPages = computed(() => {
    return Math.ceil(serviceTypes.value.length / itemsPerPage);
});

const paginatedTypes = computed(() => {
    const start = (currentPage.value - 1) * itemsPerPage;
    const end = start + itemsPerPage;
    return serviceTypes.value.slice(start, end);
});

function goToPage(page) {
    if (page >= 1 && page <= totalPages.value) {
        currentPage.value = page;
    }
}

function openDeleteModal(type) {
    typeToDelete.value = type;
    showDeleteModal.value = true;
}

async function confirmDelete() {
    if (!typeToDelete.value) return;

    const result = await servicesStore.deleteServiceType(typeToDelete.value.id);

    if (result.success) {
        if (paginatedTypes.value.length === 0 && currentPage.value > 1) {
            currentPage.value--;
        }
    } else {
        alert(result.error);
    }

    typeToDelete.value = null;
}

async function handleCreateType(typeData) {
    const result = await servicesStore.createServiceType(typeData);

    if (!result.success) {
        throw new Error(result.error);
    }

    currentPage.value = Math.ceil(serviceTypes.value.length / itemsPerPage);
}

// ✅ НОВАЯ функция - открытие модалки редактирования
function editType(type) {
    typeToEdit.value = type;
    showEditModal.value = true;
}

// ✅ НОВАЯ функция - обновление типа
async function handleUpdateType(typeData) {
    if (!typeToEdit.value) return;

    const result = await servicesStore.updateServiceType(typeToEdit.value.id, typeData);

    if (!result.success) {
        throw new Error(result.error);
    }

    typeToEdit.value = null;
}

async function loadServiceTypes() {
    await servicesStore.fetchServiceTypes();
}

onMounted(async () => {
    if (!authStore.isAdmin) {
        router.push('/');
        return;
    }

    await loadServiceTypes();
});
</script>

<template>
    <!-- Модальное окно удаления -->
    <DeleteConfirmModal
        v-model="showDeleteModal"
        title="Удаление"
        message="Вы действительно хотите удалить тип заявки?"
        :item-name="typeToDelete?.name"
        confirm-text="Подтвердить"
        cancel-text="Отмена"
        @confirm="confirmDelete"
    />

    <!-- Модальное окно создания -->
    <CreateServiceTypeModal v-model="showCreateModal" @create="handleCreateType" />

    <!-- ✅ Модальное окно редактирования -->
    <EditServiceTypeModal
        v-model="showEditModal"
        :service-type="typeToEdit"
        @update="handleUpdateType"
    />

    <div class="admin-request-types">
        <div class="admin-request-types__container">
            <!-- Кнопки управления -->
            <div class="admin-request-types__controls">
                <button class="admin-request-types__control-btn">
                    <img src="@/assets/images/icons/history.svg" alt="" />
                    <span>История заявок</span>
                </button>

                <button class="admin-request-types__control-btn" @click="showCreateModal = true">
                    <img src="@/assets/images/icons/plus.svg" alt="" />
                    <span>Создать</span>
                </button>

                <router-link to="/admin/user-requests" class="admin-request-types__control-btn">
                    <img src="@/assets/images/icons/history-user.svg" alt="" />
                    <span>Заявки пользователей</span>
                </router-link>
            </div>

            <!-- Основной контент -->
            <div class="admin-request-types__content">
                <!-- Список типов заявок -->
                <div class="admin-request-types__list-section">
                    <h1 class="admin-request-types__title">Виды заявок</h1>

                    <div v-if="isLoading" class="admin-request-types__loading">
                        <div class="admin-request-types__spinner"></div>
                    </div>

                    <div v-else-if="serviceTypes.length === 0" class="admin-request-types__empty">
                        <p>Типов заявок пока нет</p>
                        <button class="admin-request-types__create-btn" @click="showCreateModal = true">
                            Создать первый тип
                        </button>
                    </div>

                    <div v-else class="admin-request-types__list">
                        <div class="admin-request-types__list-header">Тип заявки</div>

                        <div
                            v-for="type in paginatedTypes"
                            :key="type.id"
                            class="admin-request-types__item"
                        >
                            <span class="admin-request-types__item-name">{{ type.name }}</span>
                            <div class="admin-request-types__item-actions">
                                <button
                                    class="admin-request-types__action-btn"
                                    @click="editType(type)"
                                    aria-label="Редактировать"
                                >
                                    <img src="@/assets/images/icons/edit.svg" alt="Редактировать" />
                                </button>
                                <button
                                    class="admin-request-types__action-btn"
                                    @click="openDeleteModal(type)"
                                    aria-label="Удалить"
                                >
                                    <img src="@/assets/images/icons/delete-icon.svg" alt="Удалить" />
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Пагинация -->
                    <div v-if="totalPages > 1 && !isLoading" class="admin-request-types__pagination">
                        <button
                            class="admin-request-types__pagination-btn"
                            :disabled="currentPage === 1"
                            @click="goToPage(currentPage - 1)"
                        >
                            <img src="@/assets/images/icons/arrow-left.svg" alt="Назад" />
                        </button>

                        <button
                            v-for="page in totalPages"
                            :key="page"
                            class="admin-request-types__pagination-number"
                            :class="{ 'admin-request-types__pagination-number--active': currentPage === page }"
                            @click="goToPage(page)"
                        >
                            {{ page }}
                        </button>

                        <button
                            class="admin-request-types__pagination-btn"
                            :disabled="currentPage === totalPages"
                            @click="goToPage(currentPage + 1)"
                        >
                            <img src="@/assets/images/icons/arrow-right.svg" alt="Вперед" />
                        </button>
                    </div>
                </div>

                <!-- Иллюстрация -->
                <div class="admin-request-types__illustration">
                    <img src="@/assets/images/photos/admin-requests.png" alt="" />
                </div>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
@use '@/assets/styles/variables' as *;
@use '@/assets/styles/mixins' as *;

.admin-request-types {
    min-height: 100vh;

    &__container {
        @include container;
        max-width: 1400px;
    }

    &__controls {
        display: flex;
        gap: 1rem;
        margin-bottom: 3rem;
        flex-wrap: wrap;
    }

    &__control-btn {
        display: flex;
        align-items: center;
        gap: 0.75rem;
        padding: 0.875rem 3.5rem 0.875rem 0.875rem;
        background: $color-btn-profile;
        border: 1px solid $color-text;
        border-radius: $radius-sm;
        font-size: $text-base;
        font-weight: 500;
        color: $color-text;
        cursor: pointer;
        transition: all 0.2s;
        font-family: $font-base;

        img {
            width: 20px;
            height: 20px;
        }

        &:hover {
            background: rgba($color-text, 0.05);
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }

        &:active {
            transform: translateY(0);
        }
    }

    &__content {
        display: flex;
        gap: 4rem;
        align-items: flex-start;
    }

    &__list-section {
        flex: 0 0 420px;
    }

    &__title {
        font-family: $font-title;
        font-size: $text-3xl;
        font-weight: 400;
        color: $color-text;
        margin-bottom: 2rem;
        text-align: center;
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

    &__list {
        background: rgba(255, 255, 255, 0.7);
        border-radius: $radius-xs;
        padding: 1.5rem;
    }

    &__list-header {
        font-size: $text-base;
        font-weight: 400;
        color: $color-text;
        padding: 0 1rem 1rem;
        border-bottom: 1px solid rgba($color-text, 0.15);
        margin-bottom: 1rem;
    }

    &__item {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 1rem;
        background: transparent;
        border: 1px solid $color-footer-bg;
        border-radius: $radius-sm;
        margin-bottom: 0.75rem;
        transition: all 0.2s;

        &:hover {
            background: rgba($color-text, 0.02);
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
        }
    }

    &__item-name {
        font-size: $text-base;
        color: $color-text;
        font-weight: 500;
    }

    &__item-actions {
        display: flex;
        gap: 0.5rem;
    }

    &__action-btn {
        width: 32px;
        height: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: transparent;
        border: none;
        border-radius: $radius-xs;
        cursor: pointer;
        transition: all 0.2s;

        img {
            width: 20px;
            height: 20px;
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
        margin-top: 2rem;
    }

    &__pagination-btn {
        width: 2.5rem;
        height: 2.5rem;
        display: flex;
        align-items: center;
        justify-content: center;
        background: white;
        border: 1px solid $color-border;
        border-radius: 50%;
        cursor: pointer;
        transition: all 0.2s;

        img {
            width: 1.25rem;
            height: 1.25rem;
        }

        &:hover:not(:disabled) {
            background: rgba($color-text, 0.05);
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
        background: white;
        border: 1px solid $color-border;
        border-radius: 50%;
        font-size: $text-base;
        font-weight: 500;
        color: $color-text;
        cursor: pointer;
        transition: all 0.2s;

        &:hover {
            background: rgba($color-text, 0.05);
        }

        &--active {
            background: $color-text;
            color: white;
            border-color: $color-text;
        }
    }

    &__illustration {
        flex: 1;
        display: flex;
        align-items: center;
        justify-content: center;
        padding-top: 4rem;

        img {
            max-width: 500px;
            width: 100%;
            height: auto;
        }
    }

    @media (max-width: 1200px) {
        &__content {
            flex-direction: column;
            align-items: center;
        }

        &__list-section {
            flex: 1;
            width: 100%;
            max-width: 600px;
        }

        &__illustration {
            padding-top: 2rem;

            img {
                max-width: 400px;
            }
        }
    }

    @media (max-width: 768px) {
        padding: 2rem 1rem;

        &__controls {
            flex-direction: column;
        }

        &__control-btn {
            width: 100%;
            justify-content: center;
        }

        &__title {
            font-size: $text-2xl;
        }

        &__illustration {
            img {
                max-width: 300px;
            }
        }
    }
}

@keyframes spin {
    to {
        transform: rotate(360deg);
    }
}
</style>
