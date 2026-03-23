<script setup>
  import { ref, onMounted, computed } from 'vue';
  import { useAuthStore } from '@/store/auth';
  import { useRouter } from 'vue-router';
  import { storeToRefs } from 'pinia';
  import { usePlacesStore } from '@/store/places.js';

  const authStore = useAuthStore();
  const placesStore = usePlacesStore();
  const router = useRouter();

  const { places, isLoading } = storeToRefs(placesStore);
  const deletingPlaceId = ref(null);
  const showDeleteModal = ref(false);
  const deleteSuccess = ref(false);
  const isDeleting = ref(false);

  const firstThreePlaces = computed(() => {
    return places.value.slice(0, 3);
  });

  onMounted(async () => {
    if (!authStore.isAdmin) {
      router.push('/');
      return;
    }

    await placesStore.fetchPlaces();
  });

  onMounted(() => {
    if (!authStore.isAdmin) {
      router.push('/');
    }
  });

  function editPlace(placeId) {
    router.push(`/admin/places/${placeId}/edit`);
  }

  function deletePlace(placeId) {
    deletingPlaceId.value = placeId;
    showDeleteModal.value = true;
  }

  async function confirmDelete() {
    isDeleting.value = true;
    const result = await placesStore.deletePlace(deletingPlaceId.value);
    isDeleting.value = false;

    if (result.success) {
      deleteSuccess.value = true;
      setTimeout(() => {
        showDeleteModal.value = false;
        deleteSuccess.value = false;
        deletingPlaceId.value = null;
      }, 1200);
    }
  }

  function cancelDelete() {
    showDeleteModal.value = false;
    deletingPlaceId.value = null;
  }

  function getDeletePlaceNumber() {
    const place = placesStore.places.find((p) => p.id === deletingPlaceId.value);
    return place ? place.number_place : '';
  }

  function formatCapacity(capacity) {
    const count = capacity % 10;
    if (count === 1 && capacity !== 11) {
      return `${capacity} человек`;
    } else {
      return `${capacity} человек`;
    }
  }

  function getPlaceTypeName(type) {
    const types = {
      office: 'Офис',
      coworking: 'Коворкинг',
      meeting: 'Переговорная',
    };
    return types[type] || type;
  }
</script>

<template>
  <div class="admin">
    <div class="admin__container">
      <div class="admin__welcome">
        <div class="admin__welcome-content">
          <h1 class="admin__welcome-title">
            Добро пожаловать, {{ authStore.user?.first_name || 'Админ' }}
          </h1>
          <p class="admin__welcome-text">
            Управляйте системой уверенно, принимайте решения смело, контролируйте процессы
            внимательно.
          </p>
          <p class="admin__welcome-footer">Команда и система рассчитывают на вас!</p>
        </div>
        <div class="admin__welcome-image">
          <img src="/admin-welcome.png" alt="Добро пожаловать" />
        </div>
      </div>

      <div class="admin__places">
        <h2 class="admin__places-title">Последние добавленные помещения</h2>

        <div v-if="isLoading" class="admin__loading">
          <div class="admin__spinner"></div>
          <p>Загрузка помещений...</p>
        </div>

        <div v-else-if="firstThreePlaces.length === 0" class="admin__empty">
          <p>Помещения не найдены</p>
        </div>

        <div v-else class="admin__places-table">
          <div class="admin__table-header">
            <div class="admin__table-col admin__table-col--photo">Фото</div>
            <div class="admin__table-col admin__table-col--type">Тип помещения</div>
            <div class="admin__table-col admin__table-col--number">Кабинет№</div>
            <div class="admin__table-col admin__table-col--capacity">Вместимость</div>
            <div class="admin__table-col admin__table-col--price">Стоимость</div>
            <div class="admin__table-col admin__table-col--actions"></div>
          </div>

          <div v-for="place in firstThreePlaces" :key="place.id" class="admin__table-row">
            <div class="admin__table-col admin__table-col--photo">
              <div class="admin__place-photo">
                <img :src="place.photo" :alt="place.type" />
              </div>
            </div>
            <div class="admin__table-col admin__table-col--type">
              {{ getPlaceTypeName(place.type) }}
            </div>
            <div class="admin__table-col admin__table-col--number">№{{ place.number_place }}</div>
            <div class="admin__table-col admin__table-col--capacity">
              {{ formatCapacity(place.capacity) }}
            </div>
            <div class="admin__table-col admin__table-col--price">{{ place.price }}р</div>
            <div class="admin__table-col admin__table-col--actions">
              <button
                class="admin__action-btn admin__action-btn--delete"
                @click="deletePlace(place.id)"
                aria-label="Удалить"
              >
                <img src="/delete-themes.svg" alt="Удалить" />
              </button>
              <button
                class="admin__action-btn admin__action-btn--edit"
                @click="editPlace(place.id)"
                aria-label="Редактировать"
              >
                <img src="/edit.svg" alt="Редактировать" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <transition name="modal">
      <div v-if="showDeleteModal" class="modal-overlay" @click.self="cancelDelete">
        <div class="modal" :class="{ 'modal--success': deleteSuccess }">
          <h2 class="modal__title">{{ deleteSuccess ? 'Готово' : 'Удаление' }}</h2>
          <p class="modal__text">
            <template v-if="deleteSuccess">Помещение успешно удалено</template>
            <template v-else>
              Вы действительно хотите удалить помещение №{{ getDeletePlaceNumber() }}?
            </template>
          </p>
          <div v-if="!deleteSuccess" class="modal__actions">
            <button
              class="modal__btn modal__btn--confirm"
              :disabled="isDeleting"
              @click="confirmDelete"
            >
              <span v-if="isDeleting" class="modal__btn-spinner"></span>
              {{ isDeleting ? 'Удаление...' : 'Подтвердить' }}
            </button>
            <button
              class="modal__btn modal__btn--cancel"
              :disabled="isDeleting"
              @click="cancelDelete"
            >
              Отмена
            </button>
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;
  @use '@/assets/styles/mixins' as *;

  .admin {
    &__container {
      @include container;
    }

    &__welcome {
      background: $color-btn-profile;
      border-radius: $radius-lg;
      padding: 0 2rem;
      margin-bottom: 3rem;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 2rem;
    }

    &__welcome-content {
      flex: 1;
      display: flex;
      flex-direction: column;
      justify-content: center;
      gap: 2rem;
      max-width: 500px;
    }

    &__welcome-title {
      font-family: $font-title;
      font-size: $text-2xl;
      color: $color-text;
      font-weight: normal;
    }

    &__welcome-text {
      font-size: $text-base;
      color: $color-text;
      line-height: 1.6;
    }

    &__welcome-footer {
      font-size: $text-base;
      color: $color-text;
      margin: 0;
      font-weight: 500;
    }

    &__welcome-image {
      flex-shrink: 0;
      width: 200px;

      img {
        width: 100%;
        height: 100%;
        display: block;
      }
    }

    &__places-title {
      font-family: $font-title;
      font-size: $text-2xl;
      font-weight: 400;
      color: $color-text;
      margin: 0 0 2rem 0;
      text-align: center;
    }

    &__places-table {
      background: rgba(255, 255, 255, 0.7);
      padding: 2rem;
      border-radius: $radius-sm;
      overflow: hidden;
    }

    &__table-header {
      display: grid;
      grid-template-columns: 100px 1fr 120px 150px 120px 100px;
      gap: 1.2rem;
      padding: 1rem 1.5rem;
      background: transparent;
      border-bottom: 2px solid $color-border;
      color: $color-text;
      justify-content: center;
      justify-items: center;
    }

    &__table-row {
      display: grid;
      grid-template-columns: 100px 1fr 120px 150px 120px 100px;
      gap: 1rem;
      padding: 1.5rem;
      align-items: center;
      border: 1px solid $color-text;
      border-radius: $radius-sm;
      margin: 1rem;
      transition: all 0.2s;
      justify-content: center;
      justify-items: center;

      &:hover {
        background: #ebebeb;
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
      }
    }

    &__table-col {
      display: flex;
      align-items: center;

      &--photo {
        justify-content: center;
      }

      &--actions {
        justify-content: flex-end;
        gap: 0.5rem;
      }
    }

    &__place-photo {
      width: 120px;
      height: 120px;
      border-radius: $radius-sm;
      overflow: hidden;

      img {
        width: 100%;
        height: 100%;
        object-fit: cover;
      }
    }

    &__action-btn {
      background: transparent;
      border: none;
      cursor: pointer;
      padding: 0.5rem;
      border-radius: $radius-xs;
      transition: all 0.2s;
      display: flex;
      align-items: center;
      justify-content: center;

      img {
        width: 24px;
        height: 24px;
      }

      &--delete {
        &:hover {
          background: rgba(#e74c3c, 0.1);
        }
      }

      &--edit {
        &:hover {
          background: rgba(#3498db, 0.1);
        }
      }
    }

    @media (max-width: 1024px) {
      &__table-header,
      &__table-row {
        grid-template-columns: 80px 1fr 100px 130px 100px 80px;
        gap: 0.5rem;
        padding: 1rem;
        font-size: $text-sm;
      }

      &__place-photo {
        width: 60px;
        height: 60px;
      }

      &__welcome {
        flex-direction: column;
        text-align: center;
      }

      &__welcome-image {
        width: 150px;
      }
    }

    @media (max-width: 768px) {
      padding: 2rem 1rem;

      &__table-header {
        display: none;
      }

      &__table-row {
        display: flex;
        flex-direction: column;
        gap: 1rem;
        padding: 1.5rem;
      }

      &__table-col {
        width: 100%;
        justify-content: space-between;

        &::before {
          content: attr(data-label);
          font-weight: 600;
          margin-right: 1rem;
        }

        &--photo {
          justify-content: center;

          &::before {
            display: none;
          }
        }

        &--actions {
          justify-content: center;
          gap: 1rem;

          &::before {
            display: none;
          }
        }
      }

      &__welcome-title {
        font-size: $text-xl;
      }

      &__welcome-text,
      &__welcome-footer {
        font-size: $text-sm;
      }
    }
  }

  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }

  .dropdown-enter-active {
    animation: dropdown-in 0.2s ease-out;
  }

  .dropdown-leave-active {
    animation: dropdown-out 0.2s ease-in;
  }

  .modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.4);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
  }

  .modal {
    background: #fff;
    border-radius: $radius-lg;
    padding: 2.5rem 3rem;
    min-width: 420px;
    max-width: 500px;
    text-align: center;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);

    &--success {
      border: 2px solid #27ae60;
    }

    &__title {
      font-family: $font-title;
      font-size: $text-xl;
      font-weight: 700;
      color: $color-text;
      margin: 0 0 1rem 0;
    }

    &__text {
      font-size: $text-base;
      color: $color-text;
      margin: 0 0 2rem 0;
      font-family: $font-base;
    }

    &__actions {
      display: flex;
      gap: 1.5rem;
      justify-content: center;
    }

    &__btn {
      flex: 1;
      padding: 0.875rem 1.5rem;
      border: 1px solid $color-text;
      border-radius: $radius-sm;
      font-size: $text-base;
      font-family: $font-base;
      cursor: pointer;
      transition: all 0.2s;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 0.5rem;

      &--confirm {
        background: transparent;
        color: $color-text;

        &:hover:not(:disabled) {
          background: $color-text;
          color: #fff;
        }
      }

      &--cancel {
        background: transparent;
        color: $color-text;

        &:hover:not(:disabled) {
          background: rgba($color-text, 0.05);
        }
      }

      &:disabled {
        opacity: 0.6;
        cursor: not-allowed;
      }
    }

    &__btn-spinner {
      width: 16px;
      height: 16px;
      border: 2px solid rgba($color-text, 0.3);
      border-top-color: $color-text;
      border-radius: 50%;
      animation: spin 0.6s linear infinite;
    }
  }

  .modal-enter-active {
    animation: modal-in 0.25s ease-out;
  }

  .modal-leave-active {
    animation: modal-out 0.2s ease-in;
  }

  @keyframes modal-in {
    from {
      opacity: 0;
      transform: scale(0.95);
    }
    to {
      opacity: 1;
      transform: scale(1);
    }
  }

  @keyframes modal-out {
    from {
      opacity: 1;
      transform: scale(1);
    }
    to {
      opacity: 0;
      transform: scale(0.95);
    }
  }

  @keyframes dropdown-in {
    from {
      opacity: 0;
      transform: translateY(-10px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  @keyframes dropdown-out {
    from {
      opacity: 1;
      transform: translateY(0);
    }
    to {
      opacity: 0;
      transform: translateY(-10px);
    }
  }
</style>
