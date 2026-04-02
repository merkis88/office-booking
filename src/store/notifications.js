import { defineStore } from 'pinia';
import axios from 'axios';

export const useNotificationsStore = defineStore('notifications', {
  state: () => ({
    notifications: [],
    isLoading: false,
    error: null,
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
      const payload = {
        title: notificationData.title,
        message: notificationData.message,
      };

      if (notificationData.sendToEmployee) {
        payload.send_to_employee = true;
        payload.user_email = notificationData.email;
      }

      const { data } = await axios.post('/api/admin/notifications', payload);
      return data;
    },

    async fetchNotifications() {
      this.isLoading = true;
      this.error = null;

      try {
        const { data } = await axios.get('/api/notifications');
        this.notifications = data.data ?? data;
      } catch (error) {
        this.error = error.response?.data?.message || 'Ошибка загрузки уведомлений';
      } finally {
        this.isLoading = false;
      }
    },

    async markAsRead(notificationId) {
      await axios.post(`/api/notifications/${notificationId}/read`);
      const notification = this.notifications.find((n) => n.id === notificationId);
      if (notification) {
        notification.is_read = true;
      }
    },

    async markAllAsRead() {
      await axios.post('/api/notifications/mark-all-read');
      this.notifications.forEach((n) => {
        n.is_read = true;
      });
    },

    async deleteNotification(notificationId) {
      await axios.delete(`/api/notifications/${notificationId}`);
      this.notifications = this.notifications.filter((n) => n.id !== notificationId);
    },
  },
});
