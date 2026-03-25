<script setup>
  import { computed, ref } from 'vue';
  import { useAuthStore } from '@/store/auth';
  import placeholder from '@/assets/images/photos/placeholder.jpg';

  const authStore = useAuthStore();

  const props = defineProps({
    place: {
      type: Object,
      required: true,
    },
  });

  const emit = defineEmits(['select-slot', 'delete-place', 'archive-place']);

  const slotsPerPage = 2;
  const slotPage = ref(0);

  const mergedSlots = computed(() => {
    const slots = props.place.available_slots || [];

    if (!slots.length) return [];

    const sorted = [...slots].sort((a, b) => a.start.localeCompare(b.start));

    const result = [];
    let current = { start: sorted[0].start, end: sorted[0].end };

    for (let i = 1; i < sorted.length; i++) {
      const slot = sorted[i];

      if (slot.start === current.end) {
        current.end = slot.end;
      } else {
        result.push({ ...current });
        current = { start: slot.start, end: slot.end };
      }
    }

    result.push({ ...current });

    return result.map((s) => ({
      ...s,
      time: `${s.start} - ${s.end}`,
    }));
  });

  const totalPages = computed(() => Math.ceil(mergedSlots.value.length / slotsPerPage));

  const paginatedSlots = computed(() => {
    const start = slotPage.value * slotsPerPage;
    return mergedSlots.value.slice(start, start + slotsPerPage);
  });

  function nextSlots() {
    if (slotPage.value < totalPages.value - 1) {
      slotPage.value++;
    }
  }

  function prevSlots() {
    if (slotPage.value > 0) {
      slotPage.value--;
    }
  }

  function selectSlot(range) {
    emit('select-slot', {
      place: props.place,
      range,
      availableSlots: props.place.available_slots,
    });
  }

  const placeTypeLabel = computed(() => {
    const types = {
      office: 'Аренда офиса',
      coworking: 'Аренда коворкинга',
      meeting: 'Аренда переговорной',
    };
    return types[props.place.type] || props.place.type;
  });

  function handleArchive() {
    emit('archive-place', props.place.id);
  }
</script>

<template>
  <div class="place-card">
    <div class="place-card__main">
      <div class="place-card__image-wrapper">
        <img
          :src="place.photo_url"
          :alt="place.name"
          class="place-card__image"
          @error="
            (e) => {
              e.target.onerror = null;
              e.target.src = placeholder;
            }
          "
        />
      </div>

      <div class="place-card__content">
        <h3 class="place-card__title">{{ placeTypeLabel }}</h3>
        <p class="place-card__number">Кабинет №{{ place.number_place }}</p>
        <p class="place-card__price">Стоимость: {{ place.price }}₽</p>
        <p class="place-card__capacity">Вместимость: {{ place.capacity }} человек</p>
      </div>

      <div class="place-card__actions">
        <button class="place-card__favorite" aria-label="Добавить в избранное">
          <img src="@/assets/images/icons/heart-empty.svg" alt="" />
        </button>
        <button
          v-if="authStore.isAdmin"
          class="place-card__archive"
          @click="handleArchive"
          aria-label="Отправить в архив"
        >
          <img src="@/assets/images/icons/archive.svg" alt="Удалить" />
        </button>
      </div>
    </div>

    <div class="place-card__slots">
      <button
        v-if="mergedSlots.length > 2"
        class="place-card__slot-arrow"
        @click="prevSlots"
        :disabled="slotPage === 0"
      >
        <img src="@/assets/images/icons/arrow-left.svg" alt="&lt;" />
      </button>

      <div class="place-card__slot-list">
        <button
          v-for="slot in paginatedSlots"
          :key="slot.start"
          class="place-card__slot-btn"
          @click="selectSlot(slot)"
        >
          <span v-if="mergedSlots.length === 1">Доступное время: {{ slot.time }}</span>

          <span v-else>
            {{ slot.time }}
          </span>
        </button>
      </div>

      <button
        v-if="mergedSlots.length > 2"
        class="place-card__slot-arrow"
        @click="nextSlots"
        :disabled="slotPage >= totalPages - 1"
      >
        <img src="@/assets/images/icons/arrow-right.svg" alt="&gt;" />
      </button>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;

  .place-card {
    overflow: hidden;
    display: flex;
    flex-direction: column;
    align-items: center;
    font-family: $font-base;

    &__main {
      background: $color-btn-profile;
      border: 1px solid $color-border;
      border-radius: $radius-lg;
      display: flex;
      gap: 1rem;
      padding: 1.5rem;
      position: relative;
      transition: all 0.3s;
    }

    &__image-wrapper {
      position: relative;
      width: 280px;
      height: 280px;
      flex-shrink: 0;
      overflow: hidden;
      border-radius: $radius-lg;
    }

    &__image {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    &__content {
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 1rem;
      justify-content: center;
      align-items: stretch;
    }

    &__title {
      font-size: $text-xl;
      font-weight: 600;
      color: $color-text;
      margin: 0;
    }

    &__archive {
      position: absolute;
      bottom: 0.75rem;
      right: 0.75rem;
      width: 2.5rem;
      height: 2.5rem;
      border: none;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      transition: all 0.2s;

      &:hover {
        transform: scale(1.1);
      }

      &:active {
        transform: scale(0.95);
      }

      img {
        width: 1.5rem;
        height: 1.5rem;
      }
    }

    &__number {
      font-size: $text-lg;
      color: $color-text;
      margin: 0;
    }

    &__price {
      font-size: $text-lg;
      color: $color-text;
      margin: 0;
    }

    &__capacity {
      font-size: $text-lg;
      color: $color-text;
      margin: 0;
    }

    &__actions {
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      align-items: center;

      img {
        width: 2rem;
        height: 2rem;
      }
    }

    &__favorite {
      top: 2rem;
      right: 2rem;
      width: 3rem;
      height: 3rem;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      transition: all 0.2s;
      color: $color-text;

      img {
        width: 2.5rem;
        height: 2.5rem;
      }
    }

    &__time {
      padding: 0.3rem 10rem;
      background: $color-btn-profile;
      border: 1px solid $color-border;
      border-radius: $radius-xxs;
      font-size: $text-xl;
      font-weight: 400;
      text-align: center;
      color: $color-text;
      margin-top: 10px;
      max-width: 90rem;
    }

    &__slots {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 10px;
      margin-top: 12px;
    }

    &__slot-list {
      display: flex;
      gap: 10px;
    }

    &__slot-btn {
      padding: 8px 14px;
      border: 1px solid $color-border;
      border-radius: $radius-xs;
      background: $color-input-bg;
      cursor: pointer;
      font-size: $text-base;
      transition: 0.2s;

      &:hover {
        background: $color-input-bg-dark;
      }
    }

    &__slot-arrow {
      background: none;
      border: none;
      padding: 0;
      cursor: pointer;

      img {
        width: 28px;
        height: 28px;
      }

      &:disabled {
        opacity: 0.4;
        cursor: not-allowed;
      }
    }

    @media (max-width: 768px) {
      &__main {
        flex-direction: column;
        padding: 1rem;
      }

      &__image-wrapper {
        width: 100%;
        height: 200px;
      }

      &__favorite {
        top: 1.5rem;
        right: 1.5rem;
        width: 2.5rem;
        height: 2.5rem;

        svg {
          width: 1.25rem;
          height: 1.25rem;
        }
      }

      &__time {
        font-size: $text-base;
      }
    }
  }
</style>
