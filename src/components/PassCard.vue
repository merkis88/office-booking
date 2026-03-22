<script setup>
  import { computed, onMounted } from 'vue';
  import { useQrStore } from '@/store/qr';
  import QRCode from 'qrcode';
  import { ref } from 'vue';

  const props = defineProps({
    booking: {
      type: Object,
      required: true,
    },
  });

  defineEmits(['invite-guest', 'invite-employee']);

  const qrStore = useQrStore();
  const qrDataUrl = ref(null);

  const pass = computed(() => qrStore.passes[props.booking.id] || {});
  const isLoading = computed(() => pass.value.loading);
  const hasError = computed(() => !!pass.value.error);
  const isApproved = computed(() => props.booking.status === 'approved' || props.booking.status === 'active');

  const placeTypeLabel = computed(() => {
    const types = {
      office: 'Офис',
      coworking: 'Коворкинг',
      meeting_room: 'Переговорная',
    };
    return types[props.booking.place?.type] || props.booking.place?.type || '';
  });

  const periodLabel = computed(() => {
    const start = new Date(props.booking.start_time).toLocaleDateString('ru-RU');
    const end = new Date(props.booking.end_time).toLocaleDateString('ru-RU');
    return `${start} – ${end}`;
  });

  const parkingLabel = computed(() => {
    if (props.booking.parking_place_id) {
      return `Парковка: №${props.booking.parking_place_id}`;
    }
    return 'Парковка не арендована';
  });

  async function loadQr() {
    if (!isApproved.value) return;

    await qrStore.createUserQr(props.booking.id);

    const qrData = qrStore.passes[props.booking.id]?.qrData;
    if (qrData) {
      try {
        const qrString = typeof qrData === 'string' ? qrData : JSON.stringify(qrData);
        qrDataUrl.value = await QRCode.toDataURL(qrString, {
          width: 200,
          margin: 1,
        });
      } catch {
        qrDataUrl.value = null;
      }
    }
  }

  onMounted(() => {
    loadQr();
  });
</script>

<template>
  <div class="pass-card">
    <div class="pass-card__body">
      <div class="pass-card__qr">
        <!-- Не подтверждено -->
        <div v-if="!isApproved" class="pass-card__qr-placeholder">
          <span class="pass-card__qr-pending-text">
            Пропуск будет доступен после подтверждения бронирования
          </span>
        </div>

        <!-- Загрузка -->
        <div v-else-if="isLoading" class="pass-card__qr-placeholder">
          <span>Загрузка QR...</span>
        </div>

        <!-- Ошибка -->
        <div v-else-if="hasError" class="pass-card__qr-placeholder pass-card__qr-placeholder--error">
          <span>Не удалось загрузить QR-код</span>
          <button class="pass-card__retry-btn" @click="loadQr">Повторить</button>
        </div>

        <!-- QR-код -->
        <img
          v-else-if="qrDataUrl"
          :src="qrDataUrl"
          class="pass-card__qr-image"
          alt="QR-код пропуска"
        />
      </div>

      <div class="pass-card__info">
        <h3 class="pass-card__title">{{ booking.place?.name }}</h3>
        <p class="pass-card__detail">Тип: {{ placeTypeLabel }}</p>
        <p class="pass-card__detail">Период: {{ periodLabel }}</p>
        <p class="pass-card__detail">Тип пропуска: Персональный</p>
        <p class="pass-card__detail">{{ parkingLabel }}</p>
      </div>
    </div>

    <div v-if="isApproved" class="pass-card__actions">
      <button class="pass-card__btn" @click="$emit('invite-guest')">
        Пригласить гостя
      </button>
      <button class="pass-card__btn" @click="$emit('invite-employee')">
        Выдать пропуск сотруднику
      </button>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;

  .pass-card {
    display: flex;
    flex-direction: column;
    gap: 1rem;
    padding: 2rem;
    background: $color-card-bg;
    border: 1px solid $color-border;
    border-radius: $radius-lg;
    margin-bottom: 1.5rem;

    &__body {
      display: flex;
      align-items: center;
      gap: 2rem;
    }

    &__qr {
      flex-shrink: 0;
      width: 8rem;
      height: 8rem;
      background: white;
      border: 2px solid $color-border;
      border-radius: $radius-sm;
      padding: 0.5rem;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    &__qr-image {
      width: 100%;
      height: 100%;
      object-fit: contain;
    }

    &__qr-placeholder {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      text-align: center;
      gap: 0.5rem;
      font-size: $text-sm;
      color: rgba($color-text, 0.6);
      padding: 0.25rem;

      &--error {
        color: #c0392b;
      }
    }

    &__qr-pending-text {
      font-size: 0.75rem;
      line-height: 1.3;
    }

    &__retry-btn {
      padding: 0.25rem 0.75rem;
      border: 1px solid $color-border;
      border-radius: $radius-xs;
      background: $color-input-bg;
      font-size: $text-sm;
      cursor: pointer;
      transition: background 0.2s;

      &:hover {
        background: $color-input-bg-dark;
      }
    }

    &__info {
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
    }

    &__title {
      font-size: $text-lg;
      font-weight: 600;
      color: $color-text;
      margin-bottom: 0.25rem;
    }

    &__detail {
      font-size: $text-base;
      color: $color-text;
      line-height: 1.5;
    }

    &__actions {
      display: flex;
      gap: 1rem;
    }

    &__btn {
      padding: 0.5rem 1.5rem;
      border-radius: $radius-sm;
      font-size: $text-base;
      font-weight: 500;
      transition: all 0.3s ease;
      border: 1px solid $color-border;
      background: $color-input-bg;
      color: $color-text;
      cursor: pointer;

      &:hover {
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        transform: translateY(-2px);
      }

      &:active {
        transform: translateY(0);
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.15);
      }
    }

    @media (max-width: 768px) {
      &__body {
        flex-direction: column;
        text-align: center;
      }

      &__actions {
        flex-direction: column;
      }

      &__btn {
        width: 100%;
      }
    }
  }
</style>
