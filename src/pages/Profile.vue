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
  import defaultAvatar from '@/assets/images/photos/default-avatar.png';
  import qrPlaceholder from '@/assets/images/photos/qr-placeholder.png';

  const authStore = useAuthStore();
  const bookingsStore = useBookingsStore();
  const servicesStore = useServicesStore();
  const favoritesStore = useFavoritesStore();
  const router = useRouter();
  const BOOKINGS_PER_PAGE = 3;

  onMounted(() => {
    bookingsStore.fetchBookings();
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

  const fileInput = ref(null);
  const isUploadingPhoto = ref(false);

  const handleFileChange = async (event) => {
    const file = event.target.files[0];
    if (!file) return;

    if (file.size > 5 * 1024 * 1024) {
      alert('Файл больше 5MB');
      return;
    }

    await uploadPhoto(file);

    event.target.value = '';
  };

  const uploadPhoto = async (file) => {
    isUploadingPhoto.value = true;

    try {
      await authStore.uploadProfilePhoto(file);
    } catch (error) {
      if (error.response?.status === 422) {
        alert('Некорректный файл');
      } else {
        alert('Ошибка загрузки фото');
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
    let bookings = bookingsStore.bookings.filter((b) => b.status !== 'cancelled');
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
        <div class="profile__avatar-col">
          <div class="profile__avatar-wrapper">
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
      </div>

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

          <div v-else-if="!filteredBookings.length" class="profile__empty">
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

          <div v-if="bookingsTotalPages > 1" class="profile__services-pagination">
            <button
              class="profile__pagination-btn"
              :disabled="bookingsCurrentPage === 1"
              @click="goToBookingsPage(bookingsCurrentPage - 1)"
            >
              <img src="@/assets/images/icons/arrow-left.svg" alt="Назад" />
            </button>

            <button
              v-for="page in bookingsTotalPages"
              :key="page"
              class="profile__pagination-number"
              :class="{ 'profile__pagination-number--active': bookingsCurrentPage === page }"
              @click="goToBookingsPage(page)"
            >
              {{ page }}
            </button>

            <button
              class="profile__pagination-btn"
              :disabled="bookingsCurrentPage === bookingsTotalPages"
              @click="goToBookingsPage(bookingsCurrentPage + 1)"
            >
              <img src="@/assets/images/icons/arrow-right.svg" alt="Вперед" />
            </button>
          </div>
        </div>

        <div v-if="activeTab === 1" class="profile__bottom-content">
          <div v-if="favoritesStore.isLoading" class="profile__loading">Загрузка...</div>

          <div v-else-if="!favoritesStore.favorites.length" class="profile__empty">
            <p>У вас нет избранных помещений</p>
            <p class="profile__empty-hint">
              Добавляйте помещения в избранное, нажимая на сердечко на карточке
            </p>
          </div>

          <div v-else class="profile__favorites-grid">
            <PlaceCard v-for="place in favoritesStore.favorites" :key="place.id" :place="place" />
          </div>
        </div>

        <div v-if="activeTab === 2" class="profile__bottom-content">
          <div class="profile__empty">
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
            <ServiceRequestCard v-for="service in services" :key="service.id" :service="service" />
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
    padding: 2.5rem 2rem 4rem;
    background: $color-bg;

    &__wrapper {
      @include container;
      display: flex;
      flex-direction: column;
      gap: 2rem;
    }

    &__empty {
      padding: 3rem 1rem;
      text-align: center;
      color: rgba($color-text, 0.6);
      font-size: $text-lg;

      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;

      width: 100%;
    }

    &__header-card {
      display: grid;
      grid-template-columns: 30% 1fr;
      gap: 2rem;
      padding: 2rem 3rem;
      background: $color-header-bg;
      border-radius: 1.25rem; // 20px
      border: none;
    }

    &__avatar-col {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 1rem;
    }

    &__right-col {
      display: flex;
      flex-direction: column;
      justify-content: flex-start;
      gap: 1.5rem;
      align-items: stretch;
    }

    &__avatar-wrapper {
      width: 300px;
      height: 300px;
      border-radius: 50%;
      overflow: hidden;
      box-shadow: none;
    }

    &__avatar {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    &__upload-btn {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      gap: 0.75rem;
      padding: 0.55rem 1.2rem;
      border-radius: 0.625rem; // 10px
      border: 1px solid $color-border;
      background: rgba(230, 242, 250, 0.7);
      font-size: $text-base;
      cursor: pointer;
      opacity: 1;
      transition: all 0.2s ease;

      img {
        width: 1.25rem;
        height: 1.25rem;
      }

      &:hover {
        background: rgba(209, 223, 232, 0.95);
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
      transition: 0.2s;

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
      background: rgba(255, 255, 255, 0.7);
      border-radius: 1.25rem; // 20px
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
      background: rgba(230, 242, 250, 0.7);
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

    &__error {
      color: #c0392b;
      font-size: $text-base;
      text-align: center;
      margin-top: 0.5rem;
    }

    &__btn {
      width: 180px;
      padding: 0.55rem 0;
      border-radius: 0.625rem; // 10px
      font-size: $text-base;
      font-weight: 500;
      transition: all 0.3s ease;
      border: 1px solid $color-border;
      background: rgba(230, 242, 250, 0.7);
      color: $color-text;
      cursor: pointer;
      text-decoration: none;
      text-align: center;

      &:hover {
        box-shadow: none;
        transform: none;
        background: rgba(209, 223, 232, 0.95);
      }

      &:active {
        transform: none;
        box-shadow: none;
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
      background: rgba(230, 242, 250, 0.7);
      border-radius: 0.625rem; // 10px
      font-size: 1.125rem; // 18px
      font-weight: 500;
      cursor: pointer;
      transition: all 0.2s;
      white-space: nowrap;
      display: flex;
      align-items: center;
      justify-content: center;

      &:hover {
        background: rgba(209, 223, 232, 0.95);
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
      border-radius: 0.625rem;
      border: 1px solid $color-border;
      background: none;
      font-size: 1.125rem;
      cursor: pointer;
      transition: all 0.2s;
      display: flex;
      align-items: center;
      justify-content: center;

      &:hover {
        background: rgba(255, 255, 255, 0.7);
      }
      &--active {
        background: rgba(255, 255, 255, 0.7);
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

    &__pagination {
      display: flex;
      justify-content: center;
      gap: 0.5rem;
      margin-top: 2rem;
    }

    &__page-btn {
      width: 40px;
      height: 40px;
      padding: 0;
      border-radius: 0.625rem; // 10px
      border: 1px solid $color-border;
      background: rgba(230, 242, 250, 0.7);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 1.25rem; // 20px
      font-weight: 500;

      &.active {
        background: rgba(124, 143, 160, 0.5);
      }

      &--arrow {
        img {
          width: 1.6rem;
          height: 1.6rem;
        }
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
      width: 100%;
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
