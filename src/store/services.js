import { defineStore } from 'pinia';
import axios from 'axios';

export const useServicesStore = defineStore('services', {
  state: () => ({
    bookings: [],
    services: [],
    isLoading: false,
    error: null,
  }),

  actions: {
    // ✅ Загрузка списка бронирований пользователя
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
          console.warn('Неожиданный формат данных:', data);
          this.bookings = [];
        }

        return { success: true, data: this.bookings };
      } catch (error) {
        console.error('Ошибка загрузки бронирований:', error);

        if (error.response) {
          console.error('Статус ошибки:', error.response.status);
          console.error('Данные ошибки:', error.response.data);

          if (error.response.status === 401) {
            this.error = 'Требуется авторизация';
          } else if (error.response.status === 404) {
            this.error = 'Эндпоинт не найден';
          } else {
            this.error = error.response.data.message || 'Ошибка загрузки бронирований';
          }
        } else if (error.request) {
          this.error = 'Нет ответа от сервера';
        } else {
          this.error = error.message;
        }

        this.bookings = [];
        return { success: false, error: this.error };
      } finally {
        this.isLoading = false;
      }
    },

    // ✅ Создание новой заявки на обслуживание
    async createServiceRequest(requestData) {
      this.isLoading = true;
      this.error = null;

      try {
        const payload = {
          booking_id: requestData.booking_id,
          service_type_id: requestData.service_type_id,
          service_date: requestData.service_date, // формат: "2026-03-25"
          service_time: requestData.service_time, // формат: "15:00"
          comment: requestData.comment || null,
        };

        console.log('Отправка заявки на сервер:', payload);

        const { data } = await axios.post('/api/services', payload);

        console.log('Заявка создана:', data);

        // Добавляем созданную заявку в список (если сервер возвращает данные)
        if (data.data) {
          this.services.push(data.data);
        }

        return {
          success: true,
          message: data.message || 'Заявка успешно создана',
          data: data.data || data,
        };
      } catch (error) {
        console.error('Ошибка создания заявки:', error);

        let errorMessage = 'Не удалось создать заявку';

        if (error.response) {
          console.error('Статус ошибки:', error.response.status);
          console.error('Данные ошибки:', error.response.data);

          if (error.response.data.message) {
            errorMessage = error.response.data.message;
          } else if (error.response.data.errors) {
            const errors = error.response.data.errors;
            const firstError = Object.values(errors)[0];
            errorMessage = Array.isArray(firstError) ? firstError[0] : firstError;
          }

          this.error = errorMessage;
        } else if (error.request) {
          errorMessage = 'Нет ответа от сервера';
          this.error = errorMessage;
        } else {
          this.error = error.message;
          errorMessage = error.message;
        }

        return { success: false, error: errorMessage };
      } finally {
        this.isLoading = false;
      }
    },

    // ✅ Очистка ошибок
    clearError() {
      this.error = null;
    },
  },
});
