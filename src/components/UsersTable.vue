<script setup>
  import { ref } from 'vue';

  const props = defineProps({
    users: {
      type: Array,
      required: true,
      default: () => [],
    },
    isLoading: {
      type: Boolean,
      default: false,
    },
  });

  const emit = defineEmits(['toggle-status']);

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

  function normalizeStatus(isBlocked) {
    return isBlocked ? 'blacklist' : 'whitelist';
  }

  function getStatusClass(isBlocked) {
    return normalizeStatus(isBlocked) === 'blacklist' ? 'status--blacklist' : 'status--whitelist';
  }

  function getStatusLabel(isBlocked) {
    return normalizeStatus(isBlocked) === 'blacklist' ? 'Чёрный список' : 'Белый список';
  }

  function getToggleLabel(isBlocked) {
    return normalizeStatus(isBlocked) === 'blacklist'
      ? 'Перевести в белый список'
      : 'Перевести в чёрный список';
  }

  function handleToggleStatus(user) {
    emit('toggle-status', user);
  }

  function isAdmin(user) {
    return user?.role?.role_name === 'admin';
  }

  function getActionIcon(isBlocked) {
    return isBlocked
      ? new URL('@/assets/images/icons/unblock-user.svg', import.meta.url).href
      : new URL('@/assets/images/icons/block-user.svg', import.meta.url).href;
  }
</script>

<template>
  <div class="users-table">
    <div
      v-if="!isLoading && (users?.length ?? 0) > 0"
      ref="topScrollRef"
      class="users-table__top-scroll"
      @scroll="syncScrollFromTop"
    >
      <div class="users-table__top-scroll-content"></div>
    </div>

    <div class="users-table__wrapper">
      <div v-if="isLoading" class="users-table__loading">
        <div class="spinner"></div>
      </div>

      <div v-else-if="!(users?.length ?? 0)" class="users-table__empty">
        <p>Пользователи не найдены</p>
      </div>

      <div v-else ref="tableScrollRef" class="users-table__scroll" @scroll="syncScrollFromTable">
        <table class="users-table__table">
          <thead>
            <tr>
              <th>Фамилия</th>
              <th>Имя</th>
              <th>Отчество</th>
              <th>Почта</th>
              <th>Статус</th>
              <th>Действие</th>
            </tr>
          </thead>

          <tbody>
            <tr v-for="user in users" :key="user.id">
              <td>{{ user.last_name || '—' }}</td>
              <td>{{ user.first_name || '—' }}</td>
              <td>{{ user.patronymic || '—' }}</td>
              <td>{{ user.email || '—' }}</td>
              <td>
                <span class="users-table__status" :class="getStatusClass(user.is_blocked)">
                  {{ getStatusLabel(user.is_blocked) }}
                </span>
              </td>
              <td>
                <button
                  class="users-table__action-btn"
                  :class="{ 'users-table__action-btn--disabled': isAdmin(user) }"
                  :disabled="isAdmin(user)"
                  @click.stop="!isAdmin(user) && handleToggleStatus(user)"
                  :aria-label="
                    isAdmin(user)
                      ? 'Нельзя изменить статус администратора'
                      : getToggleLabel(user.is_blocked)
                  "
                  :title="
                    isAdmin(user)
                      ? 'Нельзя изменить статус администратора'
                      : getToggleLabel(user.is_blocked)
                  "
                >
                  <img :src="getActionIcon(user.is_blocked)" alt="Сменить статус" />
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;

  .users-table {
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
      width: 1000px;
      height: 1px;
    }

    &__wrapper {
      background: $table-bg;
      border-radius: $radius-sm;
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

    &__status {
      padding: 0.375rem 0.75rem;
      border-radius: $radius-xs;
      font-size: $text-sm;
      font-weight: 500;
      white-space: nowrap;

      &.status--whitelist {
        background: $color-status-active;
        color: $color-status-active-text;
      }

      &.status--blacklist {
        background: $color-status-blocked;
        color: $color-status-blocked-text;
      }
    }

    &__action-btn {
      background: transparent;
      border: none;
      border-radius: $radius-xs;
      cursor: pointer;
      transition: all 0.2s;
      padding: 0.25rem;
      display: inline-flex;
      align-items: center;
      justify-content: center;

      img {
        width: 24px;
        height: 24px;
      }

      &:hover {
        background: rgba($color-text, 0.1);
      }

      &--disabled {
        opacity: 0.5;
        cursor: not-allowed;
      }
    }
  }

</style>
