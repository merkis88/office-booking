<script setup>
  import { ref, onMounted } from 'vue';
  import { usePlacesStore } from '@/store/places';
  import { useRouter } from 'vue-router';
  import { storeToRefs } from 'pinia';
  import AppPagination from '@/components/AppPagination.vue';

  const placesStore = usePlacesStore();
  const router = useRouter();

  const { isLoading, searchQuery, selectedFilter, currentPage, totalPages, paginatedPlaces } =
    storeToRefs(placesStore);

  const showFilterDropdown = ref(false);
  const showDeleteModal = ref(false);
  const deletingPlaceId = ref(null);
  const isDeleting = ref(false);
  const deleteSuccess = ref(false);

  onMounted(async () => {
    await placesStore.fetchPlaces();
  });

  function getPlaceTypeName(type) {
    const types = {
      office: 'Офис',
      coworking: 'Коворкинг',
      meeting: 'Переговорная',
    };
    return types[type] || type;
  }

  function formatCapacity(capacity) {
    return `${capacity} человек`;
  }

  function viewHistory() {
    router.push('/admin/places/booking-history');
  }

  function editPlace(placeId) {
    router.push(`/admin/places/${placeId}/edit`);
  }

  function getDeletePlaceNumber() {
    const place = placesStore.places.find((p) => p.id === deletingPlaceId.value);
    return place ? place.number_place : '';
  }

  function deletePlace(placeId) {
    deletingPlaceId.value = placeId;
    showDeleteModal.value = true;
  }

  async function confirmDelete() {
    isDeleting.value = true;
    try {
      await placesStore.deletePlace(deletingPlaceId.value);
      deleteSuccess.value = true;
      setTimeout(() => {
        showDeleteModal.value = false;
        deleteSuccess.value = false;
        deletingPlaceId.value = null;
      }, 1200);
    } catch (error) {
      alert(error.response?.data?.message || 'Не удалось удалить помещение');
    } finally {
      isDeleting.value = false;
    }
  }

  function cancelDelete() {
    showDeleteModal.value = false;
    deletingPlaceId.value = null;
  }

  function applyFilter(filterType) {
    placesStore.setFilter(filterType);
    showFilterDropdown.value = false;
  }

  function goToPage(page) {
    placesStore.goToPage(page);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  function getFilterLabel() {
    const labels = {
      all: 'Все помещения',
      office: 'Офисы',
      coworking: 'Коворкинги',
      meeting: 'Переговорные',
    };
    return labels[selectedFilter.value] || 'Фильтрация';
  }
</script>

<template>
  <div class="admin-places">
    <div class="admin-places__container">
      <div class="admin-places__controls">
        <div class="admin-places__control">
          <button class="admin-places__btn" @click="showFilterDropdown = !showFilterDropdown">
            <img src="@/assets/images/icons/filter.svg" alt="Фильтрация" />
            <span>{{ getFilterLabel() }}</span>
          </button>

          <transition name="dropdown">
            <div v-if="showFilterDropdown" class="admin-places__dropdown">
              <div class="admin-places__dropdown-item" @click="applyFilter('all')">
                Все помещения
              </div>
              <div class="admin-places__dropdown-item" @click="applyFilter('office')">Офисы</div>
              <div class="admin-places__dropdown-item" @click="applyFilter('coworking')">
                Коворкинги
              </div>
              <div class="admin-places__dropdown-item" @click="applyFilter('meeting')">
                Переговорные
              </div>
            </div>
          </transition>
        </div>

        <div class="admin-places__control">
          <div class="admin-places__search">
            <img
              src="@/assets/images/icons/search.svg"
              alt="Поиск"
              class="admin-places__search-icon"
            />
            <input
              :value="searchQuery"
              @input="placesStore.setSearchQuery($event.target.value)"
              type="text"
              class="admin-places__search-input"
              placeholder="Поиск"
            />
          </div>
        </div>

        <router-link to="/admin/places/create" class="admin-places__control">
          <button class="admin-places__btn">
            <img src="@/assets/images/icons/plus.svg" alt="Создать" />
            <span>Создать</span>
          </button>
        </router-link>

        <div class="admin-places__control">
          <button class="admin-places__btn" @click="viewHistory">
            <img src="@/assets/images/icons/history.svg" alt="История" />
            <span>История аренды</span>
          </button>
        </div>
      </div>

      <h1 class="admin-places__title">Помещения</h1>

      <div class="admin-places__table-wrapper">
        <div v-if="isLoading" class="admin-places__loading">
          <div class="admin-places__spinner"></div>
          <p>Загрузка помещений...</p>
        </div>

        <div v-else-if="paginatedPlaces.length === 0" class="admin-places__empty">
          <p>Помещения не найдены</p>
        </div>

        <div v-else class="admin-places__table">
          <div class="admin-places__table-header">
            <div class="admin-places__table-col admin-places__table-col--photo">Фото</div>
            <div class="admin-places__table-col admin-places__table-col--type">Тип помещения</div>
            <div class="admin-places__table-col admin-places__table-col--name">Название</div>
            <div class="admin-places__table-col admin-places__table-col--number">Кабинет№</div>
            <div class="admin-places__table-col admin-places__table-col--capacity">Вместимость</div>
            <div class="admin-places__table-col admin-places__table-col--price">Стоимость</div>
            <div class="admin-places__table-col admin-places__table-col--actions"></div>
          </div>

          <div v-for="place in paginatedPlaces" :key="place.id" class="admin-places__table-row">
            <div class="admin-places__table-col admin-places__table-col--photo">
              <div class="admin-places__place-photo">
                <img :src="place.photo_url" :alt="getPlaceTypeName(place.type)" />
              </div>
            </div>
            <div class="admin-places__table-col admin-places__table-col--type">
              {{ getPlaceTypeName(place.type) }}
            </div>
            <div class="admin-places__table-col admin-places__table-col--name">
              {{ place.name }}
            </div>
            <div class="admin-places__table-col admin-places__table-col--number">
              №{{ place.number_place }}
            </div>
            <div class="admin-places__table-col admin-places__table-col--capacity">
              {{ formatCapacity(place.capacity) }}
            </div>
            <div class="admin-places__table-col admin-places__table-col--price">
              {{ place.price }}р
            </div>
            <div class="admin-places__table-col admin-places__table-col--actions">
              <button
                class="admin-places__action-btn admin-places__action-btn--delete"
                @click="deletePlace(place.id)"
                aria-label="Удалить"
              >
                <img src="@/assets/images/icons/delete-themes.svg" alt="Удалить" />
              </button>
              <button
                class="admin-places__action-btn admin-places__action-btn--edit"
                @click="editPlace(place.id)"
                aria-label="Редактировать"
              >
                <img src="@/assets/images/icons/edit.svg" alt="Редактировать" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <AppPagination
        v-if="!isLoading"
        :current-page="currentPage"
        :total-pages="totalPages"
        @update:current-page="goToPage"
      />
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

  .admin-places {
    min-height: 100vh;

    &__container {
      @include container;
      max-width: 1200px;
    }

    &__controls {
      display: flex;
      gap: 1rem;
      margin-bottom: 2rem;
      flex-wrap: wrap;
    }

    &__control {
      position: relative;
    }

    &__btn {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      padding: 0.75rem 1.25rem;
      width: 13rem;
      background: $color-btn-profile;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      cursor: pointer;
      transition: all 0.2s;
      font-size: $text-base;
      color: $color-text;
      font-family: $font-base;

      img {
        width: 20px;
        height: 20px;
      }

      &:hover {
        background: $color-input-bg;
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
      }
    }

    &__dropdown {
      position: absolute;
      top: 100%;
      left: 0;
      margin-top: 0.5rem;
      background: $color-btn-profile;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
      z-index: 100;
      min-width: 200px;
      overflow: hidden;
    }

    &__dropdown-item {
      padding: 0.875rem 1.25rem;
      cursor: pointer;
      transition: all 0.2s;
      color: $color-text;

      &:hover {
        background: rgba($color-text, 0.05);
      }
    }

    &__search {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      padding: 0.75rem 1.25rem;
      width: 13rem;
      background: $color-btn-profile;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      transition: all 0.2s;

      &:focus-within {
        border-color: $color-text;
        box-shadow: 0 0 0 3px rgba($color-text, 0.1);
      }
    }

    &__search-icon {
      width: 20px;
      height: 20px;
      flex-shrink: 0;
    }

    &__search-input {
      border: none;
      outline: none;
      background: transparent;
      font-size: $text-base;
      color: $color-text;
      font-family: $font-base;
      min-width: 150px;

      &::placeholder {
        color: rgba($color-text, 1);
      }
    }

    // Заголовок
    &__title {
      font-family: $font-title;
      font-size: $text-2xl;
      font-weight: 500;
      color: $color-text;
      margin: 0 0 2rem 0;
      text-align: center;
    }

    // Таблица
    &__table-wrapper {
      background: rgba(255, 255, 255, 0.7);
      border-radius: $radius-lg;
      padding: 2rem;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
      margin-bottom: 2rem;
    }

    &__loading {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      gap: 1rem;
      padding: 3rem;
      color: rgba($color-text, 0.6);
    }

    &__spinner {
      width: 40px;
      height: 40px;
      border: 3px solid rgba($color-text, 0.2);
      border-top-color: #4a90e2;
      border-radius: 50%;
      animation: spin 0.8s linear infinite;
    }

    &__empty {
      text-align: center;
      padding: 3rem;
      color: rgba($color-text, 0.6);
      font-size: $text-lg;
    }

    &__table {
      border-radius: $radius-sm;
      overflow: hidden;
    }

    &__table-header {
      display: grid;
      grid-template-columns: 120px 1fr 160px 160px 140px 120px 120px;
      gap: 1rem;
      padding: 1rem 1.5rem;
      background: transparent;
      border-bottom: 2px solid $color-footer-bg;
      color: $color-text;
    }

    &__table-row {
      display: grid;
      grid-template-columns: 120px 1fr 160px 160px 140px 120px 120px;
      gap: 1rem;
      padding: 1.5rem;
      align-items: center;
      border-radius: $radius-sm;
      border: 1px solid $color-footer-bg;
      margin: 1rem;
      transition: all 0.2s;

      &:hover {
        background: #ebebeb;
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
      }
    }

    &__table-col {
      display: flex;
      align-items: center;
      justify-content: center;

      &--type {
        justify-content: center;
      }

      &--name {
        justify-content: center;
      }

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
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);

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

      &--delete:hover {
        background: rgba(#e74c3c, 0.1);
      }

      &--edit:hover {
        background: rgba(#3498db, 0.1);
      }
    }

    @media (max-width: 1024px) {
      &__controls {
        justify-content: center;
      }

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
    }

    @media (max-width: 768px) {
      padding: 2rem 1rem;

      &__controls {
        flex-direction: column;
      }

      &__table-header {
        display: none;
      }

      &__table-row {
        display: flex;
        flex-direction: column;
        gap: 1rem;
      }

      &__table-col {
        width: 100%;
        justify-content: space-between;

        &--photo {
          justify-content: center;
        }

        &--actions {
          justify-content: center;
          gap: 1rem;
        }
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
