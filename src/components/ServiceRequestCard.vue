<script setup>
  import { ref } from 'vue';
  import { useAuthStore } from '@/store/auth';

  const props = defineProps({
    service: {
      type: Object,
      required: true,
    },
  });

  const authStore = useAuthStore();
  const isDownloading = ref(false);

  function formatCreatedDate(isoDateStr) {
    if (!isoDateStr) return '';

    const datePart = isoDateStr.split('T')[0];
    const parts = datePart.split('-');

    return `${parts}`;
  }

  function formatTime(timeStr) {
    if (!timeStr) return '';
    const parts = timeStr.split(':');
    const hours = parts[0];
    const minutes = parts[1];
    const endHours = (parseInt(hours) + 1).toString().padStart(2, '0');
    return `${hours}:${minutes} - ${endHours}:${minutes}`;
  }

  const serviceTypeName = props.service.service_type?.name || 'Не указан';

  const placeType = props.service.place?.type || '';

  const placeTypeLabel =
    {
      office: 'офис',
      coworking: 'коворкинг',
      meeting_room: 'переговорная',
    }[placeType] || 'помещение';

  const placeNumber =
    props.service.booking?.place?.number_place ||
    props.service.place?.number_place ||
    props.service.place?.id ||
    '';

  async function downloadPDF() {
    if (isDownloading.value) return;

    isDownloading.value = true;

    try {
      const response = await fetch(`/api/services/${props.service.id}/export`, {
        method: 'GET',
        headers: {
          Authorization: `Bearer ${authStore.token}`,
          Accept: 'application/pdf',
        },
      });

      if (!response.ok) {
        if (response.status === 401) {
          throw new Error('Не авторизован');
        } else if (response.status === 403) {
          throw new Error('Доступ запрещен');
        } else if (response.status === 422) {
          throw new Error('Ошибка при экспорте');
        } else {
          throw new Error('Не удалось скачать PDF');
        }
      }

      const blob = await response.blob();

      const url = window.URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = `Заявка_${props.service.id}.pdf`;

      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      window.URL.revokeObjectURL(url);

    } catch (error) {
      console.error('Ошибка скачивания PDF:', error);
    } finally {
      isDownloading.value = false;
    }
  }
</script>

<template>
  <div class="service-card">
    <div class="service-card__header">
      <h3 class="service-card__title">
        Заявка №{{ service.id }}: {{ formatCreatedDate(service.created_at) }}
      </h3>
    </div>

    <div class="service-card__body">
      <div class="service-card__info">
        <div class="service-card__row">
          <span class="service-card__label">Тип заявки:</span>
          <span class="service-card__value">{{ serviceTypeName }}</span>
        </div>

        <div class="service-card__row">
          <span class="service-card__label">Тип помещения:</span>
          <span class="service-card__value">{{ placeTypeLabel }} Кабинет №{{ placeNumber }}</span>
        </div>

        <div class="service-card__row">
          <span class="service-card__label">Время работы:</span>
          <span class="service-card__value">{{ formatTime(service.service_time) }}</span>
        </div>

        <div v-if="service.comment" class="service-card__row">
          <span class="service-card__label">Комментарий:</span>
          <span class="service-card__value">{{ service.comment }}</span>
        </div>
      </div>

      <button
        class="service-card__download"
        :class="{ 'service-card__download--loading': isDownloading }"
        aria-label="Скачать PDF"
        @click="downloadPDF"
        :title="isDownloading ? 'Загрузка...' : 'Скачать PDF'"
        :disabled="isDownloading"
      >
        <div v-if="isDownloading" class="service-card__spinner"></div>
        <img v-else src="/download.svg" alt="Скачать" />
      </button>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;

  .service-card {
    transition: all 0.2s;

    &__header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 1rem;
    }

    &__title {
      font-size: $text-base;
      color: $color-text;
      margin: 0;
    }

    &__body {
      display: flex;
      flex-direction: row;
      align-items: center;
      gap: 1rem;
      background: $color-btn-profile;
      border: 1px solid $color-border;
      border-radius: $radius-xs;
      padding: 1rem;
      height: 12rem;
      width: 25rem;
    }

    &__info {
      display: flex;
      flex-direction: column;
      gap: 1rem;
      flex: 1;
    }

    &__row {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      white-space: nowrap;
    }

    &__label {
      font-size: $text-sm;
      font-weight: 500;
    }

    &__value {
      font-size: $text-base;
      color: $color-text;
    }

    &__download {
      align-self: flex-end;
      cursor: pointer;
      transition: all 0.2s;
      background: transparent;
      border: none;
      padding: 0;
      position: relative;
      width: 3rem;
      height: 3rem;
      display: flex;
      align-items: center;
      justify-content: center;

      &:hover:not(:disabled) {
        transform: scale(1.1);
      }

      &:active:not(:disabled) {
        transform: scale(0.95);
      }

      &:disabled {
        cursor: not-allowed;
        opacity: 0.6;
      }

      &--loading {
        animation: pulse 1.5s ease-in-out infinite;
      }

      img {
        width: 3rem;
        height: 3rem;
        transition: opacity 0.2s;
      }
    }

    &__spinner {
      width: 2rem;
      height: 2rem;
      border: 3px solid rgba($color-text, 0.2);
      border-top-color: $color-text;
      border-radius: 50%;
      animation: spin 0.8s linear infinite;
    }
  }

  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }

  @keyframes pulse {
    0%,
    100% {
      opacity: 1;
    }
    50% {
      opacity: 0.5;
    }
  }
</style>
