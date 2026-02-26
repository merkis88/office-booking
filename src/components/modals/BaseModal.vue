<script setup>
  import { onMounted, onUnmounted } from 'vue';

  const props = defineProps({
    modelValue: {
      type: Boolean,
      default: false,
    },
    title: {
      type: String,
      default: '',
    },
    maxWidth: {
      type: String,
      default: '500px',
    },
    closeOnBackdrop: {
      type: Boolean,
      default: false,
    },
    showCloseButton: {
      type: Boolean,
      default: true,
    },
  });

  const emit = defineEmits(['update:modelValue', 'close']);

  function closeModal() {
    emit('update:modelValue', false);
    emit('close');
  }

  function handleBackdropClick() {
    if (props.closeOnBackdrop) {
      closeModal();
    }
  }

  function handleEscape(e) {
    if (e.key === 'Escape' && props.modelValue && props.closeOnBackdrop) {
      closeModal();
    }
  }

  onMounted(() => {
    document.addEventListener('keydown', handleEscape);
  });

  onUnmounted(() => {
    document.removeEventListener('keydown', handleEscape);
  });
</script>

<template>
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="modelValue" class="modal-overlay" @click.self="handleBackdropClick">
        <div class="modal-container" :style="{ maxWidth: maxWidth }">
          <div class="modal-header">
            <button
              v-if="showCloseButton"
              class="modal-back"
              @click="closeModal"
              aria-label="Назад"
            >
              <img src="/arrow.svg" alt="" />
            </button>
            <h3 v-if="title" class="modal-title">{{ title }}</h3>
          </div>

          <div class="modal-body">
            <slot />
          </div>

          <div v-if="$slots.footer" class="modal-footer">
            <slot name="footer" />
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;
  @use '@/assets/styles/mixins' as *;

  .modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 9999;
    padding: 1rem;
  }

  .modal-container {
    background: $color-bg;
    border-radius: $radius-sm;
    width: 100%;
    max-height: 90vh;
    overflow-y: auto;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  }

  .modal-header {
    display: flex;
    align-items: center;
    padding: 1.5rem 1rem;
    position: relative;
    justify-content: center;
  }

  .modal-back {
    position: absolute;
    left: 1rem;
    display: flex;
    align-items: center;
    justify-content: center;
    width: 2.5rem;
    height: 2.5rem;
    border-radius: $radius-sm;
    transition: all 0.2s;
    color: $color-text;
    border: 1px solid #292d32;

    &:hover {
      background: rgba(255, 255, 255, 0.1);
    }
  }

  .modal-back:hover {
    background: rgba(255, 255, 255, 0.8);
  }

  .modal-title {
    font-size: $text-2xl;
    font-family: $font-title;
    font-weight: 500;
    color: $color-text;
    margin: 0;
  }

  .modal-body {
    padding: 1.5rem;
  }

  .modal-footer {
    padding: 1rem 1.5rem 1.5rem;
    display: flex;
    justify-content: center;
  }

  /* Анимации */
  .modal-enter-active,
  .modal-leave-active {
    transition: opacity 0.3s ease;
  }

  .modal-enter-active .modal-container,
  .modal-leave-active .modal-container {
    transition: transform 0.3s ease;
  }

  .modal-enter-from,
  .modal-leave-to {
    opacity: 0;
  }

  .modal-enter-from .modal-container,
  .modal-leave-to .modal-container {
    transform: scale(0.95) translateY(-20px);
  }
</style>
