<script setup>
import { computed } from 'vue';
import { useAuthStore } from '@/store/auth';

const authStore = useAuthStore();

const props = defineProps({
    place: {
        type: Object,
        required: true,
    },
});

const emit = defineEmits(['delete-place', 'restore-place']);

function handleDelete() {
    if (confirm(`Вы уверены, что хотите удалить "${props.place.name}"?`)) {
        emit('delete-place', props.place.id);
    }
}

function handleRestore() {
    emit('restore-place', props.place.id);
}

const placeTypeLabel = computed(() => {
    const types = {
        office: 'Офис',
        coworking: 'Коворкинг',
        meeting: 'Переговорная',
    };
    return types[props.place.type] || props.place.type;
});
</script>

<template>
    <div class="archived-place-card">
        <div class="archived-place-card__main">
            <div class="archived-place-card__image-wrapper">
                <img
                    :src="place.photo_url"
                    :alt="place.name"
                    class="archived-place-card__image"
                    @error="$event.target.src = '@/assets/images/photo/placeholder.jpg'"
                />
            </div>

            <div class="archived-place-card__content">
                <h3 class="archived-place-card__title">{{ place.name }}</h3>
                <p class="archived-place-card__type">{{ placeTypeLabel }}</p>
                <p class="archived-place-card__number">Кабинет №{{ place.number_place }}</p>
                <p class="archived-place-card__price">Стоимость: {{ place.price }}₽</p>
                <p class="archived-place-card__capacity">Вместимость: {{ place.capacity }} человек</p>
            </div>

            <button
                v-if="authStore.isAdmin"
                class="archived-place-card__restore"
                @click="handleRestore"
                aria-label="Восстановить помещение"
            >
                <img src="@/assets/images/icons/restore.svg" alt="Восстановить" />
            </button>
        </div>
    </div>
</template>

<style lang="scss" scoped>
@use '@/assets/styles/variables' as *;

.archived-place-card {
    overflow: hidden;
    display: flex;
    flex-direction: column;
    font-family: $font-base;

    &__main {
        background: $color-btn-profile;
        border: 1px solid $color-border;
        border-radius: $radius-lg;
        display: flex;
        gap: 1rem;
        padding: 1.5rem;
        position: relative;
        transition: all 0.3s;
        opacity: 0.8;
    }

    &__image-wrapper {
        position: relative;
        width: 180px;
        height: 180px;
        flex-shrink: 0;
        overflow: hidden;
        border-radius: $radius-lg;
    }

    &__image {
        width: 100%;
        height: 100%;
        object-fit: cover;
        filter: grayscale(30%);
    }

    &__content {
        flex: 1;
        display: flex;
        flex-direction: column;
        gap: 0.75rem;
        justify-content: center;
    }

    &__title {
        font-size: $text-lg;
        font-weight: 600;
        color: $color-text;
        margin: 0;
    }

    &__type {
        font-size: $text-base;
        color: rgba($color-text, 0.7);
        margin: 0;
    }

    &__number {
        font-size: $text-base;
        color: $color-text;
        margin: 0;
    }

    &__price {
        font-size: $text-base;
        color: $color-text;
        margin: 0;
    }

    &__capacity {
        font-size: $text-base;
        color: $color-text;
        margin: 0;
    }



    &__restore {
        position: absolute;
        top: 9.8rem;
        right: 1.5rem;
        width: 2.5rem;
        height: 2.5rem;
        border: none;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        transition: all 0.2s;

        &:hover {
            transform: scale(1.1);
        }

        img {
            width: 1.5rem;
            height: 1.5rem;
        }
    }

    @media (max-width: 768px) {
        &__main {
            flex-direction: column;
            padding: 1rem;
        }

        &__image-wrapper {
            width: 100%;
            height: 200px;
        }

        &__delete {
            bottom: 0.5rem;
            right: 0.5rem;
            width: 2rem;
            height: 2rem;

            img {
                width: 1.25rem;
                height: 1.25rem;
            }
        }

        &__restore {
            top: 1rem;
            right: 1rem;
            width: 2rem;
            height: 2rem;

            img {
                width: 1.25rem;
                height: 1.25rem;
            }
        }
    }
}
</style>
