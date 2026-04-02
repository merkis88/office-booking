import { defineStore } from 'pinia';
import axios from 'axios';

export const useQrStore = defineStore('qr', {
  state: () => ({
    // bookingId -> { loading, error, qrData }
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
    async createGuestQr(bookingId, { recipient_email }) {
      const { data } = await axios.post(`/api/qr/${bookingId}/guest-qr`, {
        recipient_email,
      });
      return data.data ?? data;
    },

    /**
     * Выдать QR зарегистрированному сотруднику
     * POST /api/qr/{bookingId}/issue-qr
     */
    async issueQr(bookingId, { recipient_email }) {
      const { data } = await axios.post(`/api/qr/${bookingId}/issue-qr`, {
        recipient_email,
      });
      return data.data ?? data;
    },
  },
});
