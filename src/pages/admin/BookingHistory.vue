<script setup>
  //import { useAdminBookingsStore } from '@/store/adminBookings';
  import { useAuthStore } from '@/store/auth.js';
  import { useRouter } from 'vue-router';
  import { ref, onMounted, computed } from 'vue';

  const router = useRouter();
  const bookingsStore = useAdminBookingsStore();
  const authStore = useAuthStore();
  const searchQuery = ref('');
  const selectedFilter = ref('all');

  onMounted(() => {
    bookingsStore.fetchBookings();
  });

  const formatTime = (date) => {
    return new Date(date).toLocaleTimeString('ru-RU', {
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  const formatDateOnly = (date) => {
    return new Date(date).toLocaleDateString('ru-RU');
  };

  const formatTimeRange = (start, end) => {
    const startTime = formatTime(start);
    const endTime = formatTime(end);
    return `${startTime}-${endTime}`;
  };

  const placeTypeMap = {
    meeting_room: 'Переговорная',
    office: 'Офис',
    coworking: 'Коворкинг',
  };

  function goBack() {
    router.push('/admin/places');
  }

  function applyFilter(type) {
    selectedFilter.value = type;
    showFilterDropdown.value = false;
  }

  const filteredBookings = computed(() => {
    const list = bookingsStore.bookings || [];

    return list.filter((b) => {
      const matchesSearch = b.user?.last_name
        ?.toLowerCase()
        .includes(searchQuery.value.toLowerCase());

      const matchesFilter =
        selectedFilter.value === 'all' ||
        b.place?.type === selectedFilter.value ||
        (selectedFilter.value === 'meeting' && b.place?.type === 'meeting_room');

      return matchesSearch && matchesFilter;
    });
  });

  function getFilterLabel() {
    const labels = {
      all: 'Все помещения',
      office: 'Офисы',
      coworking: 'Коворкинги',
      meeting: 'Переговорные',
    };
    return labels[selectedFilter.value];
  }

  const exportBookings = async () => {
    try {
      const params = new URLSearchParams(
        Object.fromEntries(
          Object.entries(bookingsStore.filters).filter(
            ([_, v]) => v !== null && v !== undefined && v !== '',
          ),
        ),
      );

      const res = await fetch(`/api/admin/bookings/export?${params}`, {
        headers: {
          Authorization: `Bearer ${authStore.token}`,
          Accept: 'text/csv',
        },
      });

      const blob = await res.blob();

      const url = window.URL.createObjectURL(blob);

      const a = document.createElement('a');
      a.href = url;
      a.download = `bookings_${new Date().toISOString()}.csv`;

      document.body.appendChild(a);
      a.click();
      a.remove();

      window.URL.revokeObjectURL(url);
    } catch (e) {
      console.error(e);
    }
  };
</script>

<template>
  <div class="admin-bookings">
    <div class="admin-bookings__controls">
      <div class="admin-bookings__control">
        <button class="admin-bookings__btn" @click="goBack">
          <img src="@/assets/images/icons/arrow-left.svg" alt="&lt;" />
        </button>
      </div>

      <div class="admin-bookings__control">
        <button class="admin-bookings__btn" @click="showFilterDropdown = !showFilterDropdown">
          <img src="@/assets/images/icons/filter.svg" />
          <span>{{ getFilterLabel() }}</span>
        </button>

        <transition name="dropdown">
          <div v-if="showFilterDropdown" class="admin-bookings__dropdown">
            <div @click="applyFilter('all')" class="admin-bookings__dropdown-item">
              Все помещения
            </div>
            <div @click="applyFilter('office')" class="admin-bookings__dropdown-item">Офисы</div>
            <div @click="applyFilter('coworking')" class="admin-bookings__dropdown-item">
              Коворкинги
            </div>
            <div @click="applyFilter('meeting')" class="admin-bookings__dropdown-item">
              Переговорные
            </div>
          </div>
        </transition>
      </div>

      <div class="admin-bookings__control">
        <div class="admin-bookings__search">
          <img src="@/assets/images/icons/search.svg" />
          <input v-model="searchQuery" type="text" placeholder="Поиск по фамилии" />
        </div>
      </div>

      <div class="admin-bookings__control">
        <button class="admin-bookings__btn" @click="exportBookings">
          <img src="@/assets/images/icons/download.svg" />
          <span>Сохранить</span>
        </button>
      </div>
    </div>

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
        <span>Дата</span>
        <span>Время</span>
      </div>

      <div v-for="booking in filteredBookings" :key="booking.id" class="admin-bookings__row">
        <span>{{ booking.user?.last_name }}</span>
        <span>{{ booking.user?.first_name }}</span>
        <span>{{ booking.user?.patronymic || '-' }}</span>

        <span>
          {{ placeTypeMap[booking.place?.type] }}
        </span>

        <span>
          {{ booking.place?.number_place }}
        </span>

        <span>{{ booking.place?.capacity }} человек</span>

        <span>{{ Math.round(booking.place?.price) }} р/час</span>

        <span>{{ formatDateOnly(booking.start_time) }}</span>

        <span>{{ formatTimeRange(booking.start_time, booking.end_time) }}</span>
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
  @use '@/assets/styles/variables' as *;
  @use '@/assets/styles/mixins' as *;

  .admin-bookings {
    width: 90%;
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
      grid-template-columns: repeat(9, 1fr);
      padding-bottom: 15px;
      border-bottom: 1px solid $color-footer-bg;
      margin-bottom: 15px;
      text-align: center;
    }

    &__row {
      display: grid;
      grid-template-columns: repeat(9, 1fr);
      padding: 12px;
      border: 1px solid $color-footer-bg;
      border-radius: 10px;
      margin-bottom: 10px;
      text-align: center;
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

    &__controls {
      display: flex;
      gap: 12px;
      margin-bottom: 20px;
      align-items: center;
    }

    &__btn {
      display: flex;
      align-items: center;
      gap: 8px;

      padding: 8px 14px;
      border: 1px solid #000;
      border-radius: 10px;
      background: transparent;
      cursor: pointer;

      font-size: 14px;

      img {
        width: 18px;
        height: 18px;
        object-fit: contain;
      }

      &:hover {
        background: #cfd8df;
      }
    }

    &__btn--icon {
      padding: 8px;
      border: none;
      background: transparent;

      img {
        width: 30px;
        height: 30px;
      }

      &:hover {
        background: transparent;
        opacity: 0.7;
      }
    }
  }

  .dropdown-enter-active {
    animation: dropdown-in 0.2s ease-out;
  }

  .dropdown-leave-active {
    animation: dropdown-out 0.2s ease-in;
  }

  @keyframes dropdown-in {
    from {
      opacity: 0;
      transform: translateY(-10px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  @keyframes dropdown-out {
    from {
      opacity: 1;
      transform: translateY(0);
    }
    to {
      opacity: 0;
      transform: translateY(-10px);
    }
  }
</style>
