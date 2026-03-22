<script setup>
  const props = defineProps({
    status: {
      type: String,
      required: true,
      validator: (v) => ['pending', 'approved', 'rejected', 'active', 'cancelled'].includes(v),
    },
  });

  const statusLabels = {
    pending: 'Ожидает подтверждения',
    approved: 'Подтверждено',
    active: 'Активно',
    rejected: 'Отменено',
    cancelled: 'Отменено',
  };

  const label = statusLabels[props.status] || props.status;
</script>

<template>
  <span class="status-badge" :class="`status-badge--${status}`">
    {{ label }}
  </span>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;

  .status-badge {
    display: inline-flex;
    align-items: center;
    padding: 0.25rem 0.75rem;
    border-radius: $radius-xxs;
    font-size: $text-sm;
    font-weight: 500;
    white-space: nowrap;

    &--pending {
      background: #fef3c7;
      color: #92400e;
    }

    &--approved {
      background: #d1fae5;
      color: #065f46;
    }

    &--active {
      background: #d1fae5;
      color: #065f46;
    }

    &--rejected {
      background: #fee2e2;
      color: #991b1b;
    }

    &--cancelled {
      background: #fee2e2;
      color: #991b1b;
    }
  }
</style>
