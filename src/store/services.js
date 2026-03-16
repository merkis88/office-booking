import { defineStore } from 'pinia';
import axios from 'axios';

export const useServicesStore = defineStore('services', {
  state: () => ({
    bookings: [],
    services: [],
    isLoading: false,
    error: null,
    validationErrors: null,
    currentPage: 1,
    lastPage: 1,
    perPage: 6,
    total: 0,
  }),

  actions: {
    async fetchMyBookings() {
      this.isLoading = true;
      this.error = null;

      try {
        const { data } = await axios.get('/api/services/my-bookings');

        console.log('Бронирования загружены:', data);

        if (data.success && Array.isArray(data.data)) {
          this.bookings = data.data;
        } else if (Array.isArray(data)) {
          this.bookings = data;
        } else {
          this.bookings = [];
        }

        return { success: true, data: this.bookings };
      } catch (error) {
        console.error('Ошибка загрузки бронирований:', error);
        this.error = 'Ошибка загрузки бронирований';
        this.bookings = [];
        return { success: false, error: this.error };
      } finally {
        this.isLoading = false;
      }
    },

    async fetchServices(page = 1) {
      this.isLoading = true;
      this.error = null;

      try {
        const { data } = await axios.get('/api/services', {
          params: { page },
        });


        if (data.success && Array.isArray(data.data)) {
          this.services = data.data;

          if (data.meta) {
            this.currentPage = data.meta.current_page;
            this.lastPage = data.meta.last_page;
            this.perPage = data.meta.per_page;
            this.total = data.meta.total;
          }
        } else if (Array.isArray(data)) {
          this.services = data;
        } else {
          this.services = [];
        }

        return { success: true, data: this.services };
      } catch (error) {
        console.error('Ошибка загрузки заявок:', error);
        this.error = 'Ошибка загрузки заявок';
        this.services = [];
        return { success: false, error: this.error };
      } finally {
        this.isLoading = false;
      }
    },

    async createServiceRequest(requestData) {
      this.isLoading = true;
      this.error = null;
      this.validationErrors = null;

      try {
        const payload = {
          booking_id: requestData.booking_id,
          service_type_id: requestData.service_type_id,
          service_date: requestData.service_date,
          service_time: requestData.service_time,
          comment: requestData.comment || null,
        };

        const { data } = await axios.post('/api/services', payload);

        if (data.data) {
          this.services.unshift(data.data);
        }

        return {
          success: true,
          message: data.message || 'Заявка успешно создана',
          data: data.data || data,
        };
      } catch (error) {
        console.error('Ошибка создания заявки:', error);

        let errorMessage = 'Не удалось создать заявку';

        if (error.response?.data?.message) {
          errorMessage = error.response.data.message;
        } else if (error.response?.data?.errors) {
          const errors = error.response.data.errors;
          const firstError = Object.values(errors)[0];
          errorMessage = Array.isArray(firstError) ? firstError[0] : firstError;
        }

        this.error = errorMessage;
        return { success: false, error: errorMessage };
      } finally {
        this.isLoading = false;
      }
    },

    clearError() {
      this.error = null;
      this.validationErrors = null;
    },
  },
});
