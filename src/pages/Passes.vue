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
        await qrStore.createGuestQr(bookingId.value, {
          recipient_email: email.value.trim(),
        });
        successMessage.value = 'Гостевой пропуск отправлен на ' + email.value.trim();
      } else {
        await qrStore.issueQr(bookingId.value, {
          recipient_email: email.value.trim(),
        });
        successMessage.value = 'Пропуск для сотрудника отправлен на ' + email.value.trim();
      }
      email.value = '';
    } catch (error) {
      apiError.value = error.message || 'Не удалось выдать пропуск. Попробуйте позже.';
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
                class="passes__input"
                :class="{ 'passes__input--error': emailError }"
                placeholder="Введите электронную почту"
              />
              <p v-if="emailError" class="passes__error">{{ emailError }}</p>
            </div>

            <button
              type="submit"
              class="passes__submit-btn"
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
      gap: 2rem;
      margin-bottom: 2rem;
    }

    &__tab {
      padding: 0.75rem 2.5rem;
      border-radius: $radius-sm;
      border: 1px solid $color-border;
      background: $color-input-bg;
      font-size: $text-base;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.2s;

      &:hover {
        background: $color-input-bg-dark;
      }

      &--active {
        background: $color-header-bg;
        font-weight: 600;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.15);
      }
    }

    &__title {
      font-family: $font-title;
      font-size: $text-2xl;
      font-weight: 500;
      margin-bottom: 2rem;
    }

    &__content {
      display: flex;
      gap: 3rem;
      align-items: center;
      width: 100%;
      max-width: 800px;
      background: $color-footer-bg;
      border-radius: $radius-sm;
      border: 1px solid $color-text;
      padding: 3rem;
    }

    &__image-col {
      flex-shrink: 0;
    }

    &__image {
      width: 250px;
      height: auto;
      object-fit: contain;
    }

    &__form-col {
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 1.5rem;
    }

    &__hint {
      font-size: $text-sm;
      color: $color-text;
      line-height: 1.4;
      font-weight: 500;
    }

    &__form {
      display: flex;
      flex-direction: column;
      gap: 1.5rem;
    }

    &__field {
      display: flex;
      flex-direction: column;
      gap: 0.25rem;
    }

    &__label {
      font-size: $text-sm;
      font-weight: 500;
      color: $color-text;
    }

    &__input {
      padding: 0.875rem 1.25rem;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      background: $color-input-bg;
      font-size: $text-base;
      outline: none;
      transition: 0.2s;

      &:focus {
        background: $color-input-bg-dark;
      }

      &--error {
        border-color: #c0392b;
      }
    }

    &__error {
      font-size: $text-sm;
      color: #c0392b;
    }

    &__submit-btn {
      align-self: flex-end;
      padding: 0.5rem 2rem;
      border-radius: $radius-sm;
      border: 1px solid $color-border;
      background: $color-input-bg;
      font-size: $text-base;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.2s;

      &:hover {
        background: $color-input-bg-dark;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
      }

      &:disabled {
        opacity: 0.6;
        cursor: not-allowed;
      }
    }

    &__success {
      font-size: $text-base;
      color: #166534;
      text-align: center;
    }

    &__api-error {
      font-size: $text-base;
      color: #c0392b;
      text-align: center;
    }

    @media (max-width: 768px) {
      &__content {
        flex-direction: column;
      }

      &__image {
        width: 180px;
      }

      &__tabs {
        flex-direction: column;
        gap: 0.5rem;
      }
    }
  }
</style>
