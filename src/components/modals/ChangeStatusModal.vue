<script setup>
import { ref, watch } from 'vue';

const props = defineProps({
    modelValue: {
        type: Boolean,
        default: false,
    },
    request: {
        type: Object,
        default: null,
    },
});

const emit = defineEmits(['update:modelValue', 'change-status', 'cancel']);

const isVisible = ref(props.modelValue);
const selectedStatus = ref('');
const isSubmitting = ref(false);
const error = ref('');

const statuses = [
    { value: 'pending', label: 'В ожидании', color: '#fff3cd' },
    { value: 'in_progress', label: 'В работе', color: '#d1ecf1' },
    { value: 'completed', label: 'Выполнено', color: '#d4edda' },
    { value: 'rejected', label: 'Отклонено', color: '#f8d7da' },
];

watch(
    () => props.modelValue,
    (newValue) => {
        isVisible.value = newValue;
        if (newValue && props.request) {
            selectedStatus.value = props.request.status || 'pending';
            error.value = '';
        }
    }
);

watch(
    () => props.request,
    (newRequest) => {
        if (newRequest) {
            selectedStatus.value = newRequest.status || 'pending';
        }
    },
    { immediate: true }
);

function closeModal() {
    isVisible.value = false;
    emit('update:modelValue', false);
    emit('cancel');
}

async function handleChangeStatus() {
    error.value = '';

    if (!selectedStatus.value) {
        error.value = 'Выберите статус';
        return;
    }

    isSubmitting.value = true;

    try {
        await emit('change-status', { status: selectedStatus.value });
        closeModal();
    } catch (err) {
        error.value = err.message || 'Ошибка изменения статуса';
    } finally {
        isSubmitting.value = false;
    }
}

function handleBackdropClick(event) {
    if (event.target === event.currentTarget) {
        closeModal();
    }
}

function getStatusColor(statusValue) {
    const status = statuses.find((s) => s.value === statusValue);
    return status ? status.color : '#fff';
}
</script>

<template>
    <Transition name="modal">
        <div v-if="isVisible" class="modal-overlay" @click="handleBackdropClick">
            <div class="modal-content" @click.stop>
                <h2 class="modal-title">Изменение статуса заявки</h2>

                <form @submit.prevent="handleChangeStatus">
                    <div class="modal-field">
                        <label class="modal-label">
                            Статус заявки<span class="modal-required">*</span>
                        </label>

                        <div class="modal-status-list">
                            <label
                                v-for="status in statuses"
                                :key="status.value"
                                class="modal-status-item"
                                :class="{ 'modal-status-item--selected': selectedStatus === status.value }"
                            >
                                <input
                                    v-model="selectedStatus"
                                    type="radio"
                                    :value="status.value"
                                    class="modal-status-radio"
                                    :disabled="isSubmitting"
                                />
                                <span class="modal-status-label" :style="{ backgroundColor: status.color }">
                  {{ status.label }}
                </span>
                            </label>
                        </div>

                        <p v-if="error" class="modal-error">{{ error }}</p>
                    </div>

                    <div class="modal-actions">
                        <button
                            type="submit"
                            class="modal-btn modal-btn--save"
                            :disabled="isSubmitting"
                        >
                            {{ isSubmitting ? 'Сохранение...' : 'Сохранить' }}
                        </button>
                        <button
                            type="button"
                            class="modal-btn modal-btn--cancel"
                            @click="closeModal"
                            :disabled="isSubmitting"
                        >
                            Отмена
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </Transition>
</template>

<style lang="scss" scoped>
@use '@/assets/styles/variables' as *;

.modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
    padding: 1rem;
}

.modal-content {
    background: $color-footer-bg;
    border-radius: $radius-sm;
    padding: 2.5rem 2rem;
    max-width: 450px;
    width: 100%;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
}

.modal-title {
    font-family: $font-title;
    font-size: $text-2xl;
    font-weight: 400;
    color: $color-text;
    margin: 0 0 2rem;
    text-align: center;
}

.modal-field {
    margin-bottom: 1.5rem;
}

.modal-label {
    display: block;
    font-size: $text-base;
    font-weight: 500;
    color: $color-text;
    margin-bottom: 1rem;
}

.modal-required {
    color: #dc3545;
    margin-left: 2px;
}

.modal-status-list {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
}

.modal-status-item {
    display: flex;
    align-items: center;
    cursor: pointer;
    transition: all 0.2s;

    &--selected {
        .modal-status-label {
            border-color: $color-text;
            box-shadow: 0 0 0 2px rgba($color-text, 0.2);
            font-weight: 600;
        }
    }
}

.modal-status-radio {
    display: none;
}

.modal-status-label {
    flex: 1;
    padding: 0.875rem 1.5rem;
    border: 2px solid transparent;
    border-radius: $radius-sm;
    font-size: $text-base;
    color: $color-text;
    transition: all 0.2s;
    text-align: center;

    &:hover {
        border-color: rgba($color-text, 0.3);
    }
}

.modal-error {
    font-size: $text-sm;
    color: #dc3545;
    margin: 0.5rem 0 0;
}

.modal-actions {
    display: flex;
    gap: 0.75rem;
    margin-top: 2rem;
}

.modal-btn {
    flex: 1;
    padding: 0.875rem 1.5rem;
    border-radius: $radius-sm;
    font-size: $text-base;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
    font-family: $font-base;
    background: $color-btn-profile;
    border: solid 1px $color-text;
    color: $color-text;

    &:disabled {
        opacity: 0.6;
        cursor: not-allowed;
    }

    &:hover:not(:disabled) {
        background: rgba(255, 255, 255, 0.8);
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    }

    &:active:not(:disabled) {
        transform: translateY(0);
    }
}

@media (max-width: 768px) {
    .modal-content {
        padding: 2rem 1.5rem;
    }

    .modal-actions {
        flex-direction: column;
    }

    .modal-btn {
        width: 100%;
    }
}
</style>
