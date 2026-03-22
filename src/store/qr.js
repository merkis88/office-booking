import { defineStore } from 'pinia';
import axios from 'axios';

export const useQrStore = defineStore('qr', {
  state: () => ({
    // bookingId → { loading, error, qrData }
    passes: {},
  }),

  actions: {
    /**
     * Получить QR для текущего пользователя по бронированию
     * POST /api/qr/{bookingId}/user-qr
     */
    async createUserQr(bookingId) {
      this.passes[bookingId] = {
        loading: true,
        error: null,
        qrData: null,
      };

      try {
        const { data } = await axios.post(`/api/qr/${bookingId}/user-qr`);
        this.passes[bookingId] = {
          loading: false,
          error: null,
          qrData: data.data ?? data,
        };
      } catch (e) {
        this.passes[bookingId] = {
          loading: false,
          error: e.response?.data?.message || 'Не удалось получить QR-код',
          qrData: null,
        };
      }
    },

    /**
     * Получить гостевой QR
     * POST /api/qr/{bookingId}/guest-qr
     */
    async createGuestQr(bookingId, { recipient_email, guest_name, time_window }) {
      try {
        const { data } = await axios.post(`/api/qr/${bookingId}/guest-qr`, {
          recipient_email,
          guest_name: guest_name || undefined,
          time_window: time_window || undefined,
        });
        return data.data ?? data;
      } catch (e) {
        throw new Error(e.response?.data?.message || 'Ошибка создания гостевого QR');
      }
    },

    /**
     * Выдать QR зарегистрированному сотруднику
     * POST /api/qr/{bookingId}/issue-qr
     */
    async issueQr(bookingId, recipientUserId) {
      try {
        const { data } = await axios.post(`/api/qr/${bookingId}/issue-qr`, {
          recipient_user_id: recipientUserId,
        });
        return data.data ?? data;
      } catch (e) {
        throw new Error(e.response?.data?.message || 'Ошибка выдачи QR сотруднику');
      }
    },
  },
});
