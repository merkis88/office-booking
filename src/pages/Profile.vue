<script setup>
  import { ref, onMounted } from 'vue';
  import { useAuthStore } from '@/store/auth';
  import { storeToRefs } from 'pinia';
  import { useRouter } from 'vue-router';

  const authStore = useAuthStore();
  const router = useRouter();
  const { user } = storeToRefs(authStore);

  const isLoading = ref(false);

  onMounted(async () => {
    if (!authStore.isAuthenticated) {
      await router.push('/authorization');
      return;
    }

    if (!user.value) {
      isLoading.value = true;
      try {
        await authStore.fetchCurrentUser();
      } catch (error) {
        console.error('Ошибка загрузки профиля:', error);
        await router.push('/authorization');
      } finally {
        isLoading.value = false;
      }
    }
  });
</script>

<template>
  <div class="profile">
    <div v-if="user" class="profile__container">
      <div class="profile__photo-section">
        <div class="profile__photo-wrapper">
          <img src="/avatar.png" alt="Фото профиля" class="profile__photo" />
        </div>
      </div>

      <div class="profile__info-section">
        <h2 class="profile__section-title">Контактные данные</h2>

        <div class="profile__form">
          <div class="profile__contact">
            <div class="profile__row">
              <div class="profile__field">
                <div class="profile__display">
                  <span class="profile__value">{{ user.last_name }}</span>
                </div>
              </div>

              <div class="profile__field">
                <div class="profile__display">
                  <span class="profile__value">{{ user.first_name }}</span>
                </div>
              </div>

              <div class="profile__field">
                <div class="profile__display">
                  <span v-if="user.patronymic" class="profile__value">{{ user.patronymic }}</span>
                  <span v-else class="profile__value">Отчество</span>
                </div>
              </div>
            </div>

            <div class="profile__row">
              <div class="profile__field">
                <div class="profile__display">
                  <span class="profile__value">{{ user.email }}</span>
                </div>
              </div>

              <div class="profile__field">
                <div class="profile__display">
                  <span v-if="user.post" class="profile__value">{{ user.post }}</span>
                  <span v-else class="profile__value">Должность</span>
                </div>
              </div>

              <div class="profile__field">
                <div class="profile__display">
                  <span v-if="user.company" class="profile__value">{{ user.company }}</span>
                  <span v-else class="profile__value">Компания</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="profile__pass-section">
          <h2 class="profile__section-title">Пропуск</h2>

          <div class="profile__pass-wrapper">
            <div class="profile__pass-card">
              <div class="profile__qr">
                <img src="/qr.png" alt="QR код" class="profile__qr-image" />
              </div>

              <div class="profile__pass-info">
                <h3 class="profile__pass-title">Пропуск для сотрудника</h3>
                <p class="profile__pass-detail">Парковочное место №18</p>
                <p class="profile__pass-detail profile__pass-detail--expiry">
                  Ваш qr-код действует до 27.02.2026
                </p>
              </div>
            </div>

            <div class="profile__pass-actions">
              <button class="profile__btn profile__btn--action">Добавить парковку</button>
              <router-link to="/update-password" class="profile__btn profile__btn--action">Сменить пароль</router-link>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;
  @use '@/assets/styles/mixins' as *;

  .profile {
    min-height: 100vh;
    padding: 4rem 2rem;

    &__container {
      @include container;
      display: flex;
      gap: 3rem;
      align-items: flex-start;
    }

    &__photo-section {
      flex-shrink: 0;
    }

    &__photo-wrapper {
      position: relative;
      width: 15rem;
      height: 22rem;
      border-radius: $radius-lg;
      overflow: hidden;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    }

    &__photo {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    &__info-section {
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 2rem;
    }

    &__section-title {
      font-family: $font-title;
      font-size: $text-xl;
      font-weight: 500;
      margin-bottom: 1rem;
      color: $color-text;
    }

    &__form {
      display: flex;
      flex-direction: column;
      gap: 1.5rem;
      align-items: center;
    }

    &__display {
      padding: 0.875rem 1.25rem;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      background: $color-input-bg;
      font-size: $text-base;
      color: $color-text;
      min-height: 3.5rem;
      width: 15rem;
      display: flex;
      align-items: center;
    }

    &__value {
      font-size: $text-base;
      color: $color-text;
      font-weight: 400;
    }

    &__contact {
      background: $color-footer-bg;
      display: flex;
      flex-direction: column;
      gap: 1.5rem;
      align-items: center;
      padding: 2rem 3rem;
      border-radius: $radius-sm;
      border: 1px solid $color-text;
    }

    &__row {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 1rem;
    }

    &__field {
      display: flex;
      flex-direction: column;
    }

    &__btn {
      padding: 0.5rem 4rem;
      border-radius: $radius-sm;
      font-size: $text-base;
      font-weight: 500;
      transition: all 0.3s ease;
      border: 1px solid $color-border;
      background: $color-input-bg;
      color: $color-text;
      cursor: pointer;

      &:hover {
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        transform: translateY(-2px);
      }

      &:active {
        transform: translateY(0);
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.15);
      }

      &--action {
        padding: 0.75rem 0.5rem;
        text-align: center;
        width: 70%;
      }
    }

    &__pass-section {
      margin-top: 2rem;
    }

    &__pass-wrapper {
      display: flex;
      gap: 2rem;
      align-items: center;
    }

    &__pass-card {
      flex: 1;
      display: flex;
      align-items: center;
      gap: 2rem;
      padding: 2rem;
      background: $color-card-bg;
      border: 1px solid $color-border;
      border-radius: $radius-lg;
    }

    &__qr {
      flex-shrink: 0;
      width: 8rem;
      height: 8rem;
      background: white;
      border: 2px solid $color-border;
      border-radius: $radius-sm;
      padding: 0.5rem;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    &__qr-image {
      width: 100%;
      height: 100%;
      object-fit: contain;
    }

    &__pass-info {
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
    }

    &__pass-title {
      font-size: $text-lg;
      font-weight: 600;
      color: $color-text;
      margin-bottom: 0.25rem;
    }

    &__pass-detail {
      font-size: $text-base;
      color: $color-text;
      line-height: 1.5;

      &--expiry {
        font-size: $text-sm;
        opacity: 0.8;
      }
    }

    &__pass-actions {
      display: flex;
      flex-direction: column;
      gap: 1rem;
      min-width: 20rem;
    }

    @media (max-width: 1024px) {
      &__container {
        flex-direction: column;
        align-items: center;
      }

      &__photo-section {
        width: 100%;
        display: flex;
        justify-content: center;
      }

      &__info-section {
        width: 100%;
      }

      &__pass-wrapper {
        flex-direction: column;
      }

      &__pass-actions {
        min-width: 100%;
      }
    }

    @media (max-width: 768px) {
      padding: 2rem 1rem;

      &__row {
        grid-template-columns: 1fr;
      }

      &__btn {
        &--action {
          width: 100%;
        }
      }

      &__pass-card {
        flex-direction: column;
        text-align: center;
      }

      &__pass-wrapper {
        flex-direction: column;
      }

      &__pass-actions {
        width: 100%;
      }
    }
  }
</style>
