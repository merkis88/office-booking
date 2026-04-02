<script setup>
  import { ref, defineProps, defineEmits } from 'vue';

  const props = defineProps({
    requests: {
      type: Array,
      required: true,
    },
    isLoading: {
      type: Boolean,
      default: false,
    },
    showEditButton: {
      type: Boolean,
      default: true,
    },
  });

  const emit = defineEmits(['edit-status']);

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

  function getStatusClass(status) {
    const statusClasses = {
      pending: 'status--pending',
      in_progress: 'status--in-progress',
      completed: 'status--completed',
      rejected: 'status--rejected',
    };
    return statusClasses[status] || '';
  }

  function handleEditStatus(request) {
    emit('edit-status', request);
  }
</script>

<template>
  <div class="requests-table">
    <!-- Верхний скроллбар -->
    <div
      v-if="!isLoading && requests.length > 0"
      ref="topScrollRef"
      class="requests-table__top-scroll"
      @scroll="syncScrollFromTop"
    >
      <div class="requests-table__top-scroll-content"></div>
    </div>

    <!-- Таблица -->
    <div class="requests-table__wrapper">
      <div v-if="isLoading" class="loading">
        <div class="spinner"></div>
      </div>

      <div v-else-if="requests.length === 0" class="empty-state">
        <p>Заявок пока нет</p>
      </div>

      <div
        v-else
        ref="tableScrollRef"
        class="requests-table__scroll-container"
        @scroll="syncScrollFromTable"
      >
        <table class="requests-table__table">
          <thead>
            <tr>
              <th>Тип заявки</th>
              <th>Фамилия</th>
              <th>Имя</th>
              <th>Отчество</th>
              <th>Email</th>
              <th>Тип помещения</th>
              <th>Кабинет №</th>
              <th>Дата бронирования</th>
              <th>Время бронирования</th>
              <th>Дата заявки</th>
              <th>Время заявки</th>
              <th>Комментарий</th>
              <th>Статус</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="request in requests" :key="request.id" class="requests-table__row">
              <td>{{ request.service_type?.name || '—' }}</td>
              <td>{{ request.user?.last_name || '—' }}</td>
              <td>{{ request.user?.first_name || '—' }}</td>
              <td>{{ request.user?.patronymic || '—' }}</td>
              <td>{{ request.user?.email || '—' }}</td>
              <td>{{ request.booking?.place?.type_name || '—' }}</td>
              <td>№{{ request.booking?.place?.number_place || '—' }}</td>
              <td>{{ request.booking?.start_time?.split(' ')[0] || '—' }}</td>
              <td>
                {{ request.booking?.start_time?.split(' ')[1] || '—' }} -
                {{ request.booking?.end_time?.split(' ')[1] || '—' }}
              </td>
              <td>{{ request.service_date || '—' }}</td>
              <td>{{ request.service_time || '—' }}</td>
              <td>{{ request.comment || '—' }}</td>
              <td>
                <div class="requests-table__actions">
                  <span class="requests-table__status" :class="getStatusClass(request.status)">
                    {{ request.status_name || '—' }}
                  </span>
                  <button
                    v-if="
                      showEditButton &&
                      request.status !== 'rejected' &&
                      request.status !== 'completed'
                    "
                    class="requests-table__action-btn"
                    @click.stop="handleEditStatus(request)"
                    aria-label="Изменить статус"
                  >
                    <img src="@/assets/images/icons/edit.svg" alt="Изменить статус" />
                  </button>
                </div>
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
  @use '@/assets/styles/mixins' as *;

  .requests-table {
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
      width: 3700px;
      height: 1px;
    }

    &__wrapper {
      background: $table-bg;
      border-radius: $table-radius;
      padding: 1.5rem;
    }

    &__scroll-container {
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
      min-width: 3500px;
    }

    &__status {
      padding: 0.375rem 0.75rem;
      border-radius: $radius-xs;
      font-size: $text-sm;
      font-weight: 500;
      white-space: nowrap;

      &.status--pending {
        background: $color-status-pending;
        color: $color-status-pending-text;
      }

      &.status--in-progress {
        background: $color-status-in-progress;
        color: $color-status-in-progress-text;
      }

      &.status--completed {
        background: $color-status-active;
        color: $color-status-active-text;
      }

      &.status--rejected {
        background: $color-status-blocked;
        color: $color-status-blocked-text;
      }
    }

    &__actions {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 0.5rem;
    }

    &__action-btn {
      @include icon-btn;
    }
  }

</style>
