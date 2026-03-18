<script setup>
  import { ref } from 'vue';
  import { useNotificationsStore } from '@/store/notifications';
  import { storeToRefs } from 'pinia';

  const notificationsStore = useNotificationsStore();
  const { notifications, isLoading, unreadCount, hasUnread } = storeToRefs(notificationsStore);

  const isOpen = ref(false);
  const markingAsRead = ref(null);
  const markingAllAsRead = ref(false);
  const deletingNotification = ref(null);

  function togglePanel() {
    isOpen.value = !isOpen.value;
    if (isOpen.value && notifications.value.length === 0) {
      notificationsStore.fetchNotifications();
    }
  }

  function closePanel() {
    isOpen.value = false;
  }

  async function markAsRead(notificationId) {
    markingAsRead.value = notificationId;
    await notificationsStore.markAsRead(notificationId);
    markingAsRead.value = null;
  }

  async function markAllAsRead() {
    markingAllAsRead.value = true;
    await notificationsStore.markAllAsRead();
    markingAllAsRead.value = false;
  }

  async function deleteNotification(notificationId) {
    deletingNotification.value = notificationId;
    await notificationsStore.deleteNotification(notificationId);
    deletingNotification.value = null;
  }

  function formatDate(dateStr) {
    if (!dateStr) return '';
    const date = new Date(dateStr);
    const day = date.getDate().toString().padStart(2, '0');
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const year = date.getFullYear();
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${day}.${month}.${year}, ${hours}:${minutes}`;
  }
</script>

<template>
  <div class="notifications">
    <button class="notifications__button" @click="togglePanel" aria-label="Уведомления">
      <img src="/notification.svg" alt="Уведомления" />
      <span v-if="unreadCount > 0" class="notifications__badge">{{ unreadCount }}</span>
    </button>

    <transition name="fade">
      <div v-if="isOpen" class="notifications__overlay" @click="closePanel"></div>
    </transition>

    <transition name="slide">
      <div v-if="isOpen" class="notifications__panel">
        <div class="notifications__header">
          <button class="notifications__close" @click="closePanel" aria-label="Закрыть">
            <img src="/arrow-square-left.svg" alt="" />
          </button>

          <h2 class="notifications__title">Уведомления</h2>
        </div>

        <button
          v-if="hasUnread"
          class="notifications__mark-all"
          @click="markAllAsRead"
          :disabled="markingAllAsRead"
        >
          <span v-if="markingAllAsRead" class="notifications__mark-all-spinner"></span>
          <span v-else class="notifications__mark-all-icon"></span>
          <span class="notifications__mark-all-text">
            {{ markingAllAsRead ? 'Обработка...' : 'Прочитать все уведомления' }}
          </span>
        </button>

        <div class="notifications__content">
          <div v-if="isLoading" class="notifications__loading">
            <div class="notifications__spinner"></div>
            <p>Загрузка уведомлений...</p>
          </div>

          <div v-else-if="notifications.length === 0" class="notifications__empty">
            Нет уведомлений
          </div>

          <div v-else class="notifications__list">
            <div
              v-for="notification in notifications"
              :key="notification.id"
              class="notification-item"
              :class="{
                'notification-item--unread': !notification.is_read,
                'notification-item--deleting': deletingNotification === notification.id,
              }"
            >
              <div class="notification-item__body">
                <div class="notification-item__content">
                  <h3 class="notification-item__title">
                    Тема: {{ notification.title }}
                    <span v-if="!notification.is_read" class="notification-item__unread-badge">
                      ●
                    </span>
                  </h3>

                  <p class="notification-item__message">{{ notification.message }}</p>

                  <span class="notification-item__date">
                    {{ notification.created_at }}
                  </span>
                </div>

                <button
                  v-if="!notification.is_read"
                  class="notification-item__mark-one"
                  @click.stop="markAsRead(notification.id)"
                  :disabled="markingAsRead === notification.id"
                >
                  <span
                    v-if="markingAsRead === notification.id"
                    class="notification-item__mark-spinner"
                  ></span>
                  <span v-else class="notification-item__mark-icon"></span>
                  <span class="notification-item__mark-text">
                    {{
                      markingAsRead === notification.id ? 'Обработка...' : 'Прочитать уведомление'
                    }}
                  </span>
                </button>
              </div>

              <button
                class="notification-item__delete"
                @click="deleteNotification(notification.id)"
                :disabled="deletingNotification === notification.id"
                aria-label="Удалить"
              >
                <div
                  v-if="deletingNotification === notification.id"
                  class="notification-item__delete-spinner"
                ></div>
                <img v-else src="/delete-themes.svg" alt="" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;

  .notifications {
    position: relative;

    &__button {
      position: relative;
      background: transparent;
      border: none;
      cursor: pointer;
      padding: 0;
      display: flex;
      align-items: center;
      justify-content: center;

      img {
        height: 35px;
        transition: opacity 0.2s;
      }

      &:hover img {
        opacity: 0.7;
      }
    }

    &__badge {
      position: absolute;
      top: -5px;
      right: -5px;
      background: #e74c3c;
      color: white;
      border-radius: 50%;
      width: 20px;
      height: 20px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 12px;
      font-weight: 600;
    }

    &__overlay {
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0, 0, 0, 0.3);
      z-index: 998;
    }

    &__panel {
      position: fixed;
      top: 26px;
      right: 60px;
      width: 400px;
      min-height: 700px;
      background: $color-bg;
      box-shadow: -4px 0 24px rgba(0, 0, 0, 0.15);
      z-index: 999;
      display: flex;
      flex-direction: column;
      align-items: center;
      border-radius: $radius-sm;
    }

    &__header {
      padding: 1.5rem;
      display: flex;
      flex-direction: column;
      gap: 1rem;
    }

    &__close {
      position: absolute;
      top: 1rem;
      left: 1rem;
      background: transparent;
      border: none;
      cursor: pointer;
      color: $color-text;
      padding: 0.5rem;
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: $radius-sm;
      transition: all 0.2s;

      &:hover {
        transform: translateY(-3px);
      }
    }

    &__title {
      font-family: $font-heading;
      font-size: $text-xl;
      font-weight: 500;
      margin: 0;
      text-align: center;
    }

    &__mark-all {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      background: transparent;
      border: none;
      cursor: pointer;
      padding: 0;
      transition: opacity 0.2s;

      &:disabled {
        opacity: 0.6;
        cursor: not-allowed;
      }
    }

    &__mark-all-icon {
      width: 36px;
      height: 20px;
      border-radius: 10px;
      background: #e6f2fa;
      position: relative;
      flex-shrink: 0;
      transition: background 0.2s;

      &::after {
        content: '';
        position: absolute;
        top: 5px;
        left: 5px;
        width: 10px;
        height: 10px;
        background: #ff8b95;
        border-radius: 50%;
        transition: transform 0.2s;
        border: solid 1px #000000;
      }
    }

    &__mark-all-spinner {
      width: 20px;
      height: 20px;
      border: 2px solid #e6f2fa;
      border-top-color: #667eea;
      border-radius: 50%;
      animation: spin 0.6s linear infinite;
    }

    &__mark-all-text {
      color: $color-text;
      font-size: $text-sm;
      white-space: nowrap;
    }

    &__content {
      flex: 1;
      overflow-y: auto;
      width: 100%;
    }

    &__loading {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      gap: 1rem;
      padding: 3rem;
      color: rgba($color-text, 0.6);
      font-size: $text-base;
    }

    &__spinner {
      width: 40px;
      height: 40px;
      border: 3px solid rgba($color-text, 0.2);
      border-top-color: #667eea;
      border-radius: 50%;
      animation: spin 0.8s linear infinite;
    }

    &__empty {
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 3rem;
      color: rgba($color-text, 0.6);
      font-size: $text-base;
    }

    &__list {
      display: flex;
      flex-direction: column;
    }
  }

  .notification-item {
    display: flex;
    align-items: center;
    gap: 1rem;
    padding: 1.5rem;
    transition: all 0.3s;

    &:hover {
      background: rgba($color-text, 0.02);
    }

    &--unread {
      background: rgba(102, 126, 234, 0.05);
    }

    &--deleting {
      opacity: 0.5;
      transform: translateX(20px);
    }

    &__body {
      flex: 1;
      min-width: 0;
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
    }

    &__content {
      padding: 0.5rem 2rem;
      cursor: pointer;
      display: flex;
      flex-direction: column;
      background: linear-gradient(#b2c1cb, #7c8fa0);
      border-radius: $radius-sm;
      border: solid 1px $color-border;
    }

    &__title {
      font-size: $text-base;
      font-weight: 500;
      margin: 0 0 0.5rem 0;
      color: $color-text;
      display: flex;
      align-items: center;
      gap: 0.5rem;
    }

    &__unread-badge {
      color: #e74c3c;
      font-size: $text-lg;
    }

    &__message {
      font-size: $text-sm;
      color: $color-text;
      margin: 0 0 0.75rem 0;
      line-height: 1.5;
    }

    &__date {
      align-self: flex-end;
      font-size: $text-sm;
      color: rgba($color-text, 0.6);
    }

    &__mark-one {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      background: transparent;
      border: none;
      cursor: pointer;
      padding: 0;
      transition: opacity 0.2s;

      &:disabled {
        opacity: 0.6;
        cursor: not-allowed;
      }
    }

    &__mark-icon {
      width: 36px;
      height: 20px;
      border-radius: 10px;
      background: #e6f2fa;
      position: relative;
      flex-shrink: 0;
      transition: background 0.2s;

      &::after {
        content: '';
        position: absolute;
        top: 5px;
        left: 5px;
        width: 10px;
        height: 10px;
        background: #ff8b95;
        border-radius: 50%;
        transition: transform 0.2s;
        border: solid 1px #000000;
      }
    }

    &__mark-spinner {
      width: 20px;
      height: 20px;
      border: 2px solid #e6f2fa;
      border-top-color: #667eea;
      border-radius: 50%;
      animation: spin 0.6s linear infinite;
    }

    &__mark-text {
      color: $color-text;
      font-size: $text-sm;
      white-space: nowrap;
    }

    &__delete {
      background: transparent;
      border: none;
      cursor: pointer;
      color: rgba($color-text, 0.5);
      padding: 0.5rem;
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: $radius-sm;
      transition: all 0.2s;
      min-width: 40px;
      min-height: 40px;

      &:hover:not(:disabled) {
        color: #e74c3c;
        background: rgba(#e74c3c, 0.1);
      }

      &:disabled {
        cursor: not-allowed;
      }
    }

    &__delete-spinner {
      width: 20px;
      height: 20px;
      border: 2px solid rgba($color-text, 0.2);
      border-top-color: #e74c3c;
      border-radius: 50%;
      animation: spin 0.6s linear infinite;
    }
  }

  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }

  .fade-enter-active,
  .fade-leave-active {
    transition: opacity 0.3s;
  }

  .fade-enter-from,
  .fade-leave-to {
    opacity: 0;
  }

  .slide-enter-active,
  .slide-leave-active {
    transition: transform 0.3s ease;
  }

  .slide-enter-from,
  .slide-leave-to {
    transform: translateX(100%);
  }

  @media (max-width: 768px) {
    .notifications {
      &__panel {
        width: 100%;
        right: 0;
      }
    }
  }
</style>
