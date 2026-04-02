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
      <div v-if="isLoading" class="requests-table__loading">
        <div class="spinner"></div>
      </div>

      <div v-else-if="requests.length === 0" class="requests-table__empty">
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
        background: #b2c1cb;
        border-radius: 10px;
      }

      &::-webkit-scrollbar-thumb {
        background: black;
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
      scrollbar-color: $color-footer-bg #b2c1cb;
    }

    &__top-scroll-content {
      width: 3700px;
      height: 1px;
    }

    &__wrapper {
      background: rgba(255, 255, 255, 0.7);
      border-radius: $radius-sm;
      padding: 1.5rem;
    }

    &__loading {
      display: flex;
      justify-content: center;
      padding: 3rem;
    }

    &__empty {
      text-align: center;
      padding: 3rem;
      font-size: $text-lg;
      color: rgba($color-text, 0.6);
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
      width: 100%;
      min-width: 3500px;
      border-collapse: separate;
      border-spacing: 0 0.75rem;

      thead {
        tr {
          th {
            padding: 1rem;
            text-align: center;
            font-size: $text-base;
            font-weight: 500;
            color: $color-text;
            white-space: nowrap;
          }
        }
      }

      tbody {
        tr {
          background: transparent;
          transition: all 0.2s;

          td {
            padding: 0.3rem 1rem;
            text-align: center;
            font-size: $text-base;
            color: $color-text;
            white-space: nowrap;
            border-top: 1px solid $color-text;
            border-bottom: 1px solid $color-text;

            &:first-child {
              border-left: 1px solid $color-text;
              border-top-left-radius: $radius-sm;
              border-bottom-left-radius: $radius-sm;
            }

            &:last-child {
              border-right: 1px solid $color-text;
              border-top-right-radius: $radius-sm;
              border-bottom-right-radius: $radius-sm;
            }
          }
        }
      }
    }

    &__status {
      padding: 0.375rem 0.75rem;
      border-radius: $radius-xs;
      font-size: $text-sm;
      font-weight: 500;
      white-space: nowrap;

      &.status--pending {
        background: #fff3cd;
        color: #856404;
      }

      &.status--in-progress {
        background: #d1ecf1;
        color: #0c5460;
      }

      &.status--completed {
        background: #d4edda;
        color: #155724;
      }

      &.status--rejected {
        background: #f8d7da;
        color: #721c24;
      }
    }

    &__actions {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 0.5rem;
    }

    &__action-btn {
      background: transparent;
      border: none;
      border-radius: $radius-xs;
      cursor: pointer;
      transition: all 0.2s;
      padding: 0.25rem;

      img {
        width: 24px;
        height: 24px;
      }

      &:hover {
        background: rgba($color-text, 0.1);
      }
    }
  }

</style>
