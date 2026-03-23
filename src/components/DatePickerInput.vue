<script setup>
  import { ref, onMounted, watch, onBeforeUnmount } from 'vue';
  import flatpickr from 'flatpickr';
  import { Russian } from 'flatpickr/dist/l10n/ru.js';
  import 'flatpickr/dist/flatpickr.css';

  const props = defineProps({
    modelValue: {
      type: String,
      default: '',
    },
    placeholder: {
      type: String,
      default: '',
    },
  });

  const emit = defineEmits(['update:modelValue']);

  const dateInput = ref(null);
  const datePickerWrapper = ref(null);
  let flatpickrInstance = null;

  const formattedDate = ref(props.placeholder);

  onMounted(() => {
    flatpickrInstance = flatpickr(dateInput.value, {
      locale: Russian,
      dateFormat: 'Y-m-d',
      defaultDate: props.modelValue || null,
      minDate: 'today',
      onChange: (selectedDates, dateStr) => {
        emit('update:modelValue', dateStr);

        if (selectedDates.length > 0) {
          const date = selectedDates[0];
          const day = date.getDate();
          const month = date.toLocaleDateString('ru-RU', { month: 'long' });
          formattedDate.value = `${day} ${month}`;
        } else {
          formattedDate.value = props.placeholder;
        }
      },
    });
  });

  onBeforeUnmount(() => {
    if (flatpickrInstance) {
      flatpickrInstance.destroy();
    }
  });

  watch(
    () => props.modelValue,
    (newValue) => {
      if (!flatpickrInstance) return;

      if (newValue) {
        flatpickrInstance.setDate(newValue, false);
      } else {
        flatpickrInstance.clear();
        formattedDate.value = '';
      }
    },
  );

  function openCalendar() {
    if (flatpickrInstance) {
      flatpickrInstance.open();
    }
  }
</script>

<template>
  <div class="date-picker-custom" ref="datePickerWrapper">
    <input ref="dateInput" type="text" class="date-picker-custom__input" />
    <div class="date-picker-custom__display" @click="openCalendar">
      <span v-if="!formattedDate" class="date-picker-custom__value-placeholder">Выберите дату</span>
      <span v-if="formattedDate" class="date-picker-custom__value">{{ formattedDate }}</span>
      <img src="/calendar.svg" alt="" class="date-picker-custom__icon" />
    </div>
  </div>
</template>

<style lang="scss">
  @use '@/assets/styles/variables' as *;

  .date-picker-custom {
    position: relative;

    &__input {
      position: absolute;
      opacity: 0;
      width: 1px;
      height: 1px;
      pointer-events: none;
    }

    &__display {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      padding: 0.875rem 3rem 0.875rem 1.25rem;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      background: $color-btn-profile;
      cursor: pointer;
      width: 30rem;
      transition: all 0.2s;
      position: relative;
    }

    &__value {
      font-size: $text-base;
      color: $color-text;
      flex: 1;
    }

    &__value-placeholder {
      opacity: 40%;
    }

    &__icon {
      position: absolute;
      right: 1rem;
      width: 1.5rem;
      height: 1.5rem;
      flex-shrink: 0;
      transition: transform 0.2s;
    }

    &:has(.flatpickr-calendar.open) &__display {
      border-color: $color-text;
      box-shadow: 0 0 0 3px rgba($color-text, 0.1);
    }
  }

  .flatpickr-calendar {
    background: $color-card-bg;
    border: 1px solid $color-border;
    border-radius: $radius-lg;
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
    padding: 0.4rem;
    margin-top: 0.5rem;
    font-family: $font-base;

    &.arrowTop:before,
    &.arrowTop:after {
      display: none;
    }

    &.open {
      z-index: 1000;
    }

    .flatpickr-months {
      padding: 0.5rem;
      margin-bottom: 0.5rem;
      height: auto;

      .flatpickr-month {
        height: auto;
        display: flex;
        align-items: center;
        justify-content: space-between;
        width: 100%;
      }

      .flatpickr-prev-month,
      .flatpickr-next-month {
        position: relative !important;
        padding: 0.5rem;
        display: flex !important;
        align-items: center;
        justify-content: center;
        width: 2rem;
        height: 2rem;
        fill: $color-text;
        border-radius: $radius-xs;
        transition: all 0.2s;
        background: transparent;

        &:hover {
          background: $color-input-bg;
          fill: $color-text;
        }

        svg {
          width: 1rem;
          height: 1rem;
        }
      }

      .flatpickr-prev-month {
        left: 0 !important;
        top: 0 !important;
      }

      .flatpickr-next-month {
        right: 0 !important;
        top: 0 !important;
      }

      .flatpickr-current-month {
        position: static !important;
        padding: 0.5rem;
        flex: 1;
        display: flex !important;
        align-items: center;
        justify-content: center;
        gap: 0.5rem;
        height: auto;
        left: auto !important;
        transform: none !important;

        .flatpickr-monthDropdown-months {
          font-size: $text-lg;
          font-weight: 600;
          color: $color-text;
          background: transparent;
          border: none;
          margin: 0;
          padding: 0.25rem 0.5rem;
          border-radius: $radius-xs;
          appearance: none;
          cursor: pointer;
          font-family: $font-base;

          &:hover {
            background: rgba($color-text, 0.05);
          }

          option {
            background: $color-card-bg;
            color: $color-text;
          }
        }

        .numInputWrapper {
          width: 80px;

          input.cur-year {
            font-size: $text-lg;
            font-weight: 600;
            color: $color-text;
            background: transparent;
            border: none;
            padding: 0.25rem 0.5rem;
            border-radius: $radius-xs;
            font-family: $font-base;

            &:hover {
              background: rgba($color-text, 0.05);
            }
          }

          .arrowUp,
          .arrowDown {
            display: none;
          }
        }
      }
    }

    .flatpickr-weekdays {
      margin-top: 0.5rem;
      height: auto;
    }

    .flatpickr-weekday {
      color: rgba($color-text, 0.6);
      font-size: $text-sm;
      font-weight: 600;
      padding: 0.5rem 0;
      line-height: 1;
    }

    .flatpickr-days {
      width: 100%;
    }

    .dayContainer {
      width: 100%;
      min-width: unset !important;
      max-width: unset !important;
      display: grid !important;
      grid-template-columns: repeat(7, 1fr) !important;
    }

    .flatpickr-day {
      color: $color-text;
      border: none;
      border-radius: $radius-xs;
      font-size: $text-base;
      font-weight: 500;
      height: 2.5rem;
      line-height: 2.5rem;
      max-width: 2.5rem;
      margin: 2px;
      transition: all 0.2s;

      &:hover {
        background: rgba($color-text, 0.1);
        border-color: rgba($color-text, 0.1);
      }

      &.today {
        border: 2px solid $color-text;
        font-weight: 700;

        &:hover {
          background: rgba($color-text, 0.1);
        }
      }

      &.selected {
        background: $color-text;
        color: $color-bg;
        font-weight: 700;
      }

      &.prevMonthDay,
      &.nextMonthDay {
        color: rgba($color-text, 0.3);
      }

      &.flatpickr-disabled {
        color: rgba($color-text, 0.2);
        cursor: not-allowed;
        text-decoration: line-through;

        &:hover {
          background: transparent;
          border-color: transparent;
        }
      }
    }

    .flatpickr-time {
      display: none;
    }
  }
</style>
