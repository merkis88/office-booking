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
  });

  const emit = defineEmits(['update:modelValue']);

  const dateInput = ref(null);
  const datePickerWrapper = ref(null);
  let flatpickrInstance = null;

  const formattedDate = ref('Выберите дату');

  function applyGridStyles(instance) {
    const container = instance.calendarContainer;

    const weekdayContainer = container.querySelector('.flatpickr-weekdaycontainer');
    if (weekdayContainer) {
      weekdayContainer.style.display = 'grid';
      weekdayContainer.style.gridTemplateColumns = 'repeat(7, 1fr)';
      weekdayContainer.style.width = '100%';
    }

    const dayContainer = container.querySelector('.dayContainer');
    if (dayContainer) {
      dayContainer.style.display = 'grid';
      dayContainer.style.gridTemplateColumns = 'repeat(7, 1fr)';
      dayContainer.style.width = '100%';
      dayContainer.style.minWidth = '100%';
      dayContainer.style.maxWidth = '100%';
      dayContainer.style.gap = '2px';
    }

    const days = container.querySelectorAll('.flatpickr-days');
    days.forEach((el) => {
      el.style.width = '100%';
    });
  }

  onMounted(() => {
    flatpickrInstance = flatpickr(dateInput.value, {
      locale: Russian,
      dateFormat: 'Y-m-d',
      defaultDate: props.modelValue || null,
      minDate: 'today',
      onReady: (selectedDates, dateStr, instance) => {
        applyGridStyles(instance);
      },
      onMonthChange: (selectedDates, dateStr, instance) => {
        setTimeout(() => applyGridStyles(instance), 0);
      },
      onChange: (selectedDates, dateStr) => {
        emit('update:modelValue', dateStr);

        if (selectedDates.length > 0) {
          const date = selectedDates[0];
          const day = date.getDate();
          const month = date.toLocaleDateString('ru-RU', { month: 'long' });
          formattedDate.value = `${day} ${month}`;
        } else {
          formattedDate.value = 'Выберите дату';
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
      if (flatpickrInstance && newValue) {
        flatpickrInstance.setDate(newValue, false);
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
  <div class="date-picker" ref="datePickerWrapper">
    <input ref="dateInput" type="text" class="date-picker__input" />
    <div class="date-picker__display" @click="openCalendar">
      <span class="date-picker__value">{{ formattedDate }}</span>
      <img src="/arrow-square-down.svg" alt="" class="date-picker__icon" />
    </div>
  </div>
</template>

<style lang="scss">
  @use '@/assets/styles/variables' as *;

  .date-picker {
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
      padding: 0.75rem 1rem;
      cursor: pointer;
      min-width: 200px;
      transition: all 0.2s;
      justify-content: center;
    }

    &__value {
      font-size: $text-2xl;
      color: $color-text;
      flex: 1;
    }

    &__icon {
      flex-shrink: 0;
      transition: transform 0.2s;
    }

    &:has(.flatpickr-calendar.open) &__icon {
      transform: rotate(180deg);
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
    padding: 1rem;
    margin-top: 0.5rem;
    font-family: $font-base;
    width: 400px !important;

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

      .flatpickr-prev-month {
        position: relative !important;
        left: 0 !important;
        top: 0 !important;
        padding: 0.5rem;
        display: flex !important;
        align-items: center;
        justify-content: center;
        width: 2rem;
        height: 2rem;
        fill: $color-text;
        border-radius: $radius-xs;
        transition: all 0.2s;

        &:hover {
          background: $color-input-bg;
          fill: $color-text;
        }

        svg {
          width: 1rem;
          height: 1rem;
        }
      }

      .flatpickr-next-month {
        position: relative !important;
        right: 0 !important;
        top: 0 !important;
        padding: 0.5rem;
        display: flex !important;
        align-items: center;
        justify-content: center;
        width: 2rem;
        height: 2rem;
        fill: $color-text;
        border-radius: $radius-xs;
        transition: all 0.2s;

        &:hover {
          background: rgba($color-text, 0.1);
        }

        svg {
          width: 1rem;
          height: 1rem;
        }
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
      height: auto;
      margin-top: 0.5rem;
      margin-bottom: 0.25rem;
    }

    .flatpickr-weekdaycontainer {
      display: grid !important;
      grid-template-columns: repeat(7, 1fr) !important;
      width: 100% !important;
    }

    .flatpickr-weekday {
      color: rgba($color-text, 0.5);
      font-size: $text-sm;
      font-weight: 600;
      padding: 0.4rem 0;
      line-height: 1;
      text-align: center;
      float: none !important;
    }

    .flatpickr-days {
      width: 100% !important;
    }

    .dayContainer {
      display: grid !important;
      grid-template-columns: repeat(7, 2fr) !important;
      width: 100% !important;
      min-width: 100% !important;
      max-width: 100% !important;
      padding: 1rem !important;
      gap: 19px !important;
      justify-content: center !important;
    }

    .flatpickr-day {
      display: flex !important;
      justify-content: center !important;
      align-items: center !important;
      color: $color-text;
      border: none;
      border-radius: $radius-xs;
      font-size: $text-base !important;
      font-weight: 500;
      height: 2.25rem;
      line-height: 2.25rem;
      max-width: 100% !important;
      width: 100% !important;
      padding: 0.5rem !important;
      margin: 0 !important;
      text-align: center;
      transition: all 0.2s;

      &:hover {
        background: rgba($color-text, 0.1);
        border-color: transparent;
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
        color: #ffffff;
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
