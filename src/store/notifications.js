import { defineStore } from 'pinia';
import axios from 'axios';

export const useNotificationsStore = defineStore('notifications', {
  state: () => ({
    isLoading: false,
    error: null,
    successMessage: null,
  }),

  actions: {
    async sendNotification(notificationData) {
      this.isLoading = true;
      this.error = null;
      this.successMessage = null;

      try {
        const payload = {
          title: notificationData.title,
          message: notificationData.message,
        };

        if (notificationData.sendToEmployee) {
          payload.send_to_employee = true;
          payload.user_email = notificationData.email;
        }

        console.log('Отправка уведомления:', payload);

        const { data } = await axios.post('/api/admin/notifications', payload);

        console.log('Уведомление отправлено:', data);

        this.successMessage = data.message || 'Уведомление успешно отправлено!';

        return { success: true, data };
      } catch (error) {
        console.error('Ошибка отправки уведомления:', error);

        let errorMessage = 'Не удалось отправить уведомление';

        if (error.response?.data?.errors) {
          const errors = error.response.data.errors;

          const firstField = Object.keys(errors)[0];
          const firstError = errors[firstField];

          errorMessage = Array.isArray(firstError) ? firstError[0] : firstError;
        }
        else if (error.response?.data?.message) {
          errorMessage = error.response.data.message;
        }

        this.error = errorMessage;

        return { success: false, error: errorMessage };
      } finally {
        this.isLoading = false;
      }
    },

    clearMessages() {
      this.error = null;
      this.successMessage = null;
    },
  },
});
