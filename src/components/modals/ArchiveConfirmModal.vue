<script setup>
import BaseModal from './BaseModal.vue';

const props = defineProps({
    modelValue: {
        type: Boolean,
        default: false,
    },
    placeName: {
        type: String,
        default: '',
    },
});

const emit = defineEmits(['update:modelValue', 'confirm', 'cancel']);

function handleConfirm() {
    emit('confirm');
    emit('update:modelValue', false);
}

function handleCancel() {
    emit('cancel');
    emit('update:modelValue', false);
}
</script>

<template>
    <BaseModal
        :model-value="modelValue"
        title="Архивация помещения"
        :close-on-backdrop="false"
        :show-close-button="false"
        max-width="600px"
        @update:model-value="$emit('update:modelValue', $event)"
    >
        <div class="archive-confirm">
            <p class="archive-confirm__text">
                У этого помещения есть активные аренды. Для архивации помещения, необходимо подтвердить
                действие. Все бронирования этого помещения будут отменены
            </p>

            <div class="archive-confirm__actions">
                <button class="archive-confirm__btn archive-confirm__btn--confirm" @click="handleConfirm">
                    Подтвердить
                </button>
                <button class="archive-confirm__btn archive-confirm__btn--cancel" @click="handleCancel">
                    Отмена
                </button>
            </div>
        </div>
    </BaseModal>
</template>

<style lang="scss" scoped>
@use '@/assets/styles/variables' as *;

.archive-confirm {
    display: flex;
    flex-direction: column;
    gap: 2rem;
    padding: 1rem 0;

    &__text {
        font-size: $text-base;
        line-height: 1.6;
        color: $color-text;
        text-align: center;
        margin: 0;
    }

    &__actions {
        display: flex;
        gap: 1rem;
        justify-content: center;
    }

    &__btn {
        padding: 0.75rem 2rem;
        border-radius: $radius-sm;
        font-size: $text-base;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s;
        border: 1px solid $color-border;
        min-width: 150px;

        &--confirm {
            background: $color-btn-profile;
            color: $color-text;

            &:hover {
                background: $color-input-bg-dark;
                transform: translateY(-2px);
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            }
        }

        &--cancel {
            background: transparent;
            color: $color-text;

            &:hover {
                background: rgba($color-text, 0.05);
            }
        }

        &:active {
            transform: translateY(0);
        }
    }

    @media (max-width: 768px) {
        &__actions {
            flex-direction: column;
        }

        &__btn {
            width: 100%;
        }
    }
}
</style>
