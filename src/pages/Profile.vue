<script setup>
  import { ref, computed, onMounted, watch } from 'vue';
  import { useAuthStore } from '@/store/auth';
  import { useBookingsStore } from '@/store/bookings';
  import { useServicesStore } from '@/store/services';
  import { storeToRefs } from 'pinia';
  import { useRouter } from 'vue-router';
  import ServiceRequestCard from '@/components/ServiceRequestCard.vue';
  import PassCard from '@/components/PassCard.vue';
  import StatusBadge from '@/components/StatusBadge.vue';
  import BookingDetailsModal from '@/components/modals/BookingDetailsModal.vue';
  import BookingFilters from '@/components/BookingFilters.vue';
  import CancelBookingModal from '@/components/modals/CancelBookingModal.vue';
  import RescheduleBookingModal from '@/components/modals/RescheduleBookingModal.vue';
  import ExtendBookingModal from '@/components/modals/ExtendBookingModal.vue';
  import DeleteAccountModal from '@/components/modals/DeleteAccountModal.vue';
  import PlaceCard from '@/components/PlaceCard.vue';
  import { useFavoritesStore } from '@/store/favorites';

  const authStore = useAuthStore();
  const bookingsStore = useBookingsStore();
  const servicesStore = useServicesStore();
  const favoritesStore = useFavoritesStore();
  const router = useRouter();

  onMounted(() => {
    bookingsStore.fetchMyBookings();
  });
  const { user } = storeToRefs(authStore);
  const {
    services,
    isLoading: isLoadingServices,
    currentPage,
    lastPage,
  } = storeToRefs(servicesStore);
  const activeTab = ref(0);

  const isLoading = ref(false);
  const isEditing = ref(false);

  const editableUser = ref({
    first_name: '',
    last_name: '',
    patronymic: '',
    email: '',
    phone: '',
    post: '',
    company: '',
  });

  const saveError = ref('');
  const isSaving = ref(false);

  const totalPages = computed(() => lastPage.value);

  async function loadServices(page = 1) {
    await servicesStore.fetchServices(page);
  }

  function goToPage(page) {
    if (page >= 1 && page <= totalPages.value) {
      loadServices(page);
    }
  }

  onMounted(async () => {
    if (!authStore.isAuthenticated) {
      await router.push('/authorization');
      return;
    }

    if (!user.value) {
      isLoading.value = true;
      try {
        await authStore.fetchCurrentUser();
      } catch (error) {
        await router.push('/authorization');
      } finally {
        isLoading.value = false;
      }
    }

  });

  watch(activeTab, (newTab) => {
    if (newTab === 1) {
      favoritesStore.fetchFavorites();
    }
    if (newTab === 3) {
      loadServices();
    }
  });

  watch(
    user,
    (newUser) => {
      if (newUser) {
        editableUser.value = { ...newUser };
      }
    },
    { immediate: true },
  );

  const showDeleteModal = ref(false);

  const selectedBooking = ref(null);
  const showGuestQrModal = ref(false);
  const showIssueQrModal = ref(false);

  const selectedBookingId = ref(null);
  const showBookingDetails = ref(false);

  function openBookingDetails(bookingId) {
    selectedBookingId.value = bookingId;
    showBookingDetails.value = true;
  }

  const cancelBookingData = ref(null);
  const showCancelModal = ref(false);

  function handleBookingCancel(booking) {
    cancelBookingData.value = booking;
    showCancelModal.value = true;
  }

  function onBookingCancelled() {
    showCancelModal.value = false;
    showBookingDetails.value = false;
    bookingsStore.fetchMyBookings();
  }

  const rescheduleBookingData = ref(null);
  const showRescheduleModal = ref(false);

  function handleBookingReschedule(booking) {
    rescheduleBookingData.value = booking;
    showRescheduleModal.value = true;
  }

  function onBookingRescheduled() {
    showRescheduleModal.value = false;
    showBookingDetails.value = false;
    bookingsStore.fetchMyBookings();
  }

  const extendBookingData = ref(null);
  const showExtendModal = ref(false);

  function handleBookingExtend(booking) {
    extendBookingData.value = booking;
    showExtendModal.value = true;
  }

  function onBookingExtended() {
    showExtendModal.value = false;
    showBookingDetails.value = false;
    bookingsStore.fetchMyBookings();
  }

  const activeBookings = computed(() =>
    bookingsStore.bookings.filter(b => b.status !== 'rejected')
  );

  function applyFilters(newFilters) {
    Object.entries(newFilters).forEach(([key, value]) => {
      bookingsStore.filters[key] = value;
    });
    bookingsStore.currentPage = 1;
    bookingsStore.fetchMyBookings();
  }

  function openGuestQrModal(booking) {
    selectedBooking.value = booking;
    showGuestQrModal.value = true;
  }

  function openIssueQrModal(booking) {
    selectedBooking.value = booking;
    showIssueQrModal.value = true;
  }

  const handleSave = async () => {
    saveError.value = '';
    isSaving.value = true;

    try {
      await authStore.updateProfile({
        first_name: editableUser.value.first_name,
        last_name: editableUser.value.last_name,
        patronymic: editableUser.value.patronymic || null,
        email: editableUser.value.email,
      });
      isEditing.value = false;
    } catch (error) {
      if (error.response?.status === 422) {
        const errors = error.response.data.errors;
        const firstError = Object.values(errors)[0];
        saveError.value = Array.isArray(firstError) ? firstError[0] : firstError;
      } else {
        saveError.value = 'Не удалось сохранить изменения. Повторите попытку.';
      }
    } finally {
      isSaving.value = false;
    }
  };

  const handleCancel = () => {
    editableUser.value = { ...user.value };
    isEditing.value = false;
    saveError.value = '';
  };

  const formatDate = (date) => {
    return new Date(date).toLocaleDateString('ru-RU');
  };

  const formatTime = (date) => {
    return new Date(date).toLocaleTimeString('ru-RU', {
      hour: '2-digit',
      minute: '2-digit',
    });
  };
</script>

<template>
  <div class="profile">
    <div v-if="user" class="profile__container">
      <div class="profile__photo-section">
        <div class="profile__photo-wrapper">
          <img src="@/assets/images/photos/avatar.png" alt="Фото профиля" class="profile__photo" />
        </div>
      </div>

      <div class="profile__info-section">
        <h2 class="profile__section-title">Контактные данные</h2>

        <div class="profile__form">
          <div class="profile__contact">
            <div class="profile__row">
              <div class="profile__field">
                <input
                  v-model="editableUser.last_name"
                  class="profile__input"
                  placeholder="Фамилия"
                />
              </div>

              <div class="profile__field">
                <input v-model="editableUser.first_name" class="profile__input" placeholder="Имя" />
              </div>

              <div class="profile__field">
                <input
                  v-model="editableUser.patronymic"
                  class="profile__input"
                  placeholder="Отчество"
                />
              </div>
            </div>

            <div class="profile__row">
              <div class="profile__field">
                <input
                  v-model="editableUser.email"
                  class="profile__input"
                  placeholder="Электронная почта"
                />
              </div>

              <div class="profile__field">
                <input
                  v-model="editableUser.phone"
                  class="profile__input"
                  placeholder="Телефон"
                />
              </div>

              <div class="profile__field">
                <input v-model="editableUser.post" class="profile__input" placeholder="Должность" readonly />
              </div>

              <div class="profile__field">
                <input
                  v-model="editableUser.company"
                  class="profile__input"
                  placeholder="Компания"
                  readonly
                />
              </div>
            </div>
          </div>
        </div>

        <p v-if="saveError" class="profile__error">{{ saveError }}</p>

        <div class="profile__actions">
          <button
            class="profile__btn"
            :disabled="isSaving"
            @click="handleSave"
          >
            {{ isSaving ? 'Сохранение...' : 'Сохранить' }}
          </button>

          <button class="profile__btn" @click="handleCancel">Не сохранять</button>
        </div>

        <div class="profile__pass-section">
          <h2 class="profile__section-title">Пропуска</h2>

          <div v-if="!activeBookings.length" class="profile__pass-empty">
            У вас нет активных аренд — QR-пропуск не требуется
          </div>

          <PassCard
            v-for="booking in activeBookings"
            :key="booking.id"
            :booking="booking"
            @invite-guest="openGuestQrModal(booking)"
            @invite-employee="openIssueQrModal(booking)"
          />

          <div class="profile__pass-actions">
            <router-link to="/update-password" class="profile__btn profile__btn--action">
              Сменить пароль
            </router-link>

            <button
              class="profile__btn profile__btn--danger"
              @click="showDeleteModal = true"
            >
              Удалить аккаунт
            </button>
          </div>
        </div>

        <div class="profile__bottom">
          <div class="profile__tabs">
            <button
              class="profile__tab"
              :class="{ 'profile__tab--active': activeTab === 0 }"
              @click="activeTab = 0"
            >
              Активные аренды
            </button>
            <button
              class="profile__tab"
              :class="{ 'profile__tab--active': activeTab === 1 }"
              @click="activeTab = 1"
            >
              Избранное
            </button>
            <button
              class="profile__tab"
              :class="{ 'profile__tab--active': activeTab === 2 }"
              @click="activeTab = 2"
            >
              История аренды
            </button>
            <button
              class="profile__tab"
              :class="{ 'profile__tab--active': activeTab === 3 }"
              @click="activeTab = 3"
            >
              Заявки
            </button>
          </div>

          <div v-if="activeTab === 0" class="profile__bottom-content">
            <BookingFilters
              :filters="bookingsStore.filters"
              @update:filters="applyFilters"
            />

            <div v-if="bookingsStore.isLoading">Загрузка...</div>

            <div
              v-else
              v-for="booking in bookingsStore.bookings"
              :key="booking.id"
              class="profile__booking-card profile__booking-card--clickable"
              @click="openBookingDetails(booking.id)"
            >
              <div class="profile__booking-info">
                <h3>
                  {{ booking.place.name }}
                </h3>

                <p>
                  {{ formatDate(booking.start_time) }} — {{ formatTime(booking.start_time) }} -
                  {{ formatTime(booking.end_time) }}
                </p>

                <p>Вместимость: {{ booking.place.capacity }} человек</p>

                <StatusBadge :status="booking.status" />
              </div>
            </div>

            <div class="profile__pagination" v-if="bookingsStore.lastPage > 1">
              <button
                v-for="page in bookingsStore.lastPage"
                :key="page"
                @click="bookingsStore.setPage(page)"
                :class="['profile__page-btn', { active: page === bookingsStore.currentPage }]"
              >
                {{ page }}
              </button>
            </div>
          </div>

          <div v-if="activeTab === 1" class="profile__bottom-content">
            <div v-if="favoritesStore.isLoading" class="profile__loading">
              Загрузка...
            </div>

            <div v-else-if="!favoritesStore.favorites.length" class="profile__placeholder-card">
              <p>У вас нет избранных помещений</p>
              <p class="profile__empty-hint">
                Добавляйте помещения в избранное, нажимая на сердечко на карточке
              </p>
            </div>

            <div v-else class="profile__favorites-grid">
              <PlaceCard
                v-for="place in favoritesStore.favorites"
                :key="place.id"
                :place="place"
              />
            </div>
          </div>

          <div v-if="activeTab === 2" class="profile__bottom-content">
            <div class="profile__placeholder-card">
              <p>История аренды</p>
            </div>
          </div>

          <div v-if="activeTab === 3" class="profile__services">
            <div v-if="isLoadingServices" class="profile__services-loading">
              <p>Загрузка заявок...</p>
            </div>

            <div v-else-if="services.length === 0" class="profile__services-empty">
              <p>У вас пока нет заявок</p>
            </div>

            <div v-else class="profile__services-grid">
              <ServiceRequestCard
                v-for="service in services"
                :key="service.id"
                :service="service"
              />
            </div>

            <div v-if="totalPages > 1 && !isLoading" class="profile__services-pagination">
              <button
                class="profile__pagination-btn"
                :disabled="currentPage === 1"
                @click="goToPage(currentPage - 1)"
              >
                <img src="@/assets/images/icons/arrow-left.svg" alt="Назад" />
              </button>

              <button
                v-for="page in totalPages"
                :key="page"
                class="profile__pagination-number"
                :class="{ 'profile__pagination-number--active': currentPage === page }"
                @click="goToPage(page)"
              >
                {{ page }}
              </button>

              <button
                class="profile__pagination-btn"
                :disabled="currentPage === totalPages"
                @click="goToPage(currentPage + 1)"
              >
                <img src="@/assets/images/icons/arrow-right.svg" alt="Вперед" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <BookingDetailsModal
      v-model="showBookingDetails"
      :booking-id="selectedBookingId"
      @cancel="handleBookingCancel"
      @reschedule="handleBookingReschedule"
      @extend="handleBookingExtend"
    />

    <CancelBookingModal
      v-model="showCancelModal"
      :booking="cancelBookingData"
      @cancelled="onBookingCancelled"
    />

    <RescheduleBookingModal
      v-model="showRescheduleModal"
      :booking="rescheduleBookingData"
      @rescheduled="onBookingRescheduled"
    />

    <ExtendBookingModal
      v-model="showExtendModal"
      :booking="extendBookingData"
      @extended="onBookingExtended"
    />

    <DeleteAccountModal v-model="showDeleteModal" />
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;
  @use '@/assets/styles/mixins' as *;

  .profile {
    min-height: 100vh;
    padding: 4rem 2rem;

    &__container {
      @include container;
      display: flex;
      gap: 3rem;
      align-items: flex-start;
    }

    &__photo-section {
      flex-shrink: 0;
    }

    &__photo-wrapper {
      position: relative;
      width: 15rem;
      height: 22rem;
      border-radius: $radius-lg;
      overflow: hidden;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    }

    &__photo {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    &__info-section {
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 2rem;
    }

    &__section-title {
      font-family: $font-title;
      font-size: $text-xl;
      font-weight: 500;
      margin-bottom: 1rem;
      color: $color-text;
    }

    &__form {
      display: flex;
      flex-direction: column;
      gap: 1.5rem;
      align-items: center;
    }

    &__display {
      padding: 0.875rem 1.25rem;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      background: $color-input-bg;
      font-size: $text-base;
      color: $color-text;
      min-height: 3.5rem;
      width: 15rem;
      display: flex;
      align-items: center;
    }

    &__value {
      font-size: $text-base;
      color: $color-text;
      font-weight: 400;
      width: 100%;
      overflow: hidden;
      white-space: nowrap;
    }

    &__input {
      padding: 0.875rem 1.25rem;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      background: $color-input-bg;
      font-size: $text-base;
      min-height: 3.5rem;
      width: 15rem;
      outline: none;
      transition: 0.2s;

      &:focus {
        background: $color-input-bg-dark;
      }

      &[readonly] {
        opacity: 0.6;
        cursor: default;
      }
    }

    &__error {
      color: #c0392b;
      font-size: $text-base;
      text-align: center;
      margin-top: 0.5rem;
    }

    &__actions {
      display: flex;
      gap: 2rem;
      justify-content: center;
      margin-top: 1.5rem;
    }

    &__contact {
      background: $color-footer-bg;
      display: flex;
      flex-direction: column;
      gap: 1.5rem;
      align-items: center;
      padding: 2rem 3rem;
      border-radius: $radius-sm;
      border: 1px solid $color-text;
    }

    &__row {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 1rem;
    }

    &__field {
      display: flex;
      flex-direction: column;
    }

    &__btn {
      padding: 0.5rem 4rem;
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

      &:disabled {
        opacity: 0.6;
        cursor: not-allowed;
        transform: none;
        box-shadow: none;
      }

      &--action {
        padding: 0.75rem 0.5rem;
        text-align: center;
        width: 70%;
      }

      &--danger {
        color: #991b1b;
        border-color: #991b1b;

        &:hover {
          background: #fee2e2;
        }
      }
    }

    &__pass-section {
      margin-top: 2rem;
    }

    &__pass-empty {
      padding: 2rem;
      text-align: center;
      color: rgba($color-text, 0.6);
      font-size: $text-lg;
      background: $color-card-bg;
      border: 1px solid $color-border;
      border-radius: $radius-lg;
      margin-bottom: 1.5rem;
    }

    &__pass-actions {
      display: flex;
      gap: 1rem;
      margin-top: 1rem;
    }

    &__bottom {
      margin-top: 4rem;
    }

    &__tabs {
      display: flex;
      justify-content: center;
      gap: 1.5rem;
      margin-bottom: 2rem;
    }

    &__tab {
      padding: 0.5rem 4rem;
      border-radius: $radius-sm;
      border: 1px solid $color-border;
      background: $color-input-bg;
      font-size: $text-lg;
      transition: 0.2s;
      white-space: nowrap;
      flex-shrink: 0;

      &:hover {
        background: $color-input-bg-dark;
      }

      &--active {
        filter: drop-shadow(0 4px 4px rgba($color-border, 0.5));
      }
    }

    &__bottom-content {
      display: flex;
      justify-content: center;
      flex-direction: column;
      align-items: center;
    }

    &__placeholder-card {
      width: 60%;
      padding: 2rem;
      background: $color-card-bg;
      border-radius: $radius-lg;
      border: 1px solid $color-border;
      text-align: center;
    }

    &__empty-hint {
      margin-top: 0.5rem;
      color: rgba($color-text, 0.5);
      font-size: $text-sm;
    }

    &__loading {
      padding: 3rem;
      text-align: center;
      color: rgba($color-text, 0.6);
      font-size: $text-lg;
    }

    &__favorites-grid {
      width: 100%;
      max-width: 1200px;
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
      gap: 2rem;
    }

    &__booking-card {
      width: 60%;
      padding: 1.5rem;
      margin-bottom: 1.5rem;
      background: $color-card-bg;
      border-radius: $radius-lg;
      border: 1px solid $color-border;

      &--clickable {
        cursor: pointer;
        transition: all 0.2s ease;

        &:hover {
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
          transform: translateY(-2px);
        }

        &:active {
          transform: translateY(0);
          box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
        }
      }
    }

    &__booking-info {
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
    }

    &__pagination {
      display: flex;
      justify-content: center;
      gap: 0.5rem;
      margin-top: 2rem;
    }

    &__page-btn {
      padding: 0.5rem 1rem;
      border-radius: $radius-sm;
      border: 1px solid $color-border;
      background: $color-input-bg;

      &.active {
        background: white;
      }
    }

    &__services {
      width: 100%;
      display: flex;
      flex-direction: column;
      align-items: center;
    }

    &__services-loading,
    &__services-empty {
      padding: 3rem;
      text-align: center;
      color: rgba($color-text, 0.6);
      font-size: $text-lg;
    }

    &__services-grid {
      width: 100%;
      max-width: 1200px;
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(370px, 1fr));
      gap: 2.8rem;
      margin-bottom: 5rem;
    }

    &__services-pagination {
      display: flex;
      justify-content: center;
      align-items: center;
      gap: 0.5rem;
      margin-top: 2rem;
    }

    &__pagination-number {
      width: 2.5rem;
      height: 2.5rem;
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: $radius-xs;
      background: $color-input-bg;
      color: $color-text;
      font-size: $text-base;
      cursor: pointer;
      transition: all 0.2s;

      &:hover:not(:disabled) {
        background: $color-input-bg-dark;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
      }

      &:disabled {
        opacity: 0.5;
        cursor: not-allowed;
      }
    }

    &__pagination-btn {
      img {
        width: 2.6rem;
        height: 2.6rem;
      }
      &:disabled {
        opacity: 0.5;
        cursor: not-allowed;
      }
    }

    &__pagination-number {
      font-weight: 500;

      &--active {
        background: $color-header-bg;
        font-weight: 600;
        border-color: $color-text;
      }
    }

    @media (max-width: 1024px) {
      &__container {
        flex-direction: column;
        align-items: center;
      }

      &__photo-section {
        width: 100%;
        display: flex;
        justify-content: center;
      }

      &__info-section {
        width: 100%;
      }

      &__services-grid {
        grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
      }
    }

    @media (max-width: 768px) {
      padding: 2rem 1rem;

      &__row {
        grid-template-columns: 1fr;
      }

      &__btn {
        &--action {
          width: 100%;
        }
      }

      &__services-grid {
        grid-template-columns: 1fr;
      }

      &__tabs {
        overflow-x: auto;
        justify-content: flex-start;
      }
    }
  }
</style>
