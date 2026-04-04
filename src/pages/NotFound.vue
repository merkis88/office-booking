<script setup>
import { useRouter } from 'vue-router';

const router = useRouter();

function goHome() {
    router.push('/');
}
</script>

<template>
    <div class="not-found">
        <div class="not-found__container">
            <div class="not-found__content">
                <div class="not-found__image">
                    <img src="@/assets/images/photos/not-found.png" alt="404" />
                </div>

                <div class="not-found__text-content">
                    <h1 class="not-found__code">404</h1>
                    <p class="not-found__message">
                        Возможно вы ошиблись, такой<br />
                        страницы не существует
                    </p>
                    <button @click="goHome" class="not-found__btn">
                        <img src="@/assets/images/icons/send.svg" alt="" class="not-found__btn-icon" />
                        Назад на сайт
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
@use '@/assets/styles/variables' as *;
@use '@/assets/styles/mixins' as *;

.not-found {
    min-height: calc(100vh - 100px);
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 2rem;

    &__container {
        @include container;
        display: flex;
        justify-content: center;
        align-items: center;
    }

    &__content {
        display: flex;
        align-items: center;
        gap: 4rem;
        max-width: 900px;
    }

    &__image {
        flex-shrink: 0;
        width: 300px;
        display: flex;
        align-items: center;
        justify-content: center;

        img {
            width: 100%;
            height: auto;
            object-fit: contain;
        }
    }

    &__text-content {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 1.5rem;
    }

    &__code {
        font-family: $font-title;
        font-size: 10rem;
        font-weight: 200;
        color: $color-text;
        margin: 0;
        line-height: 1;
    }

    &__message {
        font-size: $text-lg;
        color: $color-text;
        text-align: center;
        margin: 0;
        line-height: 1.6;
    }

    &__btn {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        padding: 0.75rem 1.5rem;
        background: $color-btn-profile;
        border: 1px solid $color-border;
        border-radius: $radius-sm;
        font-size: $text-base;
        color: $color-text;
        cursor: pointer;
        transition: all 0.2s;
        margin-top: 1rem;

        &:hover {
            background: $color-input-bg-dark;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        &:active {
            transform: translateY(0);
        }
    }

    &__btn-icon {
        width: 1.25rem;
        height: 1.25rem;
    }

    @media (max-width: 768px) {
        min-height: calc(100vh - 80px);
        padding: 1rem;

        &__content {
            flex-direction: column;
            gap: 2rem;
        }

        &__image {
            width: 200px;
        }

        &__code {
            font-size: 6rem;
        }

        &__message {
            font-size: $text-base;
        }

        &__btn {
            width: 100%;
            justify-content: center;
        }
    }
}
</style>
