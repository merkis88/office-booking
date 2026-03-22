<script setup>
  import { ref, computed, onMounted, watch } from 'vue';
  import { useAuthStore } from '@/store/auth';
  import { useBookingsStore } from '@/store/bookings';
  import { useServicesStore } from '@/store/services';
  import { storeToRefs } from 'pinia';
  import { useRouter } from 'vue-router';
  import QRCode from 'qrcode';
  import ServiceRequestCard from '@/components/ServiceRequestCard.vue';
  import BookingCard from '@/components/BookingCard.vue';
  import CancelBookingModal from '@/components/modals/CancelBookingModal.vue';
  import RescheduleBookingModal from '@/components/modals/RescheduleBookingModal.vue';
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
  });

  const saveError = ref('');
  const isSaving = ref(false);

  const qrDataUrl = ref(null);
  const qrLoading = ref(false);

  async function generateQrImage(hash) {
    if (!hash) {
      qrDataUrl.value = null;
      return;
    }
    qrLoading.value = true;
    try {
      qrDataUrl.value = await QRCode.toDataURL(hash, {
        width: 200,
        margin: 1,
      });
    } catch {
      qrDataUrl.value = null;
    } finally {
      qrLoading.value = false;
    }
  }

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

    isLoading.value = true;
    try {
      await authStore.fetchProfile();
    } catch (error) {
      await router.push('/authorization');
      return;
    } finally {
      isLoading.value = false;
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
    () => user.value?.qr_hash,
    (newHash) => {
      if (newHash) {
        generateQrImage(newHash);
      } else {
        qrDataUrl.value = null;
      }
    },
    { immediate: true },
  );

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

  const cancelBookingData = ref(null);
  const showCancelModal = ref(false);

  function handleBookingCancel(booking) {
    cancelBookingData.value = booking;
    showCancelModal.value = true;
  }

  function onBookingCancelled() {
    showCancelModal.value = false;
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
    bookingsStore.fetchMyBookings();
  }

  const activePlaceType = ref(null);

  const placeTypeFilters = [
    { label: 'Все аренды', value: null },
    { label: 'Переговорные', value: 'meeting' },
    { label: 'Коворкинг', value: 'coworking' },
    { label: 'Офис', value: 'office' },
  ];

  const filteredBookings = computed(() => {
    // Показываем только активные (cancelled отфильтровываем на фронте,
    // т.к. бэкенд пока не поддерживает фильтр status=active)
    let bookings = bookingsStore.bookings.filter(b => b.status !== 'cancelled');
    if (activePlaceType.value) {
      bookings = bookings.filter(b => b.place?.type === activePlaceType.value);
    }
    return bookings;
  });

  const groupedBookings = computed(() => {
    const groups = {};
    for (const booking of filteredBookings.value) {
      const date = new Date(booking.start_time).toLocaleDateString('ru-RU', {
        day: 'numeric',
        month: 'long',
        year: 'numeric',
      });
      if (!groups[date]) groups[date] = [];
      groups[date].push(booking);
    }
    return groups;
  });

  function handleBookingInvite(booking) {
    router.push({ path: '/passes', query: { booking: booking.id } });
  }

  const handleSave = async () => {
    saveError.value = '';
    isSaving.value = true;

    try {
      await authStore.updateProfile({
        first_name: editableUser.value.first_name,
        last_name: editableUser.value.last_name,
        patronymic: editableUser.value.patronymic || null,
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

</script>

<template>
  <div class="profile">
    <div v-if="user" class="profile__wrapper">
      <div class="profile__header-card">
        <!-- Левая колонка: аватар -->
        <div class="profile__avatar-col">
          <div class="profile__avatar-wrapper">
            <img src="@/assets/images/photos/avatar.png" alt="Фото профиля" class="profile__avatar" />
          </div>
          <button class="profile__upload-btn" disabled>Загрузить фото</button>
        </div>

        <!-- Правая колонка: контактные данные -->
        <div class="profile__form-col">
          <h2 class="profile__section-title">Контактные данные</h2>

          <div class="profile__fields">
            <div class="profile__field">
              <label class="profile__label">Фамилия</label>
              <input v-model="editableUser.last_name" class="profile__input" />
            </div>

            <div class="profile__field">
              <label class="profile__label">Имя</label>
              <input v-model="editableUser.first_name" class="profile__input" />
            </div>

            <div class="profile__field">
              <label class="profile__label">Отчество</label>
              <input v-model="editableUser.patronymic" class="profile__input" />
            </div>

            <div class="profile__field">
              <label class="profile__label">Почта</label>
              <input v-model="editableUser.email" class="profile__input" readonly />
            </div>
          </div>
        </div>

        <!-- Кнопки — полная ширина -->
        <div class="profile__actions">
          <button class="profile__btn" :disabled="isSaving" @click="handleSave">
            {{ isSaving ? 'Сохранение...' : 'Сохранить' }}
          </button>
          <button class="profile__btn" @click="handleCancel">Не сохранять</button>
          <router-link to="/update-password" class="profile__btn">Сменить пароль</router-link>
          <button class="profile__btn profile__btn--danger" @click="showDeleteModal = true">
            Удалить аккаунт
          </button>
        </div>
      </div>

      <!-- QR-блок — отдельная секция -->
      <div class="profile__qr-section">
        <!-- Нет активных бронирований -->
        <div v-if="!user.qr_booking" class="profile__qr-section-inner">
          <p class="profile__qr-section-text">Нет активных бронирований — QR-пропуск не требуется</p>
        </div>

        <!-- QR не виден (вне временного окна) -->
        <div v-else-if="!user.qr_visible" class="profile__qr-section-inner">
          <p class="profile__qr-section-text">{{ user.qr_message }}</p>
          <div class="profile__qr-frame profile__qr-frame--empty"></div>
        </div>

        <!-- QR загружается -->
        <div v-else-if="qrLoading" class="profile__qr-section-inner">
          <p class="profile__qr-section-text">Загрузка QR-кода...</p>
          <div class="profile__qr-frame">
            <span>Загрузка...</span>
          </div>
        </div>

        <!-- QR-код виден -->
        <div v-else class="profile__qr-section-inner">
          <p class="profile__qr-section-text">{{ user.qr_message }}</p>
          <div class="profile__qr-frame">
            <img v-if="qrDataUrl" :src="qrDataUrl" alt="QR-код пропуска" class="profile__qr-image" />
          </div>
        </div>
      </div>

      <p v-if="saveError" class="profile__error">{{ saveError }}</p>

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

        <div v-if="activeTab === 0" class="profile__bookings">
          <div class="profile__place-filter">
            <button
              v-for="filter in placeTypeFilters"
              :key="filter.value"
              class="profile__place-filter-btn"
              :class="{ 'profile__place-filter-btn--active': activePlaceType === filter.value }"
              @click="activePlaceType = filter.value"
            >
              {{ filter.label }}
            </button>
          </div>

          <div v-if="bookingsStore.isLoading" class="profile__loading">Загрузка...</div>

          <div v-else-if="!filteredBookings.length" class="profile__placeholder-card">
            <p>У вас нет активных бронирований</p>
          </div>

          <template v-else>
            <div
              v-for="(group, date) in groupedBookings"
              :key="date"
              class="profile__booking-group"
            >
              <h3 class="profile__booking-date">{{ date }}</h3>

              <BookingCard
                v-for="booking in group"
                :key="booking.id"
                :booking="booking"
                @invite="handleBookingInvite"
                @reschedule="handleBookingReschedule"
                @cancel="handleBookingCancel"
              />
            </div>
          </template>

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

    <DeleteAccountModal v-model="showDeleteModal" />
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;
  @use '@/assets/styles/mixins' as *;

  .profile {
    min-height: 100vh;
    padding: 4rem 2rem;

    &__wrapper {
      @include container;
      display: flex;
      flex-direction: column;
      gap: 2rem;
    }

    &__header-card {
      display: grid;
      grid-template-columns: 30% 1fr;
      gap: 2rem;
      padding: 2rem 3rem;
      background: $color-footer-bg;
      border-radius: $radius-sm;
      border: 1px solid $color-text;
    }

    &__avatar-col {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 1rem;
    }

    &__avatar-wrapper {
      width: 150px;
      height: 150px;
      border-radius: 50%;
      overflow: hidden;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    }

    &__avatar {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    &__upload-btn {
      padding: 0.5rem 1rem;
      border-radius: $radius-sm;
      border: 1px solid $color-border;
      background: $color-input-bg;
      font-size: $text-sm;
      cursor: not-allowed;
      opacity: 0.6;
    }

    &__form-col {
      display: flex;
      flex-direction: column;
      gap: 1rem;
    }

    &__section-title {
      font-family: $font-title;
      font-size: $text-xl;
      font-weight: 500;
      margin-bottom: 1rem;
      color: $color-text;
    }

    &__fields {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 1rem;
    }

    &__field {
      display: flex;
      flex-direction: column;
    }

    &__label {
      font-size: $text-sm;
      color: $color-text;
      margin-bottom: 0.25rem;
      display: block;
    }

    &__input {
      padding: 0.875rem 1.25rem;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      background: $color-input-bg;
      font-size: $text-base;
      min-height: 3.5rem;
      width: 100%;
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

    &__qr-section {
      background: $color-footer-bg;
      border-radius: $radius-sm;
      border: 1px solid $color-text;
      padding: 1.5rem 3rem;
    }

    &__qr-section-inner {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 2rem;
    }

    &__qr-section-text {
      flex: 1;
      font-size: $text-base;
      color: $color-text;
      text-align: center;
      line-height: 1.5;
    }

    &__qr-frame {
      width: 150px;
      height: 150px;
      border: 2px solid $color-border;
      border-radius: $radius-sm;
      background: white;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 0.25rem;

      &--empty {
        opacity: 0.3;
        border-style: dashed;
        background: transparent;
      }
    }

    &__qr-image {
      width: 100%;
      height: 100%;
      object-fit: contain;
    }

    &__actions {
      grid-column: 1 / -1;
      display: flex;
      gap: 1rem;
      justify-content: center;
      margin-top: 1rem;
    }

    &__error {
      color: #c0392b;
      font-size: $text-base;
      text-align: center;
      margin-top: 0.5rem;
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
      text-decoration: none;
      text-align: center;

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

      &--danger {
        color: #991b1b;
        border-color: #991b1b;

        &:hover {
          background: #fee2e2;
        }
      }
    }

    &__bottom {
      margin-top: 2rem;
    }

    &__tabs {
      display: flex;
      justify-content: center;
      gap: 0;
      margin-bottom: 2rem;
    }

    &__tab {
      padding: 0.75rem 2.5rem;
      border: 1px solid $color-border;
      background: $color-input-bg;
      font-size: $text-base;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.2s;
      white-space: nowrap;

      &:first-child {
        border-radius: $radius-sm 0 0 $radius-sm;
      }

      &:last-child {
        border-radius: 0 $radius-sm $radius-sm 0;
      }

      &:not(:first-child) {
        border-left: none;
      }

      &:hover {
        background: $color-input-bg-dark;
      }

      &--active {
        background: $color-header-bg;
        font-weight: 600;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.15);
      }
    }

    &__place-filter {
      display: flex;
      justify-content: center;
      gap: 0.75rem;
      margin-bottom: 2rem;
    }

    &__place-filter-btn {
      padding: 0.4rem 1.5rem;
      border-radius: $radius-sm;
      border: 1px solid $color-border;
      background: $color-input-bg;
      font-size: $text-sm;
      cursor: pointer;
      transition: all 0.2s;

      &:hover {
        background: $color-input-bg-dark;
      }

      &--active {
        background: $color-header-bg;
        font-weight: 600;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.15);
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

    &__bookings {
      display: flex;
      flex-direction: column;
      align-items: center;
      width: 100%;
    }

    &__booking-group {
      width: 60%;
      margin-bottom: 1.5rem;
    }

    &__booking-date {
      font-size: $text-base;
      font-weight: 500;
      color: $color-text;
      margin-bottom: 1rem;
    }

    &__booking-group :deep(.booking-card) {
      margin-bottom: 1rem;
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
      font-weight: 500;

      &:hover:not(:disabled) {
        background: $color-input-bg-dark;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
      }

      &:disabled {
        opacity: 0.5;
        cursor: not-allowed;
      }

      &--active {
        background: $color-header-bg;
        font-weight: 600;
        border-color: $color-text;
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

    @media (max-width: 1024px) {
      &__header-card {
        grid-template-columns: 1fr;
        justify-items: center;
      }

      &__services-grid {
        grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
      }
    }

    @media (max-width: 768px) {
      padding: 2rem 1rem;

      &__fields {
        grid-template-columns: 1fr;
      }

      &__actions {
        flex-wrap: wrap;
      }

      &__services-grid {
        grid-template-columns: 1fr;
      }

      &__tabs {
        overflow-x: auto;
        justify-content: flex-start;
      }

      &__place-filter {
        overflow-x: auto;
        justify-content: flex-start;
      }
    }
  }
</style>
