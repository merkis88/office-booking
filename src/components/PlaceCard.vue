<script setup>
  import { computed, ref } from 'vue';

  const props = defineProps({
    place: {
      type: Object,
      required: true,
    },
  });

  const emit = defineEmits(['select-slot']);

  const slotsPerPage = 2;
  const startIndex = ref(0);

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

  const paginatedSlots = computed(() => {
    return mergedSlots.value.slice(startIndex.value, startIndex.value + slotsPerPage);
  });

  function nextSlots() {
    if (startIndex.value < mergedSlots.value.length - slotsPerPage) {
      startIndex.value++;
    }
  }

  function prevSlots() {
    if (startIndex.value > 0) {
      startIndex.value--;
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
</script>

<template>
  <div class="place-card">
    <div class="place-card__main">
      <div class="place-card__image-wrapper">
        <img :src="place.photo_url" :alt="place.name" class="place-card__image" />
      </div>

      <div class="place-card__content">
        <h3 class="place-card__title">{{ placeTypeLabel }}</h3>
        <p class="place-card__number">Кабинет №{{ place.number_place }}</p>
        <p class="place-card__price">Стоимость: {{ Math.round(place.price) }} р/час</p>
        <p class="place-card__capacity">Вместимость: {{ place.capacity }} человек</p>
      </div>

      <button class="place-card__favorite" aria-label="Добавить в избранное">
        <img src="/heart-empty.svg" alt="" />
      </button>
    </div>

    <div class="place-card__slots">
      <button
        v-if="mergedSlots.length > 2"
        class="place-card__slot-arrow"
        @click="prevSlots"
        :disabled="startIndex === 0"
      >
        <img src="/arrow-left.svg" alt="&lt;" />
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
        :disabled="startIndex >= mergedSlots.length - slotsPerPage"
      >
        <img src="/arrow-right.svg" alt="&gt;" />
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
      font-size: $text-xl;
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
        width: 40px;
        height: 40px;
      }

      &:disabled {
        opacity: 0.4;
        cursor: default;
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
