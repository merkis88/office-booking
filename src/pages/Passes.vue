<script setup>
  import { ref, onMounted } from 'vue';
  import { useRoute, useRouter } from 'vue-router';
  import { useQrStore } from '@/store/qr';

  const route = useRoute();
  const router = useRouter();
  const qrStore = useQrStore();

  const activeTab = ref('employee');
  const email = ref('');
  const emailError = ref('');
  const apiError = ref('');
  const successMessage = ref('');
  const isSubmitting = ref(false);

  const bookingId = ref(null);

  onMounted(async () => {
    bookingId.value = Number(route.query.booking);
    if (!bookingId.value) {
      await router.push('/profile');
    }
  });

  function validateEmail() {
    emailError.value = '';
    if (!email.value.trim()) {
      emailError.value = 'Введите электронную почту';
      return false;
    }
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email.value)) {
      emailError.value = 'Неверно введена электронная почта';
      return false;
    }
    return true;
  }

  async function handleSubmit() {
    if (!validateEmail()) return;

    isSubmitting.value = true;
    apiError.value = '';
    successMessage.value = '';

    try {
      if (activeTab.value === 'guest') {
        await qrStore.sendGuestQr(bookingId.value, {
          email: email.value.trim(),
        });
        successMessage.value = 'Гостевой пропуск отправлен на ' + email.value.trim();
      } else {
        await qrStore.sendUserQr(bookingId.value, {
          email: email.value.trim(),
        });
        successMessage.value = 'Пропуск для сотрудника отправлен на ' + email.value.trim();
      }
      email.value = '';
    } catch (error) {
      apiError.value = error.response?.data?.message || 'Не удалось выдать пропуск. Попробуйте позже.';
    } finally {
      isSubmitting.value = false;
    }
  }
</script>

<template>
  <div class="passes">
    <div class="passes__container">
      <!-- Табы -->
      <div class="passes__tabs">
        <button
          class="passes__tab"
          :class="{ 'passes__tab--active': activeTab === 'employee' }"
          @click="activeTab = 'employee'"
        >
          Пропуск для сотрудника
        </button>
        <button
          class="passes__tab"
          :class="{ 'passes__tab--active': activeTab === 'guest' }"
          @click="activeTab = 'guest'"
        >
          Пропуск для гостя
        </button>
      </div>

      <!-- Заголовок -->
      <h1 class="passes__title">Пропуск</h1>

      <!-- Контент -->
      <div class="passes__content">
        <!-- Картинка -->
        <div class="passes__image-col">
          <img
            v-if="activeTab === 'employee'"
            src="@/assets/images/photos/man_on_chair_laptop.png"
            alt="Сотрудник"
            class="passes__image"
          />
          <img
            v-else
            src="@/assets/images/photos/man_standing.png"
            alt="Гость"
            class="passes__image"
          />
        </div>

        <!-- Форма -->
        <div class="passes__form-col">
          <!-- Подсказка для гостя -->
          <p v-if="activeTab === 'guest'" class="passes__hint">
            Пропуск для гостя является одноразовым и действует всего 2 часа
          </p>

          <form @submit.prevent="handleSubmit" class="passes__form">
            <div class="passes__field">
              <label class="passes__label">Эл.почта*</label>
              <input
                v-model="email"
                type="email"
                class="input"
                :class="{ 'input--error': emailError }"
                placeholder="Введите электронную почту"
              />
              <p v-if="emailError" class="passes__error">{{ emailError }}</p>
            </div>

            <button
              type="submit"
              class="btn"
              :disabled="isSubmitting"
            >
              {{ isSubmitting ? 'Отправка...' : 'Выдать пропуск' }}
            </button>
          </form>

          <!-- Успех -->
          <p v-if="successMessage" class="passes__success">{{ successMessage }}</p>

          <!-- Общая ошибка API -->
          <p v-if="apiError" class="passes__api-error">{{ apiError }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;
  @use '@/assets/styles/mixins' as *;

  .passes {
    min-height: 100vh;
    padding: 4rem 2rem;

    &__container {
      @include container;
      display: flex;
      flex-direction: column;
      align-items: center;
    }

    &__tabs {
      display: flex;
      gap: 1.5rem;
      margin-bottom: 2rem;
      justify-content: center;
    }

    &__tab {
      padding: 1rem 3rem;
      border-radius: $radius-md;
      border: 1px solid $color-border;
      background: $color-input-bg;
      font-size: $text-lg;
      font-weight: 500;
      cursor: pointer;
      transition: $transition-fast;

      &:hover {
        background: $color-input-bg-dark;
      }

      &--active {
        background: #EBCAA3;
        font-weight: 600;
        border-color: $color-border;
      }
    }

    &__title {
      font-family: $font-title;
      font-size: $text-2xl;
      font-weight: 500;
      font-style: italic;
      margin-bottom: 2rem;
      text-align: center;
    }

    &__content {
      display: flex;
      gap: 0;
      align-items: stretch;
      width: 100%;
      max-width: 900px;
      border-radius: $radius-lg;
      overflow: hidden;
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
    }

    &__image-col {
      flex: 1;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 3rem;
      background: $color-footer-bg;
    }

    &__image {
      max-width: 100%;
      max-height: 400px;
      object-fit: contain;
      z-index: 2;
    }

    &__form-col {
      flex: 1;
      padding: 3rem;
      display: flex;
      flex-direction: column;
      justify-content: center;
      gap: 1.5rem;
      position: relative;
      background:
        linear-gradient(
          to bottom left,
          #EBCAA3 0%,
          #FF8B95 49.9%,
          $color-footer-bg 50%,
          $color-footer-bg 100%
        );
    }

    &__hint {
      font-size: $text-base;
      color: $color-text;
      line-height: 1.4;
      font-weight: 600;
    }

    &__form {
      display: flex;
      flex-direction: column;
      gap: 1.5rem;
      align-items: flex-end;
    }

    &__field {
      width: 100%;
      display: flex;
      flex-direction: column;
      gap: 0.25rem;
    }

    &__label {
      font-size: $text-sm;
      font-weight: 500;
      color: $color-text;
    }

    &__error {
      font-size: $text-sm;
      color: $color-danger;
    }

    &__success {
      font-size: $text-base;
      color: $color-success;
      text-align: center;
    }

    &__api-error {
      font-size: $text-base;
      color: $color-danger;
      text-align: center;
    }

    @media (max-width: 768px) {
      &__content {
        flex-direction: column;
      }

      &__image-col {
        padding: 2rem;
      }

      &__image {
        max-height: 250px;
      }

      &__form-col {
        padding: 2rem;
      }

      &__tabs {
        flex-direction: column;
        gap: 0.5rem;
      }
    }
  }
</style>
