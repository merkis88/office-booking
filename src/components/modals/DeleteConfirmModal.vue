<script setup>
import { ref, watch } from 'vue';

const props = defineProps({
    modelValue: {
        type: Boolean,
        default: false,
    },
    title: {
        type: String,
        default: 'Удаление',
    },
    message: {
        type: String,
        default: 'Вы действительно хотите удалить этот элемент?',
    },
    itemName: {
        type: String,
        default: '',
    },
    confirmText: {
        type: String,
        default: 'Подтвердить',
    },
    cancelText: {
        type: String,
        default: 'Отмена',
    },
});

const emit = defineEmits(['update:modelValue', 'confirm', 'cancel']);

const isVisible = ref(props.modelValue);

watch(
    () => props.modelValue,
    (newValue) => {
        isVisible.value = newValue;
    }
);

function closeModal() {
    isVisible.value = false;
    emit('update:modelValue', false);
    emit('cancel');
}

function confirmDelete() {
    emit('confirm');
    closeModal();
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
                <h2 class="modal-title">{{ title }}</h2>

                <p class="modal-message">{{ message }}</p>

                <p v-if="itemName" class="modal-item-name">{{ itemName }}</p>

                <div class="modal-actions">
                    <button class="modal-btn modal-btn--confirm" @click="confirmDelete">
                        {{ confirmText }}
                    </button>
                    <button class="modal-btn modal-btn--cancel" @click="closeModal">
                        {{ cancelText }}
                    </button>
                </div>
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
    background: white;
    border-radius: $radius-lg;
    padding: 2rem;
    max-width: 400px;
    width: 100%;
    border: solid 1px $color-border;
}

.modal-title {
    font-size: $text-xl;
    font-weight: 600;
    color: $color-text;
    margin: 0 0 1.5rem;
    text-align: center;
}

.modal-message {
    font-size: $text-base;
    color: $color-text;
    margin: 0 0 1rem;
    text-align: center;
    line-height: 1.5;
}

.modal-item-name {
    font-size: $text-base;
    font-weight: 600;
    color: $color-text;
    margin: 0 0 1.5rem;
    text-align: center;
    padding: 0.75rem;
    background: rgba($color-text, 0.05);
    border-radius: $radius-sm;
}

.modal-actions {
    display: flex;
    gap: 0.75rem;
    margin-top: 1.5rem;
}

.modal-btn {
    flex: 1;
    padding: 0.875rem 1.5rem;
    border: none;
    border-radius: $radius-sm;
    font-size: $text-base;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
    font-family: $font-base;

    &--confirm {
        background: #dc3545;
        color: white;

        &:hover {
            background: #c82333;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(220, 53, 69, 0.3);
        }

        &:active {
            transform: translateY(0);
        }
    }

    &--cancel {
        background: $color-input-bg;
        color: $color-text;
        border: 1px solid $color-border;

        &:hover {
            background: $color-input-bg-dark;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }

        &:active {
            transform: translateY(0);
        }
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
        padding: 1.5rem;
    }

    .modal-actions {
        flex-direction: column;
    }

    .modal-btn {
        width: 100%;
    }
}
</style>
