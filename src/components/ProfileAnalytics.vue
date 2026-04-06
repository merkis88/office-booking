<script setup>
  import { computed } from 'vue';
  import { useBookingsStore } from '@/store/bookings';
  import { storeToRefs } from 'pinia';

  const bookingsStore = useBookingsStore();
  const { bookings } = storeToRefs(bookingsStore);

  const relevantBookings = computed(() =>
    bookings.value.filter((b) => b.status === 'active' || b.status === 'over'),
  );

  const favoritePlaceType = computed(() => {
    const countMap = {};
    for (const booking of relevantBookings.value) {
      const type = booking.place?.type;
      if (!type) continue;
      countMap[type] = (countMap[type] || 0) + 1;
    }
    const entries = Object.entries(countMap);
    if (!entries.length) return '—';

    entries.sort((a, b) => b[1] - a[1]);
    const [topType, topCount] = entries[0];

    const secondCount = entries[1]?.[1] || 0;
    return topCount > secondCount ? topType : '—';
  });

  const totalBookedHours = computed(() => {
    return relevantBookings.value.reduce((sum, booking) => {
      const start = new Date(booking.start_time);
      const end = new Date(booking.end_time);
      const hours = (end - start) / (1000 * 60 * 60); // переводим миллисекунды в часы
      return sum + hours;
    }, 0);
  });

  const totalBookingsCount = computed(() => relevantBookings.value.length);
</script>

<template>
  <div class="profile-analytics">
    <div class="analytics-item">
      <strong>Любимый тип помещений:</strong>
      {{ favoritePlaceType }}
    </div>
    <div class="analytics-item">
      <strong>Всего часов забронировано:</strong>
      {{ totalBookedHours.toFixed(1) }}
    </div>
    <div class="analytics-item">
      <strong>Всего бронирований:</strong>
      {{ totalBookingsCount }}
    </div>
  </div>
</template>

<style scoped>
  .profile-analytics {
    display: flex;
    gap: 2rem;
    flex-wrap: wrap;
    margin-top: 1rem;
  }
  .analytics-item {
    background: #f7f7f7;
    padding: 1rem 1.5rem;
    border-radius: 8px;
    font-size: 1rem;
  }
</style>
