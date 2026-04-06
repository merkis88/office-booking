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
  import FavoriteCard from '@/components/FavoriteCard.vue';
  import BookingHistoryCard from '@/components/BookingHistoryCard.vue';
  import AppPagination from '@/components/AppPagination.vue';
  import { useFavoritesStore } from '@/store/favorites';
  import defaultAvatar from '@/assets/images/photos/default-avatar.png';
  import qrPlaceholder from '@/assets/images/photos/qr-placeholder.png';
  import downloadIcon from '@/assets/images/icons/download-white.svg';
  import ProfileAnalytics from '@/components/ProfileAnalytics.vue';

  const authStore = useAuthStore();
  const bookingsStore = useBookingsStore();
  const servicesStore = useServicesStore();
  const favoritesStore = useFavoritesStore();
  const router = useRouter();
  const BOOKINGS_PER_PAGE = 3;
  const isDragOver = ref(false);
  const dragCounter = ref(0);

  onMounted(() => {
    bookingsStore.fetchBookings();
    favoritesStore.fetchFavorites();
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
  const photoError = ref('');

  const editableUser = ref({
    first_name: '',
    last_name: '',
    patronymic: '',
    email: '',
  });

  const fileInput = ref(null);
  const isUploadingPhoto = ref(false);

  const handleFileChange = async (event) => {
    const file = event.target.files[0];
    if (!file) return;
    photoError.value = '';

    if (file.size > 5 * 1024 * 1024) {
      photoError.value = 'Файл больше 5MB';
      return;
    }

    await uploadPhoto(file);

    event.target.value = '';
  };

  const uploadPhoto = async (file) => {
    isUploadingPhoto.value = true;
    photoError.value = '';

    try {
      await authStore.uploadProfilePhoto(file);
    } catch (error) {
      if (error.response?.status === 422) {
        photoError.value = 'Некорректный файл';
      } else {
        photoError.value = 'Ошибка загрузки фото';
      }
    } finally {
      isUploadingPhoto.value = false;
    }
  };

  const saveError = ref('');
  const isSaving = ref(false);

  const qrDataUrl = ref(null);
  const qrLoading = ref(false);

  const bookingsCurrentPage = ref(1);

  const paginatedBookings = computed(() => {
    const start = (bookingsCurrentPage.value - 1) * BOOKINGS_PER_PAGE;
    return filteredBookings.value.slice(start, start + BOOKINGS_PER_PAGE);
  });

  const bookingsTotalPages = computed(() => {
    return Math.ceil(filteredBookings.value.length / BOOKINGS_PER_PAGE);
  });

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

  const qrDateTimeText = computed(() => {
    if (!user.value?.qr_available_from || !user.value?.qr_available_until) {
      return '';
    }

    const from = new Date(user.value.qr_available_from);
    const until = new Date(user.value.qr_available_until);

    const date = from.toLocaleDateString('ru-RU', {
      day: 'numeric',
      month: 'long',
    });

    const fromTime = from.toLocaleTimeString('ru-RU', {
      hour: '2-digit',
      minute: '2-digit',
    });

    const untilTime = until.toLocaleTimeString('ru-RU', {
      hour: '2-digit',
      minute: '2-digit',
    });

    return `${date}, ${fromTime}–${untilTime}`;
  });

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
    bookingsStore.fetchBookings();
  }

  function goToBookingsPage(page) {
    if (page >= 1 && page <= bookingsTotalPages.value) {
      bookingsCurrentPage.value = page;
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }
  }

  const rescheduleBookingData = ref(null);

  const showRescheduleModal = ref(false);
  function handleBookingReschedule(booking) {
    rescheduleBookingData.value = booking;
    showRescheduleModal.value = true;
  }
  function onBookingRescheduled() {
    showRescheduleModal.value = false;
    bookingsStore.fetchBookings();
  }
  const activePlaceType = ref(null);

  const placeTypeFilters = [
    { label: 'Все аренды', value: null },
    { label: 'Переговорная', value: 'meeting' },
    { label: 'Коворкинг', value: 'coworking' },
    { label: 'Офис', value: 'office' },
  ];

  watch(activePlaceType, () => {
    bookingsCurrentPage.value = 1;
  });

  function formatBookingDateForGroup(isoString) {
    if (!isoString) return '';
    const date = new Date(isoString);
    const day = date.toLocaleDateString('ru-RU', { day: 'numeric' });
    const month = date.toLocaleDateString('ru-RU', { month: 'long' });
    const year = date.toLocaleDateString('ru-RU', { year: 'numeric' });
    return `${day} ${month}, ${year}`;
  }

  const filteredBookings = computed(() => {
    let bookings = bookingsStore.bookings.filter((b) => b.status === 'active');
    if (activePlaceType.value) {
      bookings = bookings.filter((b) => b.place?.type === activePlaceType.value);
    }
    return bookings;
  });

  const groupedBookings = computed(() => {
    const groups = {};
    for (const booking of paginatedBookings.value) {
      const date = formatBookingDateForGroup(booking.start_time);
      if (!groups[date]) groups[date] = [];
      groups[date].push(booking);
    }
    return groups;
  });

  const historyBookings = computed(() => {
    let bookings = bookingsStore.bookings.filter(
      (b) => b.status === 'cancelled' || b.status === 'over',
    );

    if (activePlaceType.value) {
      bookings = bookings.filter((b) => b.place?.type === activePlaceType.value);
    }

    return bookings;
  });

  const groupedHistoryBookings = computed(() => {
    const groups = {};
    for (const booking of historyBookings.value) {
      const date = formatBookingDateForGroup(booking.start_time);
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

  const handleDragOver = (e) => {
    e.preventDefault();
  };

  const handleDragEnter = (e) => {
    e.preventDefault();
    dragCounter.value++;
    isDragOver.value = true;
  };

  const handleDragLeave = () => {
    dragCounter.value--;

    if (dragCounter.value <= 0) {
      isDragOver.value = false;
      dragCounter.value = 0;
    }
  };

  const handleDrop = async (e) => {
    e.preventDefault();

    dragCounter.value = 0;
    isDragOver.value = false;

    const file = e.dataTransfer.files[0];
    if (!file) return;

    photoError.value = '';

    const isValidType = file.type === 'image/jpeg' || file.type === 'image/png';

    if (!isValidType) {
      photoError.value = 'Только JPG или PNG';
      return;
    }

    if (file.size > 5 * 1024 * 1024) {
      photoError.value = 'Файл больше 5MB';
      return;
    }

    await uploadPhoto(file);
  };
</script>

<template>
  <div class="profile">
    <div v-if="user" class="profile__wrapper">
      <div class="profile__header-card">
        <div class="profile__avatar-col">
          <div
            class="profile__avatar-wrapper"
            :class="{ 'profile__avatar-wrapper--drag': isDragOver }"
            @dragenter="handleDragEnter"
            @dragover="handleDragOver"
            @dragleave="handleDragLeave"
            @drop="handleDrop"
          >
            <img
              :src="user.photo_url || defaultAvatar"
              alt="Фото профиля"
              class="profile__avatar"
              @error="
                (e) => {
                  e.target.onerror = null;
                  e.target.src = defaultAvatar;
                }
              "
            />

            <div class="profile__avatar-overlay">
              <img :src="downloadIcon" alt="Загрузка" />
            </div>
          </div>
          <input
            ref="fileInput"
            type="file"
            accept="image/*"
            style="display: none"
            @change="handleFileChange"
          />

          <button class="profile__upload-btn" type="button" @click="fileInput.click()">
            <img src="@/assets/images/icons/edit.svg" alt="Иконка загрузки фото" />
            Загрузить фото
          </button>
          <p v-if="photoError" class="error-message">{{ photoError }}</p>
        </div>

        <div class="profile__right-col">
          <div class="profile__form-col">
            <h2 class="profile__section-title">Контактные данные</h2>

            <div class="profile__fields">
              <div class="profile__field">
                <label class="profile__label">Фамилия:</label>
                <input v-model="editableUser.last_name" class="profile__input" />
              </div>

              <div class="profile__field">
                <label class="profile__label">Имя:</label>
                <input v-model="editableUser.first_name" class="profile__input" />
              </div>

              <div class="profile__field">
                <label class="profile__label">Отчество:</label>
                <input v-model="editableUser.patronymic" class="profile__input" />
              </div>

              <div class="profile__field">
                <label class="profile__label">Электронная почта:</label>
                <input v-model="editableUser.email" class="profile__input" readonly />
              </div>
            </div>
          </div>

          <div class="profile__actions">
            <button class="btn profile__action-btn" :disabled="isSaving" @click="handleSave">
              {{ isSaving ? 'Сохранение...' : 'Сохранить' }}
            </button>
            <button class="btn profile__action-btn" @click="handleCancel">Не сохранять</button>
            <router-link to="/update-password" class="btn profile__action-btn">
              Сменить пароль
            </router-link>
            <button
              class="btn btn--outline-danger profile__action-btn"
              @click="showDeleteModal = true"
            >
              Удалить аккаунт
            </button>
          </div>
        </div>
      </div>

      <p v-if="saveError" class="error-message">{{ saveError }}</p>

      <div class="profile__qr-section">
        <div v-if="!user.qr_booking" class="profile__qr-section-inner">
          <p class="profile__qr-section-text">
            Нет активных бронирований — QR-пропуск не требуется
          </p>
        </div>

        <div v-else-if="!user.qr_visible" class="profile__qr-section-inner">
          <p class="profile__qr-section-text">{{ user.qr_message }}</p>
          <div class="profile__qr-frame profile__qr-frame--empty">
            <img :src="qrPlaceholder" class="profile__qr-image" alt="QR" />
          </div>
        </div>

        <div v-else-if="qrLoading" class="profile__qr-section-inner">
          <p class="profile__qr-section-text">Загрузка QR-кода...</p>
          <div class="profile__qr-frame">
            <span>Загрузка...</span>
          </div>
        </div>

        <div v-else class="profile__qr-section-inner">
          <p class="profile__qr-section-text">
            Благодарим за выбор нашего бизнес-центра. Ваш qr-код активен и готов к работе! Вы можете
            пользоваться им 30 минут до начала аренды и 15 минут после окончания
            <span v-if="qrDateTimeText">({{ qrDateTimeText }})</span>
            .
          </p>
          <div class="profile__qr-frame">
            <img
              v-if="qrDataUrl"
              :src="qrDataUrl"
              alt="QR-код пропуска"
              class="profile__qr-image"
            />
          </div>
        </div>
      </div>

      <ProfileAnalytics />

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

          <div v-if="bookingsStore.isLoading" class="loading">
            <div class="spinner"></div>
          </div>

          <div v-else-if="!filteredBookings.length" class="empty-state">
            <p>Нет активных бронирований</p>
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

          <AppPagination
            :current-page="bookingsCurrentPage"
            :total-pages="bookingsTotalPages"
            @update:current-page="goToBookingsPage"
          />
        </div>

        <div v-if="activeTab === 1" class="profile__bottom-content">
          <div v-if="favoritesStore.isLoading" class="loading">
            <div class="spinner"></div>
          </div>

          <div v-else-if="!favoritesStore.favorites.length" class="empty-state">
            <p>Нет избранных помещений</p>
            <p class="empty-state__hint">
              Добавляйте помещения в избранное, нажимая на сердечко на карточке
            </p>
          </div>

          <div v-else class="profile__favorites-grid">
            <FavoriteCard
              v-for="place in favoritesStore.favorites"
              :key="place.id"
              :place="place"
            />
          </div>
        </div>

        <div v-if="activeTab === 2" class="profile__bookings">
          <div v-if="!historyBookings.length" class="empty-state">
            <p>История аренды пуста</p>
          </div>

          <template v-else>
            <div
              v-for="(group, date) in groupedHistoryBookings"
              :key="date"
              class="profile__booking-group"
            >
              <h3 class="profile__booking-date">{{ date }}</h3>

              <div class="profile__history-grid">
                <BookingHistoryCard v-for="booking in group" :key="booking.id" :booking="booking" />
              </div>
            </div>
          </template>
        </div>

        <div v-if="activeTab === 3" class="profile__services">
          <div v-if="isLoadingServices" class="loading">
            <div class="spinner"></div>
          </div>

          <div v-else-if="services.length === 0" class="empty-state">
            <p>Заявок пока нет</p>
          </div>

          <div v-else class="profile__services-grid">
            <ServiceRequestCard v-for="service in services" :key="service.id" :service="service" />
          </div>

          <AppPagination
            v-if="!isLoading"
            :current-page="currentPage"
            :total-pages="totalPages"
            @update:current-page="goToPage"
          />
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
    padding: 2.5rem 2rem 4rem;
    background: $color-bg;

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
      background: $color-header-bg;
      border-radius: $card-radius;
      border: none;
    }

    &__avatar-col {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 1rem;

      .error-message {
        width: 190px;
      }
    }

    &__right-col {
      display: flex;
      flex-direction: column;
      justify-content: flex-start;
      gap: 1.5rem;
      align-items: stretch;
    }

    &__avatar-wrapper {
      position: relative;
      width: 300px;
      height: 300px;
      border-radius: 50%;
      overflow: hidden;

      border: 3px solid transparent;
      transition:
        border-color 0.2s ease,
        transform 0.2s ease;

      &--drag {
        border: 3px solid $color-btn-profile;
        transform: scale(1.03);
      }
    }

    &__avatar-overlay {
      pointer-events: none;
      position: absolute;
      inset: 0;
      background: rgba(0, 0, 0, 0.55);

      display: flex;
      align-items: center;
      justify-content: center;

      opacity: 0;
      transition: opacity 0.25s ease;

      img {
        width: 48px;
        height: 48px;
        transform: translateY(10px) scale(0.9);
        transition: transform 0.25s ease;
      }
    }

    &__avatar-wrapper--drag &__avatar-overlay {
      opacity: 1;

      img {
        transform: translateY(0) scale(1);
      }
    }

    &__avatar {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    &__upload-btn {
      width: 190px;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      gap: 0.75rem;
      padding: 0.55rem 1.2rem;
      border-radius: $card-image-radius;
      border: 1px solid $color-border;
      background: $card-bg;
      font-size: $text-base;
      cursor: pointer;
      opacity: 1;
      transition: all 0.2s ease;

      img {
        width: 1.25rem;
        height: 1.25rem;
      }

      &:hover {
        background: rgba($color-input-bg, 0.95);
      }
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
      text-align: left;
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
      color: rgba($color-text, 0.5);
      margin-bottom: 0.25rem;
      display: block;
    }

    &__input {
      padding: 0.25rem 0;
      border: none;
      border-bottom: 1px solid rgba($color-border, 0.6);
      border-radius: 0;
      background: transparent;
      font-size: $text-base;
      min-height: unset;
      width: 100%;
      outline: none;
      transition: $transition-fast;

      &:focus {
        background: transparent;
      }

      &[readonly] {
        opacity: 0.6;
        cursor: default;
      }
    }

    &__qr-section {
      width: 80%;
      margin: 0 auto;
      background: $table-bg;
      border-radius: $card-radius;
      border: 1px solid $color-text;
      padding: 1.25rem 2.5rem;
    }

    &__qr-section-inner {
      display: flex;
      align-items: center;
      justify-content: space-between;
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
      border: 2px solid $color-footer-bg;
      border-radius: $radius-sm;
      background: $card-bg;
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
      border-radius: $radius-xxs;
    }

    &__actions {
      display: flex;
      gap: 1.25rem;
      justify-content: flex-start;
      margin-top: 0.75rem;
    }

    &__action-btn {
      width: 180px;
      padding: 0.55rem 0;
    }

    &__bottom {
      margin-top: 2rem;
    }

    &__tabs {
      display: flex;
      justify-content: flex-start;
      gap: 0.9rem;
      max-width: 1100px;
      margin: 0 auto 1.25rem;
    }

    &__tab {
      width: 210px;
      height: 42px;
      padding: 0;
      border: 1px solid $color-border;
      background: $card-bg;
      border-radius: $card-image-radius;
      font-size: 1.125rem; // 18px
      font-weight: 500;
      cursor: pointer;
      transition: all 0.2s;
      white-space: nowrap;
      display: flex;
      align-items: center;
      justify-content: center;

      &:hover {
        background: rgba($color-input-bg, 0.95);
      }

      &--active {
        box-shadow: $button-shadow;
      }
    }

    &__place-filter {
      display: flex;
      justify-content: center;
      gap: 0.9rem;
      flex-wrap: wrap;
      margin-bottom: 2rem;
      width: 100%;
    }

    &__place-filter-btn {
      width: 200px;
      height: 42px;
      padding: 0;
      border: 1px solid $color-border;
      background: $card-bg;
      border-radius: 0.625rem;
      font-size: 1.125rem;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.2s;
      display: flex;
      align-items: center;
      justify-content: center;
      white-space: nowrap;

      &:hover {
        background: rgba($color-input-bg, 0.95);
      }

      &--active {
        box-shadow: $button-shadow;
      }
    }

    &__bottom-content {
      display: flex;
      justify-content: center;
      flex-direction: column;
      align-items: center;
    }

    &__placeholder-card {
      width: 100%;
      max-width: 680px;
      padding: 2rem;
      background: $color-card-bg;
      border-radius: $radius-lg;
      border: 1px solid $color-border;
      text-align: center;
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
      width: 100%;
      max-width: 1100px;
      margin-bottom: 1.5rem;
    }

    &__booking-date {
      font-size: 1.5rem; // 24px
      font-weight: 400;
      color: $color-text;
      margin-bottom: 1rem;
    }

    &__booking-group :deep(.booking-card) {
      margin-bottom: 1rem;
    }

    &__services {
      width: 100%;
      display: flex;
      flex-direction: column;
      align-items: center;
    }

    &__services-grid {
      width: 100%;
      max-width: 1200px;
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(370px, 1fr));
      gap: 2.8rem;
      margin-bottom: 5rem;
    }

    &__history-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 1rem;
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

      &__history-grid {
        grid-template-columns: 1fr;
      }

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
