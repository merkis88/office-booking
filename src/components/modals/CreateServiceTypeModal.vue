<script setup>
import { ref, watch } from 'vue';

const props = defineProps({
    modelValue: {
        type: Boolean,
        default: false,
    },
});

const emit = defineEmits(['update:modelValue', 'create', 'cancel']);

const isVisible = ref(props.modelValue);
const typeName = ref('');
const isSubmitting = ref(false);
const error = ref('');

watch(
    () => props.modelValue,
    (newValue) => {
        isVisible.value = newValue;
        if (newValue) {
            // Сбросить форму при открытии
            typeName.value = '';
            error.value = '';
        }
    }
);

function closeModal() {
    isVisible.value = false;
    emit('update:modelValue', false);
    emit('cancel');
}

async function handleCreate() {
    error.value = '';

    // Валидация
    if (!typeName.value.trim()) {
        error.value = 'Введите название типа заявки';
        return;
    }

    isSubmitting.value = true;

    try {
        await emit('create', { name: typeName.value.trim() });
        closeModal();
    } catch (err) {
        error.value = err.message || 'Ошибка создания';
    } finally {
        isSubmitting.value = false;
    }
}

function handleBackdropClick(event) {
    if (event.target === event.currentTarget) {
        closeModal();
    }
}
</script>

<template>
    <Transition name="modal">
        <div v-if="isVisible" class="modal-overlay" @click="handleBackdropClick">
            <div class="modal-content" @click.stop>

                <h2 class="modal-title">Создание вида заявки</h2>

                <form @submit.prevent="handleCreate">
                    <div class="modal-field">
                        <label class="modal-label">
                            Тип заявки<span class="modal-required">*</span>
                        </label>
                        <input
                            v-model="typeName"
                            type="text"
                            class="modal-input"
                            placeholder="Введите тип заявки"
                            :disabled="isSubmitting"
                            maxlength="255"
                        />
                        <p v-if="error" class="modal-error">{{ error }}</p>
                    </div>

                    <div class="modal-actions">
                        <button
                            type="submit"
                            class="modal-btn modal-btn--create"
                            :disabled="isSubmitting"
                        >
                            {{ isSubmitting ? 'Создание...' : 'Создать' }}
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
    max-width: 420px;
    width: 30rem;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
}

.modal-subtitle {
    font-size: $text-sm;
    color: rgba($color-text, 0.7);
    margin: 0 0 0.5rem;
    text-align: center;
}

.modal-title {
    font-family:$font-title;
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
    margin-bottom: 0.5rem;
}

.modal-required {
    color: #dc3545;
    margin-left: 2px;
}

.modal-input {
    width: 100%;
    padding: 0.875rem 1rem;
    border-radius: $radius-sm;
    background: white;
    font-size: $text-base;
    color: $color-text;
    font-family: $font-base;
    transition: all 0.2s;
    background: $color-btn-profile;
    border: solid 1px $color-text;

    &:focus {
        outline: none;
        border-color: $color-text;
        box-shadow: 0 0 0 3px rgba($color-text, 0.1);
    }

    &::placeholder {
        color: rgba($color-text, 0.5);
    }

    &:disabled {
        background: rgba(255, 255, 255, 0.6);
        cursor: not-allowed;
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

.modal-enter-active,
.modal-leave-active {
    transition: opacity 0.3s ease;

    .modal-content {
        transition: transform 0.3s ease;
    }
}

.modal-enter-from,
.modal-leave-to {
    opacity: 0;

    .modal-content {
        transform: scale(0.9) translateY(-20px);
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
