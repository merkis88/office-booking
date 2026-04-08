<script setup>
  import { computed } from 'vue';
  import { useBookingsStore } from '@/store/bookings';
  import { storeToRefs } from 'pinia';
  import { getPlaceTypeLabel } from '@/store/places.js';
  import { Pie } from 'vue-chartjs';
  import { Chart as ChartJS, ArcElement, Tooltip, Legend } from 'chart.js';

  ChartJS.register(ArcElement, Tooltip, Legend);

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

  const bookingsByType = computed(() => {
    const map = {};

    for (const booking of relevantBookings.value) {
      const type = booking.place?.type;
      if (!type) continue;

      map[type] = (map[type] || 0) + 1;
    }

    return map;
  });

  const pieChartData = computed(() => {
    const labels = Object.keys(bookingsByType.value).map((type) => getPlaceTypeLabel(type));

    const data = Object.values(bookingsByType.value);

    return {
      labels,
      datasets: [
        {
          data,
          backgroundColor: ['#C1F97D', '#D6E7F6', '#ECFDD8'],
          borderColor: '#7C8FA0',
          borderWidth: 2,
        },
      ],
    };
  });

  const chartOptions = {
    plugins: {
      legend: {
        display: false,
      },
    },
  };

  const hasChartData = computed(() => Object.keys(bookingsByType.value).length > 0);
</script>

<template>
  <div class="profile-analytics">
    <div class="analytics-stats">
      <div class="analytics-item">
        Любимый тип помещения:
        {{ favoritePlaceType === '—' ? '—' : getPlaceTypeLabel(favoritePlaceType) }}
      </div>

      <div class="analytics-item">Всего часов забронировано: {{ totalBookedHours.toFixed(0) }}</div>

      <div class="analytics-item">Количество бронирований: {{ totalBookingsCount }}</div>
    </div>

    <div class="analytics-chart" v-if="hasChartData">
      <Pie :data="pieChartData" :options="chartOptions" />

      <div class="chart-legend">
        <div v-for="(label, index) in pieChartData.labels" :key="label" class="legend-item">
          <span
            class="legend-color"
            :style="{ backgroundColor: pieChartData.datasets[0].backgroundColor[index] }"
          />
          {{ label }}
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;

  .profile-analytics {
    width: 70%;
    display: flex;
    justify-content: space-between;
    align-items: center;
    align-self: center;
    gap: 2rem;
    margin-top: 1rem;
  }

  .analytics-stats {
    display: flex;
    flex-direction: column;
    gap: 1rem;
    flex: 1;
  }

  .analytics-item {
    background: #f7f7f7;
    padding: 1rem;
    border-radius: 10px;
    border: $card-border;
    text-align: center;
    font-size: 1rem;
  }

  .analytics-chart {
    display: flex;
    align-items: center;
    gap: 2rem;
  }

  .analytics-chart canvas {
    width: 180px !important;
    height: 180px !important;
  }

  .chart-legend {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .legend-item {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    font-size: 1rem;
  }

  .legend-color {
    width: 18px;
    height: 18px;
    border-radius: 4px;
  }
</style>
