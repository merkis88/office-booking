<script setup>
  import { onMounted } from 'vue';
  import { useAdminBookingsStore } from '@/store/adminBookings';

  const bookingsStore = useAdminBookingsStore();

  onMounted(() => {
    bookingsStore.fetchBookings();
  });

  const formatDate = (date) => {
    return new Date(date).toLocaleDateString('ru-RU');
  };

  const formatTime = (date) => {
    return new Date(date).toLocaleTimeString('ru-RU', {
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  const placeTypeMap = {
    meeting_room: 'Переговорная',
    office: 'Офис',
    coworking: 'Коворкинг',
  };
</script>

<template>
  <div class="admin-bookings">
    <h1 class="admin-bookings__title">История аренды помещений</h1>

    <div class="admin-bookings__table">
      <div class="admin-bookings__head">
        <span>Фамилия</span>
        <span>Имя</span>
        <span>Отчество</span>
        <span>Тип помещения</span>
        <span>Кабинет №</span>
        <span>Вместимость</span>
        <span>Стоимость</span>
      </div>

      <div v-for="booking in bookingsStore.bookings" :key="booking.id" class="admin-bookings__row">
        <span>{{ booking.user?.last_name }}</span>
        <span>{{ booking.user?.first_name }}</span>
        <span>{{ booking.user?.patronymic || '-' }}</span>

        <span>
          {{ placeTypeMap[booking.place?.type] }}
        </span>

        <span>
          {{ booking.place?.name }}
        </span>

        <span>{{ booking.place?.capacity }} человек</span>

        <span>{{ booking.price ?? 0 }}р</span>
      </div>
    </div>

    <div class="admin-bookings__pagination" v-if="bookingsStore.lastPage > 1">
      <button
        v-for="page in bookingsStore.lastPage"
        :key="page"
        @click="bookingsStore.setPage(page)"
        :class="['admin-bookings__page', { active: page === bookingsStore.currentPage }]"
      >
        {{ page }}
      </button>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  .admin-bookings {
    max-width: 1100px;
    margin: 0 auto;

    &__title {
      text-align: center;
      font-size: 28px;
      margin-bottom: 30px;
    }

    &__table {
      background: #d8e0e5;
      padding: 25px;
      border-radius: 12px;
    }

    &__head {
      display: grid;
      grid-template-columns: repeat(7, 1fr);
      padding-bottom: 15px;
      border-bottom: 1px solid black;
      margin-bottom: 15px;
    }

    &__row {
      display: grid;
      grid-template-columns: repeat(7, 1fr);
      padding: 12px;
      border: 1px solid black;
      border-radius: 10px;
      margin-bottom: 10px;
    }

    &__pagination {
      display: flex;
      justify-content: center;
      gap: 10px;
      margin-top: 25px;
    }

    &__page {
      padding: 6px 12px;
      border: 1px solid black;
      border-radius: 6px;
    }

    &__page.active {
      background: #8b9dad;
      color: white;
    }
  }
</style>
