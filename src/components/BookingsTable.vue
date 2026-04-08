<script setup>
  import { ref } from 'vue';
  import { getPlaceTypeLabel } from '../store/places.js';

  const props = defineProps({
    bookings: {
      type: Array,
      required: true,
    },
    isLoading: {
      type: Boolean,
      default: false,
    },
  });

  const topScrollRef = ref(null);
  const tableScrollRef = ref(null);

  function syncScrollFromTop() {
    if (topScrollRef.value && tableScrollRef.value) {
      tableScrollRef.value.scrollLeft = topScrollRef.value.scrollLeft;
    }
  }

  function syncScrollFromTable() {
    if (topScrollRef.value && tableScrollRef.value) {
      topScrollRef.value.scrollLeft = tableScrollRef.value.scrollLeft;
    }
  }

  function formatCapacity(capacity) {
    return `${capacity} человек`;
  }

  function formatTime(start, end) {
    if (!start || !end) return '';

    const s = new Date(start);
    const e = new Date(end);

    return `${s.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
   - ${e.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}`;
  }

  function formatDate(date) {
    if (!date) return '';
    return new Date(date).toLocaleDateString();
  }

  function getStatusClass(status) {
    const classes = {
      active: 'status--active',
      cancelled: 'status--cancelled',
      over: 'status--over',
    };
    return classes[status] || '';
  }

  function getStatusName(status) {
    const names = {
      active: 'Активна',
      cancelled: 'Отменена',
      over: 'Завершена',
    };
    return names[status] || status || '—';
  }
</script>

<template>
  <div class="bookings-table">
    <!-- Верхний скролл -->
    <div
      v-if="!isLoading && bookings.length > 0"
      ref="topScrollRef"
      class="bookings-table__top-scroll"
      @scroll="syncScrollFromTop"
    >
      <div class="bookings-table__top-scroll-content"></div>
    </div>

    <div class="bookings-table__wrapper">
      <div v-if="isLoading" class="loading">
        <div class="spinner"></div>
      </div>

      <div v-else-if="bookings.length === 0" class="empty-state">
        <p>История аренды пуста</p>
      </div>

      <!-- Таблица -->
      <div v-else ref="tableScrollRef" class="bookings-table__scroll" @scroll="syncScrollFromTable">
        <table class="bookings-table__table">
          <thead>
            <tr>
              <th>Фамилия</th>
              <th>Имя</th>
              <th>Отчество</th>
              <th>Тип помещения</th>
              <th>Название</th>
              <th>Кабинет №</th>
              <th>Вместимость</th>
              <th>Стоимость</th>
              <th>Время</th>
              <th>Дата</th>
              <th>Статус</th>
            </tr>
          </thead>

          <tbody>
            <tr v-for="booking in bookings" :key="booking.id">
              <td>{{ booking.user?.last_name || '—' }}</td>
              <td>{{ booking.user?.first_name || '—' }}</td>
              <td>{{ booking.user?.patronymic || '—' }}</td>
              <td>{{ getPlaceTypeLabel(booking.place?.type) }}</td>
              <td>{{ booking.place?.name || '—' }}</td>
              <td>№{{ booking.place?.number_place || '—' }}</td>
              <td>{{ formatCapacity(booking.place?.capacity) }}</td>
              <td>{{ booking.price }} р</td>
              <td>{{ formatTime(booking.start_time, booking.end_time) }}</td>
              <td>{{ formatDate(booking.start_time) }}</td>
              <td>
                <span class="bookings-table__status" :class="getStatusClass(booking.status)">
                  {{ getStatusName(booking.status) }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<style scoped lang="scss">
  @use '@/assets/styles/variables' as *;
  @use '@/assets/styles/mixins' as *;

  .bookings-table {
    &__top-scroll {
      overflow-x: auto;
      overflow-y: hidden;
      margin-bottom: 0.5rem;
      height: 14px;

      &::-webkit-scrollbar {
        height: 14px;
      }

      &::-webkit-scrollbar-track {
        background: $color-bg;
        border-radius: 10px;
      }

      &::-webkit-scrollbar-thumb {
        background: $color-text;
        border: 2px solid $color-text;
        border-radius: 10px;
        background-clip: padding-box;

        &:hover {
          background: $color-footer-bg;
          border-color: $color-text;
        }

        &:active {
          background: $color-footer-bg;
        }
      }

      scrollbar-width: thin;
      scrollbar-color: $color-footer-bg $color-bg;
    }

    &__top-scroll-content {
      width: 1800px;
      height: 1px;
    }

    &__wrapper {
      background: $table-bg;
      border-radius: $table-radius;
      padding: 1.5rem;
    }

    &__scroll {
      overflow-x: auto;
      overflow-y: visible;
      max-width: 100%;

      &::-webkit-scrollbar {
        display: none;
      }

      scrollbar-width: none;
      -ms-overflow-style: none;
    }

    &__table {
      @include admin-table;
      min-width: 1600px;
    }

    &__status {
      padding: 0.375rem 0.75rem;
      border-radius: $radius-xs;
      font-size: $text-sm;
      font-weight: 500;
      white-space: nowrap;

      &.status--active {
        background: $color-status-active;
        color: $color-status-active-text;
      }

      &.status--over {
        background: $color-warning-light;
        color: $color-warning-text;
      }

      &.status--cancelled {
        background: $color-status-blocked;
        color: $color-status-blocked-text;
      }
    }
  }
</style>
