import { defineStore } from 'pinia';
import axios from 'axios';

export const useQrStore = defineStore('qr', {
  actions: {
    /**
     * QR для сотрудника
     * POST /api/qr/{bookingId}/user-qr
     * Body: { email }
     */
    async sendUserQr(bookingId, { email }) {
      const { data } = await axios.post(`/api/qr/${bookingId}/user-qr`, {
        email,
      });
      return data.data ?? data;
    },

    /**
     * QR для гостя
     * POST /api/qr/{bookingId}/guest-qr
     * Body: { recipient_email }
     */
    async sendGuestQr(bookingId, { email }) {
      const { data } = await axios.post(`/api/qr/${bookingId}/guest-qr`, {
        recipient_email: email,
      });
      return data.data ?? data;
    },
  },
});
