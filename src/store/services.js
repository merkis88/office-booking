import { defineStore } from 'pinia';
import axios from 'axios';

export const useServicesStore = defineStore('services', {
  state: () => ({
    bookings: [],
    services: [],
    serviceTypes: [],
    isLoading: false,
    error: null,
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
        this.bookings = data.data ?? data;
        if (!Array.isArray(this.bookings)) this.bookings = [];
      } catch (error) {
        this.error = error.response?.data?.message || 'Ошибка загрузки бронирований';
        this.bookings = [];
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

        this.services = data.data ?? data;
        if (!Array.isArray(this.services)) this.services = [];

        if (data.meta) {
          this.currentPage = data.meta.current_page;
          this.lastPage = data.meta.last_page;
          this.perPage = data.meta.per_page;
          this.total = data.meta.total;
        }
      } catch (error) {
        this.error = error.response?.data?.message || 'Ошибка загрузки заявок';
        this.services = [];
      } finally {
        this.isLoading = false;
      }
    },

    async fetchServiceTypes() {
      this.isLoading = true;
      this.error = null;

      try {
        const { data } = await axios.get('/api/admin/service-types');
        this.serviceTypes = data.data ?? data;
        if (!Array.isArray(this.serviceTypes)) this.serviceTypes = [];
      } catch (error) {
        this.error = error.response?.data?.message || 'Ошибка загрузки типов заявок';
        this.serviceTypes = [];
      } finally {
        this.isLoading = false;
      }
    },

    async createServiceType(typeData) {
      const { data } = await axios.post('/api/admin/service-types', {
        name: typeData.name,
      });
      const newType = data.data ?? data;
      this.serviceTypes.push(newType);
      return newType;
    },

    async updateServiceType(typeId, typeData) {
      const { data } = await axios.put(`/api/admin/service-types/${typeId}`, {
        name: typeData.name,
      });
      const updatedType = data.data ?? data;
      const index = this.serviceTypes.findIndex((t) => t.id === typeId);
      if (index !== -1) {
        this.serviceTypes[index] = updatedType;
      }
      return updatedType;
    },

    async deleteServiceType(typeId) {
      await axios.delete(`/api/admin/service-types/${typeId}`);
      const index = this.serviceTypes.findIndex((t) => t.id === typeId);
      if (index !== -1) {
        this.serviceTypes.splice(index, 1);
      }
    },

    async updateServiceStatus(serviceId, status) {
      const { data } = await axios.put(`/api/admin/services/${serviceId}/status`, {
        status,
      });
      const updated = data.data ?? data;
      const index = this.services.findIndex((s) => s.id === serviceId);
      if (index !== -1) {
        this.services[index] = updated;
      }
      return updated;
    },

    async createServiceRequest(requestData) {
      const payload = {
        booking_id: requestData.booking_id,
        service_type_id: requestData.service_type_id,
        service_date: requestData.service_date,
        service_time: requestData.service_time,
        comment: requestData.comment || null,
      };

      const { data } = await axios.post('/api/services', payload);
      const newService = data.data ?? data;
      if (newService) {
        this.services.unshift(newService);
      }
      return newService;
    },
  },
});
