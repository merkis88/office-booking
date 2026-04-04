<script setup>
  import { ref, onMounted } from 'vue';
  import { useUsersStore } from '@/store/users';
  import { useRouter } from 'vue-router';
  import { storeToRefs } from 'pinia';
  import UsersTable from '@/components/UsersTable.vue';
  import UserStatusModal from '@/components/modals/UserStatusModal.vue';
  import AppPagination from '@/components/AppPagination.vue';

  const usersStore = useUsersStore();
  const router = useRouter();

  const isModalOpen = ref(false);
  const selectedUser = ref(null);
  const modalError = ref('');

  const { loading, currentPage, totalPages, paginatedUsers, searchQuery, filters } =
    storeToRefs(usersStore);

  const showFilterDropdown = ref(false);

  function applyFilter(status) {
    usersStore.setFilter('status', status);
    showFilterDropdown.value = false;
  }

  function getFilterLabel() {
    const labels = {
      all: 'Все пользователи',
      active: 'Белый список',
      blocked: 'Чёрный список',
    };

    return labels[filters.value.status] || 'Фильтр';
  }

  onMounted(async () => {
    await usersStore.fetchUsers();
  });

  function goToPage(page) {
    usersStore.setPage(page);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  function toggleUserStatus(user) {
    selectedUser.value = user;
    modalError.value = '';
    isModalOpen.value = true;
  }

  async function handleConfirm({ user, reason, done, fail }) {
    modalError.value = '';

    try {
      await usersStore.updateUserStatus(user, reason);
      done();
    } catch (error) {
      modalError.value = error.message || 'Ошибка';
      fail();
    }
  }
</script>

<template>
  <div class="admin-users">
    <div class="admin-users__container">
      <div class="admin-users__controls">
        <div class="admin-users__control">
          <button class="admin-users__btn" @click="showFilterDropdown = !showFilterDropdown">
            <img src="@/assets/images/icons/filter.svg" alt="Фильтр" />
            <span>{{ getFilterLabel() }}</span>
          </button>

          <transition name="dropdown">
            <div v-if="showFilterDropdown" class="admin-users__dropdown">
              <div class="admin-users__dropdown-item" @click="applyFilter('all')">
                Все пользователи
              </div>
              <div class="admin-users__dropdown-item" @click="applyFilter('active')">
                Белый список
              </div>
              <div class="admin-users__dropdown-item" @click="applyFilter('blocked')">
                Чёрный список
              </div>
            </div>
          </transition>
        </div>

        <div class="admin-users__control">
          <div class="admin-users__search">
            <img
              src="@/assets/images/icons/search.svg"
              alt="Поиск"
              class="admin-users__search-icon"
            />
            <input
              :value="searchQuery"
              @input="usersStore.setSearchQuery($event.target.value)"
              type="text"
              class="admin-users__search-input"
              placeholder="Поиск по фамилии"
            />
          </div>
        </div>
      </div>

      <h1 class="admin-users__title">Пользователи</h1>

      <div class="admin-users__table-wrapper">
        <UsersTable
          :users="paginatedUsers"
          :is-loading="loading"
          @toggle-status="toggleUserStatus"
        />
      </div>

      <AppPagination
        v-if="!loading"
        :current-page="currentPage"
        :total-pages="totalPages"
        @update:current-page="goToPage"
      />
    </div>
  </div>

  <UserStatusModal
    v-model="isModalOpen"
    :user="selectedUser"
    :error="modalError"
    @confirm="handleConfirm"
  />
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;
  @use '@/assets/styles/mixins' as *;

  .admin-users {
    min-height: 100vh;

    &__container {
      @include container;
      max-width: 1200px;
    }

    &__controls {
      display: flex;
      gap: 1rem;
      margin-bottom: 2rem;
      flex-wrap: wrap;
    }

    &__control {
      position: relative;
    }

    &__search {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      padding: 0.75rem 1rem;
      width: 13rem;
      background: $color-btn-profile;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      transition: all 0.2s;

      &:focus-within {
        border-color: $color-text;
        box-shadow: 0 0 0 3px rgba($color-text, 0.1);
      }
    }

    &__search-icon {
      width: 20px;
      height: 20px;
      flex-shrink: 0;
    }

    &__search-input {
      border: none;
      outline: none;
      background: transparent;
      font-size: $text-base;
      color: $color-text;
      font-family: $font-base;
      min-width: 150px;

      &::placeholder {
        color: rgba($color-text, 0.6);
      }
    }

    &__title {
      font-family: $font-title;
      font-size: $text-2xl;
      font-weight: 500;
      color: $color-text;
      text-align: center;
      margin-bottom: 2rem;
    }

    &__table-wrapper {
      margin-bottom: 2rem;
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
    }

    &__dropdown {
      @include admin-dropdown;
      min-width: 200px;
    }

    &__dropdown-item {
      @include admin-dropdown-item;
    }

    @media (max-width: 768px) {
      &__controls {
        flex-direction: column;
      }
    }
  }
</style>
