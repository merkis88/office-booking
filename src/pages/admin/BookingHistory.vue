<script setup>
  import { ref, onMounted } from 'vue';
  import { useBookingsStore } from '@/store/bookings';
  import { useRouter } from 'vue-router';
  import { storeToRefs } from 'pinia';
  import BookingsTable from '@/components/BookingsTable.vue';
  import AppPagination from '@/components/AppPagination.vue';

  const bookingsStore = useBookingsStore();
  const router = useRouter();

  const { isLoading, currentPage, totalPages, paginatedBookings, filters, searchQuery } =
    storeToRefs(bookingsStore);

  const showFilterDropdown = ref(false);

  onMounted(async () => {
    await bookingsStore.fetchBookings({ admin: true });
  });

  function goBack() {
    router.push('/admin/places');
  }

  function applyFilter(filterType) {
    bookingsStore.setFilter('type', filterType, true);
    showFilterDropdown.value = false;
  }

  function goToPage(page) {
    bookingsStore.setPage(page, true);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  function getFilterLabel() {
    const labels = {
      all: 'Все помещения',
      office: 'Офисы',
      coworking: 'Коворкинги',
      meeting: 'Переговорные',
    };
    return labels[filters.value.type] || 'Фильтрация';
  }
</script>

<template>
  <div class="admin-bookings">
    <div class="admin-bookings__container">
      <div class="admin-bookings__controls">
        <div class="admin-bookings__control">
          <button class="admin-bookings__btn--back" @click="goBack">
            <img src="@/assets/images/icons/arrow-left.svg" alt="Назад" />
          </button>
        </div>

        <div class="admin-bookings__control">
          <button class="admin-bookings__btn" @click="showFilterDropdown = !showFilterDropdown">
            <img src="@/assets/images/icons/filter.svg" alt="Фильтрация" />
            <span>{{ getFilterLabel() }}</span>
          </button>

          <transition name="dropdown">
            <div v-if="showFilterDropdown" class="admin-bookings__dropdown">
              <div class="admin-bookings__dropdown-item" @click="applyFilter('all')">
                Все помещения
              </div>
              <div class="admin-bookings__dropdown-item" @click="applyFilter('office')">Офисы</div>
              <div class="admin-bookings__dropdown-item" @click="applyFilter('coworking')">
                Коворкинги
              </div>
              <div class="admin-bookings__dropdown-item" @click="applyFilter('meeting')">
                Переговорные
              </div>
            </div>
          </transition>
        </div>

        <div class="admin-bookings__control">
          <div class="admin-bookings__search">
            <img
              src="@/assets/images/icons/search.svg"
              alt="Поиск"
              class="admin-bookings__search-icon"
            />
            <input
              :value="searchQuery"
              @input="bookingsStore.setSearchQuery($event.target.value)"
              type="text"
              class="admin-bookings__search-input"
              placeholder="Поиск по фамилии"
            />
          </div>
        </div>

        <div class="admin-bookings__control">
          <button class="admin-bookings__btn" @click="bookingsStore.exportBookings">
            <img src="@/assets/images/icons/download.svg" alt="Экспорт" />
            <span>Сохранить</span>
          </button>
        </div>
      </div>

      <h1 class="admin-bookings__title">История аренды помещений</h1>

      <div class="admin-bookings__table-wrapper">
        <BookingsTable :bookings="paginatedBookings" :is-loading="isLoading" />
      </div>

      <AppPagination
        v-if="!isLoading"
        :current-page="currentPage"
        :total-pages="totalPages"
        @update:current-page="goToPage"
      />
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;
  @use '@/assets/styles/mixins' as *;

  .admin-bookings {
    min-height: 100vh;

    &__container {
      @include container;
      max-width: 1200px;
    }

    // ===== Controls =====
    &__controls {
      display: flex;
      gap: 1rem;
      margin-bottom: 2rem;
      flex-wrap: wrap;
    }

    &__control {
      position: relative;
    }

    &__btn {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      padding: 0.75rem 1.25rem;
      width: 13rem;
      background: $color-btn-profile;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      cursor: pointer;
      font-size: $text-base;
      color: $color-text;

      img {
        width: 20px;
        height: 20px;
      }

      &:hover {
        background: $color-input-bg;
      }

      &--back {
        border: none;
        background: none;

        img {
          width: 40px;
          height: 40px;
        }
      }
    }

    // ===== Dropdown =====
    &__dropdown {
      position: absolute;
      top: 100%;
      left: 0;
      margin-top: 0.5rem;
      background: $color-btn-profile;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      min-width: 200px;
      z-index: 10;
    }

    &__dropdown-item {
      padding: 0.75rem 1rem;
      cursor: pointer;

      &:hover {
        background: rgba($color-text, 0.05);
      }
    }

    // ===== Search =====
    &__search {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      padding: 0.75rem 1rem;
      width: 13rem;
      background: $color-btn-profile;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
    }

    &__search-icon {
      width: 20px;
      height: 20px;
    }

    &__search-input {
      border: none;
      outline: none;
      background: transparent;
      font-size: $text-base;
      color: $color-text;
      width: 100%;
    }

    // ===== Title =====
    &__title {
      font-family: $font-title;
      font-size: $text-2xl;
      font-weight: 500;
      color: $color-text;
      text-align: center;
      margin-bottom: 2rem;
    }

    // ===== Wrapper =====
    &__table-wrapper {
      margin-bottom: 2rem;
    }

    &__loading,
    &__empty {
      text-align: center;
      padding: 2rem;
      color: rgba($color-text, 0.6);
    }

    // ===== Responsive =====
    @media (max-width: 768px) {
      &__controls {
        flex-direction: column;
      }
    }
  }
</style>
