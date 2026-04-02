<script setup>
  import { reactive, watch } from 'vue';

  const props = defineProps({
    filters: {
      type: Object,
      required: true,
    },
  });

  const emit = defineEmits(['update:filters']);

  const local = reactive({
    status: props.filters.status,
    from: props.filters.from,
    to: props.filters.to,
    sort: props.filters.sort || '-start_time',
  });

  watch(
    () => props.filters,
    (newFilters) => {
      local.status = newFilters.status;
      local.from = newFilters.from;
      local.to = newFilters.to;
      local.sort = newFilters.sort || '-start_time';
    },
    { deep: true },
  );

  function setStatus(value) {
    local.status = value;
    emitFilters();
  }

  function emitFilters() {
    emit('update:filters', {
      status: local.status,
      from: local.from,
      to: local.to,
      sort: local.sort,
    });
  }

  function resetFilters() {
    local.status = null;
    local.from = null;
    local.to = null;
    local.sort = '-start_time';
    emitFilters();
  }
</script>

<template>
  <div class="booking-filters">
    <div class="booking-filters__row">
      <div class="booking-filters__group">
        <span class="booking-filters__label">Статус:</span>
        <div class="booking-filters__chips">
          <button
            class="booking-filters__chip"
            :class="{ 'booking-filters__chip--active': local.status === null }"
            @click="setStatus(null)"
          >
            Все
          </button>
          <button
            class="booking-filters__chip"
            :class="{ 'booking-filters__chip--active': local.status === 'active' }"
            @click="setStatus('active')"
          >
            Активные
          </button>
          <button
            class="booking-filters__chip"
            :class="{ 'booking-filters__chip--active': local.status === 'cancelled' }"
            @click="setStatus('cancelled')"
          >
            Отмененные
          </button>
        </div>
      </div>
    </div>

    <div class="booking-filters__row">
      <div class="booking-filters__group">
        <span class="booking-filters__label">Период:</span>
        <div class="booking-filters__dates">
          <input
            v-model="local.from"
            type="date"
            class="booking-filters__date-input"
            @change="emitFilters"
          />
          <span class="booking-filters__separator">&mdash;</span>
          <input
            v-model="local.to"
            type="date"
            class="booking-filters__date-input"
            @change="emitFilters"
          />
        </div>
      </div>

      <div class="booking-filters__group">
        <span class="booking-filters__label">Сортировка:</span>
        <select
          v-model="local.sort"
          class="booking-filters__select"
          @change="emitFilters"
        >
          <option value="-start_time">Сначала новые</option>
          <option value="start_time">Сначала старые</option>
        </select>
      </div>
    </div>

    <div class="booking-filters__row booking-filters__row--end">
      <button class="booking-filters__reset" @click="resetFilters">
        Сбросить фильтры
      </button>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;

  .booking-filters {
    width: 60%;
    background: $color-card-bg;
    border: 1px solid $color-border;
    border-radius: $radius-sm;
    padding: 1.25rem 1.5rem;
    margin-bottom: 1.5rem;
    display: flex;
    flex-direction: column;
    gap: 1rem;

    &__row {
      display: flex;
      align-items: center;
      gap: 2rem;
      flex-wrap: wrap;

      &--end {
        justify-content: flex-end;
      }
    }

    &__group {
      display: flex;
      align-items: center;
      gap: 0.75rem;
    }

    &__label {
      font-size: $text-base;
      font-weight: 500;
      color: $color-text;
      white-space: nowrap;
    }

    &__chips {
      display: flex;
      gap: 0.5rem;
    }

    &__chip {
      padding: 0.375rem 1rem;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      background: $color-input-bg;
      font-size: $text-sm;
      cursor: pointer;
      transition: all 0.2s;

      &:hover {
        background: $color-input-bg-dark;
      }

      &--active {
        background: $color-header-bg;
        font-weight: 600;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.15);
      }
    }

    &__dates {
      display: flex;
      align-items: center;
      gap: 0.5rem;
    }

    &__date-input {
      padding: 0.375rem 0.75rem;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      background: $color-input-bg;
      font-size: $text-sm;
      outline: none;
      transition: $transition-fast;

      &:focus {
        background: $color-input-bg-dark;
      }
    }

    &__separator {
      color: $color-text;
    }

    &__select {
      padding: 0.375rem 0.75rem;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      background: $color-input-bg;
      font-size: $text-sm;
      outline: none;
      cursor: pointer;
      transition: $transition-fast;

      &:focus {
        background: $color-input-bg-dark;
      }
    }

    &__reset {
      padding: 0.375rem 1rem;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      background: $color-input-bg;
      font-size: $text-sm;
      cursor: pointer;
      transition: all 0.2s;

      &:hover {
        background: $color-input-bg-dark;
      }
    }

    @media (max-width: 768px) {
      width: 100%;

      &__row {
        flex-direction: column;
        align-items: flex-start;
        gap: 0.75rem;
      }

      &__dates {
        flex-wrap: wrap;
      }
    }
  }
</style>
