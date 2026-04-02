<script setup>
  import { ref } from 'vue';

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

  function getPlaceTypeName(type) {
    const types = {
      office: 'Офис',
      coworking: 'Коворкинг',
      meeting: 'Переговорная',
    };
    return types[type] || type;
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
      <div v-if="isLoading" class="bookings-table__loading">
        <div class="spinner"></div>
      </div>

      <div v-else-if="bookings.length === 0" class="bookings-table__empty">
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
              <th>Кабинет №</th>
              <th>Вместимость</th>
              <th>Стоимость</th>
              <th>Время</th>
              <th>Дата</th>
            </tr>
          </thead>

          <tbody>
            <tr v-for="booking in bookings" :key="booking.id">
              <td>{{ booking.user?.last_name || '—' }}</td>
              <td>{{ booking.user?.first_name || '—' }}</td>
              <td>{{ booking.user?.patronymic || '—' }}</td>
              <td>{{ getPlaceTypeName(booking.place?.type) }}</td>
              <td>№{{ booking.place?.number_place || '—' }}</td>
              <td>{{ formatCapacity(booking.place?.capacity) }}</td>
              <td>{{ booking.price }} р</td>
              <td>{{ formatTime(booking.start_time, booking.end_time) }}</td>
              <td>{{ formatDate(booking.start_time) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<style scoped lang="scss">
  @use '@/assets/styles/variables' as *;

  .bookings-table {
    &__top-scroll {
      overflow-x: auto;
      height: 8px; // меньше

      &::-webkit-scrollbar {
        height: 8px;
      }

      &::-webkit-scrollbar-track {
        background: #e5e7eb; // светлый фон
        border-radius: 10px;
      }

      &::-webkit-scrollbar-thumb {
        background: #9ca3af; // серый вместо чёрного
        border-radius: 10px;
      }

      &::-webkit-scrollbar-thumb:hover {
        background: #6b7280;
      }

      scrollbar-width: thin;
      scrollbar-color: #9ca3af #e5e7eb;
    }

    &__top-scroll-content {
      width: 100%;
      min-width: 100%;
      height: 1px;
    }

    &__wrapper {
      background: rgba(255, 255, 255, 0.7);
      border-radius: $radius-xs;
      padding: 1.5rem;
    }

    &__scroll {
      overflow-x: auto;

      &::-webkit-scrollbar {
        display: none;
      }

      scrollbar-width: none;
    }

    &__table {
      width: max-content;
      min-width: 100%;
      border-collapse: separate;
      border-spacing: 0 0.75rem;

      th {
        padding: 1rem;
        text-align: center;
        white-space: nowrap;
        border-bottom: 1px solid $color-header-bg;
      }

      td {
        padding: 0.75rem 1rem;
        text-align: center;
        white-space: nowrap;
        border-top: 1px solid $color-header-bg;
        border-bottom: 1px solid $color-header-bg;
      }

      tr td:first-child {
        border-left: 1px solid $color-header-bg;
        border-top-left-radius: 6px;
        border-bottom-left-radius: 6px;
      }

      tr td:last-child {
        border-right: 1px solid $color-header-bg;
        border-top-right-radius: 6px;
        border-bottom-right-radius: 6px;
      }
    }

    &__loading,
    &__empty {
      text-align: center;
      padding: 2rem;
    }

  }
</style>
