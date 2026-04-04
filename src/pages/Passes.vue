<script setup>
  import { ref, onMounted } from 'vue';
  import { useRoute, useRouter } from 'vue-router';
  import { useQrStore } from '@/store/qr';
  import PassConfirmModal from '@/components/modals/PassConfirmModal.vue';

  const route = useRoute();
  const router = useRouter();
  const qrStore = useQrStore();

  const activeTab = ref('employee');
  const email = ref('');
  const emailError = ref('');
  const apiError = ref('');
  const successMessage = ref('');
  const isSubmitting = ref(false);
  const showConfirmModal = ref(false);
  const modalError = ref('');

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

    modalError.value = '';
    showConfirmModal.value = true;
  }

  async function handleConfirm() {
    isSubmitting.value = true;
    modalError.value = '';

    try {
      if (activeTab.value === 'guest') {
        await qrStore.sendGuestQr(bookingId.value, { email: email.value.trim() });
        successMessage.value = 'Гостевой пропуск отправлен на ' + email.value.trim();
      } else {
        await qrStore.sendUserQr(bookingId.value, { email: email.value.trim() });
        successMessage.value = 'Пропуск для сотрудника отправлен на ' + email.value.trim();
      }
      email.value = '';
      showConfirmModal.value = false;

      setTimeout(() => (successMessage.value = ''), 5000);
    } catch (error) {
      modalError.value =
        error.response?.data?.message || 'Не удалось выдать пропуск. Попробуйте позже.';
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
            Пропуск для гостя является одноразовым и
            <br />
            действует всего 2 часа
          </p>

          <div class="passes__form-wrapper">
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

              <!-- Успех -->
              <p v-if="successMessage" class="passes__success">{{ successMessage }}</p>

              <!-- Общая ошибка API -->
              <p v-if="apiError" class="passes__api-error">{{ apiError }}</p>
            </form>

            <!-- Кнопка вне фонового блока формы -->
            <button type="submit" class="btn" :disabled="isSubmitting" @click="handleSubmit">
              {{ isSubmitting ? 'Отправка...' : 'Выдать пропуск' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>

  <PassConfirmModal
    :model-value="showConfirmModal"
    :email="email"
    :error="modalError"
    @update:model-value="showConfirmModal = $event"
    @confirm="handleConfirm"
  />
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

    // --- ТАБЫ ---
    &__tabs {
      display: flex;
      gap: 2rem;
      margin-bottom: 3rem;
    }

    &__tab {
      padding: 2rem 3rem;
      border-radius: $radius-md;
      border: 1px solid $color-border;
      background: $color-header-bg;
      font-size: $text-lg;
      transition: $transition-fast;
      box-shadow: none;

      &:hover {
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
      }

      &--active {
        background: #e5c39c;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
      }
    }

    &__title {
      display: none; // в макете его нет
    }

    // --- ОСНОВНАЯ КАРТОЧКА ---
    &__content {
      position: relative;
      display: flex;
      width: 100%;
      max-width: 1000px;
      height: 100%;
      max-height: 410px;
      border-radius: $radius-lg;
      overflow: hidden;
      background: $color-footer-bg;
    }

    // диагональный фон
    &__content::before {
      content: '';
      position: absolute;
      inset: 0;
      z-index: 1;

      background: linear-gradient(to top, #ff8b95 0%, #e5c39c 100%);

      clip-path: polygon(60% 0, 100% 0, 100% 100%);
    }

    // --- КАРТИНКА ---
    &__image-col {
      flex: 1;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 2rem;
      z-index: 2;
    }

    &__image {
      max-height: 340px;
    }

    // --- ФОРМА ---
    &__form-col {
      flex: 1;
      display: flex;
      flex-direction: column;
      align-items: end;
      justify-content: center;
      z-index: 2;
    }

    // плашка формы (ВАЖНО)

    &__form-wrapper {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 1rem; /* расстояние между формой и кнопкой */
      width: 100%;
    }

    &__form {
      background: #aeb8c2;
      padding: 2rem;
      border-radius: $radius-md 0 0 $radius-md;
      width: 100%;
    }

    .btn {
      z-index: 2;
    }

    &__hint {
      padding: 0 1rem;
      margin: -2rem 0 2rem;
      text-align: center;
      font-size: $text-sm;
    }

    &__field {
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
    }

    &__label {
      font-size: $text-sm;
    }

    // инпут как в макете
    .input {
      background: #cbd5df;
    }

    &__error {
      font-size: $text-sm;
      color: $color-danger;
    }

    // кнопка по центру
    .btn {
      align-self: center;
      padding: 0.6rem 2rem;
    }

    &__success,
    &__api-error {
      text-align: center;
      margin-top: 1rem;
      margin-right: 1rem;
    }

    &__success {
      color: $color-success;
    }

    // --- МОБИЛКА ---
    @media (max-width: 768px) {
      &__content {
        flex-direction: column;
      }

      &__content::before {
        display: none;
      }

      &__image {
        max-height: 200px;
      }

      &__form {
        max-width: 100%;
      }
    }
  }
</style>
