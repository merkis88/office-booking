<script setup>
  import { ref } from 'vue';
  import { useNotificationsStore } from '@/store/notifications';
  import { storeToRefs } from 'pinia';

  const notificationsStore = useNotificationsStore();
  const { isLoading, error, successMessage } = storeToRefs(notificationsStore);

  const form = ref({
    title: '',
    message: '',
    sendToEmployee: false,
    email: '',
  });

  async function handleSubmit() {
    notificationsStore.clearMessages();

    if (!form.value.title.trim()) {
      notificationsStore.error = 'Введите тему уведомления';
      return;
    }

    if (!form.value.message.trim()) {
      notificationsStore.error = 'Введите текст уведомления';
      return;
    }

    if (form.value.sendToEmployee && !form.value.email.trim()) {
      notificationsStore.error = 'Введите электронную почту получателя';
      return;
    }

    if (form.value.sendToEmployee && !validateEmail(form.value.email)) {
      notificationsStore.error = 'Введите корректный email адрес';
      return;
    }

    const result = await notificationsStore.sendNotification({
      title: form.value.title,
      message: form.value.message,
      sendToEmployee: form.value.sendToEmployee,
      email: form.value.email,
    });

    if (result.success) {
      form.value.title = '';
      form.value.message = '';
      form.value.sendToEmployee = false;
      form.value.email = '';
    }
  }

  function validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
  }
</script>

<template>
  <div class="notification-send">
    <div class="notification-send__container">
      <div class="notification-send__content">
        <div class="notification-send__form-wrapper">
          <h1 class="notification-send__title">Отправка уведомлений</h1>

          <form @submit.prevent="handleSubmit" class="notification-send__form">
            <div class="notification-send__field">
              <label class="notification-send__label">
                Тема
                <span class="notification-send__required">*</span>
              </label>
              <input
                v-model="form.title"
                type="text"
                class="notification-send__input"
                placeholder="Введите тему уведомления"
                :disabled="isLoading"
              />
            </div>

            <div class="notification-send__field">
              <label class="notification-send__label">
                Текст уведомления
                <span class="notification-send__required">*</span>
              </label>
              <textarea
                v-model="form.message"
                class="notification-send__textarea"
                placeholder="Введите текст уведомления"
                rows="6"
                :disabled="isLoading"
              ></textarea>
            </div>

            <div class="notification-send__checkbox-wrapper">
              <label class="notification-send__checkbox-label">
                <input
                  v-model="form.sendToEmployee"
                  type="checkbox"
                  class="notification-send__checkbox"
                  :disabled="isLoading"
                />
                <span class="notification-send__checkbox-text">
                  Отправить уведомление лично сотруднику
                </span>
              </label>
            </div>

            <div v-if="form.sendToEmployee" class="notification-send__field">
              <label class="notification-send__label">
                Электронная почта пользователя
                <span class="notification-send__required">*</span>
              </label>
              <input
                v-model="form.email"
                type="email"
                class="notification-send__input"
                placeholder="Введите электронную почту"
                :disabled="isLoading"
              />
            </div>

            <div v-if="successMessage" class="notification-send__success">
              {{ successMessage }}
            </div>

            <div v-if="error" class="notification-send__error">
              {{ error }}
            </div>

            <button type="submit" class="notification-send__submit" :disabled="isLoading">
              {{ isLoading ? 'Отправка...' : 'Отправить' }}
            </button>
          </form>
        </div>

        <div class="notification-send__illustration">
          <img src="/men-notification.png" alt="Уведомления" />
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;
  @use '@/assets/styles/mixins' as *;

  .notification-send {
    min-height: 100vh;
    padding: 4rem 2rem;

    &__container {
      @include container;
    }

    &__content {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 4rem;
      align-items: center;
    }

    &__form-wrapper {
      padding: 2rem 5rem;
      display: flex;
      flex-direction: column;
      gap: 2rem;
      background-color: $color-footer-bg;
      border-radius: $radius-md;
    }

    &__title {
      font-family: $font-title;
      font-size: $text-2xl;
      margin: 0;
      text-align: center;
      font-weight: normal;
    }

    &__form {
      display: flex;
      flex-direction: column;
      gap: 1.5rem;
    }

    &__field {
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
    }

    &__label {
      font-size: $text-base;
      font-weight: 500;
      color: $color-text;
    }

    &__required {
      margin-left: 0.25rem;
    }

    &__input {
      padding: 0.875rem 1.25rem;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      background: $color-input-bg;
      font-size: $text-base;
      color: $color-text;
      transition: all 0.2s;

      &:focus {
        outline: none;
        border-color: $color-footer-text;
      }

      &:disabled {
        opacity: 0.6;
        cursor: not-allowed;
      }

      &::placeholder {
        color: rgba($color-text, 0.5);
      }
    }

    &__textarea {
      padding: 0.875rem 1.25rem;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      background: $color-input-bg;
      font-size: $text-base;
      color: $color-text;
      font-family: inherit;
      resize: vertical;
      min-height: 120px;
      transition: all 0.2s;

      &:focus {
        outline: none;
        border-color: $color-footer-text;
        box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
      }

      &:disabled {
        opacity: 0.6;
        cursor: not-allowed;
      }

      &::placeholder {
        color: rgba($color-text, 0.5);
      }
    }

    &__checkbox-wrapper {
      display: flex;
      align-items: center;
    }

    &__checkbox-label {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      cursor: pointer;
      user-select: none;
    }

    &__checkbox {
      padding: 0.5rem;
      width: 1.25rem;
      height: 1.25rem;
      cursor: pointer;
      accent-color: $color-bg;
      border-radius: $radius-sm;

      &:disabled {
        cursor: not-allowed;
      }
    }

    &__checkbox-text {
      font-size: $text-base;
      color: $color-text;
    }

    &__submit {
      padding: 1rem 2rem;
      background: $color-input-bg;
      border: none;
      border-radius: $radius-sm;
      font-size: $text-base;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.3s;

      &:hover:not(:disabled) {
        transform: translateY(-2px);
      }

      &:active:not(:disabled) {
        transform: translateY(0);
      }

      &:disabled {
        opacity: 0.6;
        cursor: not-allowed;
      }
    }

    &__success {
      padding: 1rem;
      background: rgba(46, 204, 113, 0.1);
      border: 1px solid #2ecc71;
      border-radius: $radius-sm;
      color: #27ae60;
      text-align: center;
      font-weight: 500;
    }

    &__error {
      padding: 1rem;
      background: rgba(231, 76, 60, 0.1);
      border: 1px solid #e74c3c;
      border-radius: $radius-sm;
      color: #c0392b;
      text-align: center;
      font-weight: 500;
    }

    &__illustration {
      display: flex;
      align-items: center;
      justify-content: center;

      img {
        max-width: 100%;
        height: auto;
        filter: drop-shadow(0 8px 24px rgba(0, 0, 0, 0.1));
      }
    }

    @media (max-width: 1024px) {
      &__content {
        grid-template-columns: 1fr;
        gap: 2rem;
      }

      &__illustration {
        order: -1;

        img {
          max-width: 300px;
        }
      }
    }

    @media (max-width: 768px) {
      padding: 2rem 1rem;

      &__content {
        padding: 2rem 1.5rem;
      }

      &__title {
        font-size: $text-xl;
      }
    }
  }
</style>
