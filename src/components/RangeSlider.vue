<script setup>
  import { ref, watch } from 'vue';

  const props = defineProps({
    modelValue: {
      type: Array,
      required: true,
    },
    min: {
      type: Number,
      default: 0,
    },
    max: {
      type: Number,
      default: 100,
    },
    step: {
      type: Number,
      default: 1,
    },
  });

  const emit = defineEmits(['update:modelValue']);

  const minVal = ref(props.modelValue[0]);
  const maxVal = ref(props.modelValue[1]);

  const getPercent = (value) => {
    return ((value - props.min) / (props.max - props.min)) * 100;
  };

  const updateMin = () => {
    const value = Math.min(Number(minVal.value), maxVal.value - props.step);
    minVal.value = value;
    emit('update:modelValue', [value, maxVal.value]);
  };

  const updateMax = () => {
    const value = Math.max(Number(maxVal.value), minVal.value + props.step);
    maxVal.value = value;
    emit('update:modelValue', [minVal.value, value]);
  };

  watch(
    () => props.modelValue,
    (newValue) => {
      minVal.value = newValue[0];
      maxVal.value = newValue[1];
    },
    { deep: true },
  );
</script>

<template>
  <div class="range-slider">
    <div class="range-slider__track">
      <div
        class="range-slider__range"
        :style="{
          left: getPercent(minVal) + '%',
          width: getPercent(maxVal) - getPercent(minVal) + '%',
        }"
      />
    </div>

    <input
      v-model="minVal"
      type="range"
      :min="min"
      :max="max"
      :step="step"
      class="range-slider__input range-slider__input--min"
      @input="updateMin"
    />

    <input
      v-model="maxVal"
      type="range"
      :min="min"
      :max="max"
      :step="step"
      class="range-slider__input range-slider__input--max"
      @input="updateMax"
    />
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;

  .range-slider {
    position: relative;
    height: 24px;
    display: flex;
    align-items: center;
    width: 200px;
    margin-bottom: 11px;

    &__track {
      position: absolute;
      width: 100%;
      height: 6px;
      background: #e6f2fa;
      border-radius: 10px;
      margin-top: 12px;
    }

    &__range {
      position: absolute;
      height: 6px;
      background: #7c8fa0;
      border-radius: 2px;
    }

    &__input {
      position: absolute;
      width: 100%;
      height: 4px;
      background: transparent;
      pointer-events: none;
      -webkit-appearance: none;
      appearance: none;

      &::-webkit-slider-thumb {
        -webkit-appearance: none;
        appearance: none;
        width: 1.25rem;
        height: 1.25rem;
        border-radius: 50%;
        background: #7C8FA0;
        cursor: pointer;
        pointer-events: all;
        transition: transform 0.2s;
        position: relative;
        margin-bottom: 3rem;

        &:hover {
          transform: scale(1.2);
        }

        &:active {
          transform: scale(1.1);
        }
      }

      &--max {
        z-index: 4;
      }

      &--min {
        z-index: 3;
      }

      &::-webkit-slider-runnable-track {
        -webkit-appearance: none;
        height: 4px;
        background: transparent;
      }

      &::-moz-range-track {
        height: 4px;
        background: transparent;
      }

      &:focus {
        outline: none;
      }

    }
  }
</style>
