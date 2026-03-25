import { defineStore } from 'pinia';
import axios from 'axios';

export const useServicesStore = defineStore('services', {
    state: () => ({
        bookings: [],
        services: [],
        serviceTypes: [], // ✅ ДОБАВЛЕНО
        isLoading: false,
        error: null,
        successMessage: null,
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

                if (data.success && Array.isArray(data.data)) {
                    this.bookings = data.data;
                } else if (Array.isArray(data)) {
                    this.bookings = data;
                } else {
                    this.bookings = [];
                }

                return { success: true, data: this.bookings };
            } catch (error) {
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
                this.error = 'Ошибка загрузки заявок';
                this.services = [];
                return { success: false, error: this.error };
            } finally {
                this.isLoading = false;
            }
        },

        // ✅ НОВЫЙ метод - загрузка типов заявок
        async fetchServiceTypes() {
            this.isLoading = true;
            this.error = null;

            try {
                const { data } = await axios.get('/api/admin/service-types');

                if (data.success && Array.isArray(data.data)) {
                    this.serviceTypes = data.data;
                } else if (Array.isArray(data)) {
                    this.serviceTypes = data;
                } else {
                    this.serviceTypes = [];
                }

                return { success: true, data: this.serviceTypes };
            } catch (error) {
                console.error('Ошибка загрузки типов заявок:', error);
                this.error = 'Ошибка загрузки типов заявок';
                this.serviceTypes = [];
                return { success: false, error: this.error };
            } finally {
                this.isLoading = false;
            }
        },

        // ✅ НОВЫЙ метод - создание типа заявки
        async createServiceType(typeData) {
            this.isLoading = true;
            this.error = null;

            try {
                const { data } = await axios.post('/api/admin/service-types', {
                    name: typeData.name,
                });

                const newType = data.data || data;
                this.serviceTypes.push(newType);

                return { success: true, data: newType };
            } catch (error) {
                console.error('Ошибка создания типа заявки:', error);
                const message = error.response?.data?.message || 'Не удалось создать тип заявки';
                this.error = message;
                return { success: false, error: message };
            } finally {
                this.isLoading = false;
            }
        },

        // ✅ НОВЫЙ метод - обновление типа заявки
        async updateServiceType(typeId, typeData) {
            this.isLoading = true;
            this.error = null;

            try {
                const { data } = await axios.put(`/api/admin/service-types/${typeId}`, {
                    name: typeData.name,
                });

                const updatedType = data.data || data;
                const index = this.serviceTypes.findIndex((t) => t.id === typeId);
                if (index !== -1) {
                    this.serviceTypes[index] = updatedType;
                }

                return { success: true, data: updatedType };
            } catch (error) {
                console.error('Ошибка обновления типа заявки:', error);
                const message = error.response?.data?.message || 'Не удалось обновить тип заявки';
                this.error = message;
                return { success: false, error: message };
            } finally {
                this.isLoading = false;
            }
        },

        // ✅ НОВЫЙ метод - удаление типа заявки
        async deleteServiceType(typeId) {
            this.isLoading = true;
            this.error = null;

            try {
                await axios.delete(`/api/admin/service-types/${typeId}`);

                const index = this.serviceTypes.findIndex((t) => t.id === typeId);
                if (index !== -1) {
                    this.serviceTypes.splice(index, 1);
                }

                return { success: true };
            } catch (error) {
                console.error('Ошибка удаления типа заявки:', error);
                const message = error.response?.data?.message || 'Не удалось удалить тип заявки';
                this.error = message;
                return { success: false, error: message };
            } finally {
                this.isLoading = false;
            }
        },

        async createServiceRequest(requestData) {
            this.isLoading = true;
            this.error = null;
            this.successMessage = null;
            this.validationErrors = null;

            try {
                const payload = {
                    booking_id: requestData.booking_id,
                    service_type_id: requestData.service_type_id,
                    service_date: requestData.service_date,
                    service_time: requestData.service_time,
                    comment: requestData.comment || null,
                };

                const { data } = await axios.post('/api/service-types', payload);

                if (data.data) {
                    this.services.unshift(data.data);
                }

                this.successMessage = data.message || 'Заявка успешно создана';

                return {
                    success: true,
                    message: this.successMessage,
                    data: data.data || data,
                };
            } catch (error) {
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

        clearMessages() {
            this.error = null;
            this.successMessage = null;
            this.validationErrors = null;
        },
    },
    async deleteServiceType(typeId) {
        this.isLoading = true;
        this.error = null;

        try {
            await axios.delete(`/api/admin/service-types/${typeId}`);

            const index = this.serviceTypes.findIndex((t) => t.id === typeId);
            if (index !== -1) {
                this.serviceTypes.splice(index, 1);
            }

            return { success: true };
        } catch (error) {
            console.error('Ошибка удаления типа заявки:', error);
            const message = error.response?.data?.message || 'Не удалось удалить тип заявки';
            this.error = message;
            return { success: false, error: message };
        } finally {
            this.isLoading = false;
        }
    },
});
