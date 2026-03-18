import { defineStore } from 'pinia';
import axios from 'axios';

export const useNotificationsStore = defineStore('notifications', {
  state: () => ({
    notifications: [],
    isLoading: false,
    error: null,
    successMessage: null,
  }),

  getters: {
    unreadCount: (state) => {
      return state.notifications.filter((n) => !n.is_read).length;
    },

    hasUnread: (state) => {
      return state.notifications.some((n) => !n.is_read);
    },
  },

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
        } else if (error.response?.data?.message) {
          errorMessage = error.response.data.message;
        }

        this.error = errorMessage;

        return { success: false, error: errorMessage };
      } finally {
        this.isLoading = false;
      }
    },

    async fetchNotifications() {
      this.isLoading = true;
      this.error = null;

      try {
        const { data } = await axios.get('/api/notifications');

        this.notifications = data.data || data;

        console.log('Уведомления загружены:', this.notifications);

        return { success: true, data: this.notifications };
      } catch (error) {
        console.error('Ошибка загрузки уведомлений:', error);
        this.error = 'Не удалось загрузить уведомления';
        return { success: false, error: this.error };
      } finally {
        this.isLoading = false;
      }
    },

    async markAsRead(notificationId) {
      try {
        await axios.post(`/api/notifications/${notificationId}/read`);

        const notification = this.notifications.find((n) => n.id === notificationId);
        if (notification) {
          notification.is_read = true;
        }

        console.log(`Уведомление ${notificationId} отмечено как прочитанное`);

        return { success: true };
      } catch (error) {
        console.error('Ошибка отметки как прочитанное:', error);
        return { success: false, error: error.message };
      }
    },

    async markAllAsRead() {
      try {
        await axios.post('/api/notifications/mark-all-read');

        this.notifications.forEach((n) => {
          n.is_read = true;
        });

        console.log('Все уведомления отмечены как прочитанные');

        return { success: true };
      } catch (error) {
        console.error('Ошибка отметки всех как прочитанные:', error);
        return { success: false, error: error.message };
      }
    },

    async deleteNotification(notificationId) {
      try {
        await axios.delete(`/api/notifications/${notificationId}`);

        this.notifications = this.notifications.filter((n) => n.id !== notificationId);

        console.log(`Уведомление ${notificationId} удалено`);

        return { success: true };
      } catch (error) {
        console.error('Ошибка удаления уведомления:', error);
        return { success: false, error: error.message };
      }
    },

    clearMessages() {
      this.error = null;
      this.successMessage = null;
    },
  },
});
