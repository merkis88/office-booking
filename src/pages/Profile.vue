<script setup>
  import { ref, computed, onMounted, watch } from 'vue';
  import { useAuthStore } from '@/store/auth';
  import { useBookingsStore } from '@/store/bookings';
  import { useServicesStore } from '@/store/services';
  import { storeToRefs } from 'pinia';
  import { useRouter } from 'vue-router';
  import QRCode from 'qrcode';
  import ServiceRequestCard from '@/components/ServiceRequestCard.vue';

  onMounted(() => {
    bookingsStore.fetchMyBookings();
  });

  onMounted(async () => {
    const res = await fetch('/api/qr-data');
    const data = await res.json();

    qr.value = await QRCode.toDataURL(data.qrString);
  });

  const qrImages = ref([]);
  const authStore = useAuthStore();
  const bookingsStore = useBookingsStore();
  const servicesStore = useServicesStore();
  const router = useRouter();
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
    post: '',
    company: '',
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

    await fetchQrs();
  });

  watch(activeTab, (newTab) => {
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

  const fetchQrs = async () => {
    try {
      const res = await fetch('/api/profile/qrs', {
        headers: {
          Authorization: `Bearer ${authStore.token}`,
          Accept: 'application/json',
        },
      });

      if (!res.ok) {
        throw new Error('Ошибка загрузки QR');
      }

      const data = await res.json();

      const images = await Promise.all(data.data.map((qrString) => QRCode.toDataURL(qrString)));

      qrImages.value = images;
    } catch (e) {
      console.error(e);
    }
  };

  const handleSave = async () => {
    try {
      console.log('Отправка данных:', editableUser.value);

      user.value = { ...editableUser.value };

      isEditing.value = false;
    } catch (e) {
      console.error('Ошибка сохранения', e);
    }
  };

  const handleCancel = () => {
    editableUser.value = { ...user.value };
    isEditing.value = false;
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
          <img src="/avatar.png" alt="Фото профиля" class="profile__photo" />
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
                <input v-model="editableUser.post" class="profile__input" placeholder="Должность" />
              </div>

              <div class="profile__field">
                <input
                  v-model="editableUser.company"
                  class="profile__input"
                  placeholder="Компания"
                />
              </div>
            </div>
          </div>
        </div>

        <div class="profile__actions">
          <button class="profile__btn" @click="handleSave">Сохранить</button>

          <button class="profile__btn" @click="handleCancel">Не сохранять</button>
        </div>

        <div class="profile__pass-section">
          <h2 class="profile__section-title">Пропуск</h2>

          <div class="profile__pass-wrapper">
            <div class="profile__pass-card">
              <div class="profile__qr">
                <img
                  v-for="(qr, index) in qrImages"
                  :key="index"
                  :src="qr"
                  class="profile__qr-image"
                  alt="QR-код"
                />
              </div>

              <div class="profile__pass-info">
                <h3 class="profile__pass-title">Пропуск для сотрудника</h3>
                <p class="profile__pass-detail">Парковочное место №18</p>
                <p class="profile__pass-detail profile__pass-detail--expiry">
                  Ваш qr-код действует до 27.02.2026
                </p>
              </div>
            </div>

            <div class="profile__pass-actions">
              <button class="profile__btn profile__btn--action">Добавить парковку</button>
              <router-link to="/update-password" class="profile__btn profile__btn--action">
                Сменить пароль
              </router-link>
            </div>
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
            <div v-if="bookingsStore.isLoading">Загрузка...</div>

            <div
              v-else
              v-for="booking in bookingsStore.bookings"
              :key="booking.id"
              class="profile__booking-card"
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

                <p>Статус: {{ booking.status }}</p>
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
            <div class="profile__placeholder-card">
              <p>Избранное</p>
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
                <img src="/arrow-left.svg" alt="Назад" />
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
                <img src="/arrow-right.svg" alt="Вперед" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
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

      &--action {
        padding: 0.75rem 0.5rem;
        text-align: center;
        width: 70%;
      }
    }

    &__pass-section {
      margin-top: 2rem;
    }

    &__pass-wrapper {
      display: flex;
      gap: 2rem;
      align-items: center;
    }

    &__pass-card {
      flex: 1;
      display: flex;
      align-items: center;
      gap: 2rem;
      padding: 2rem;
      background: $color-card-bg;
      border: 1px solid $color-border;
      border-radius: $radius-lg;
    }

    &__qr {
      flex-shrink: 0;
      width: 8rem;
      height: 8rem;
      background: white;
      border: 2px solid $color-border;
      border-radius: $radius-sm;
      padding: 0.5rem;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    &__qr-image {
      width: 100%;
      height: 100%;
      object-fit: contain;
    }

    &__pass-info {
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
    }

    &__pass-title {
      font-size: $text-lg;
      font-weight: 600;
      color: $color-text;
      margin-bottom: 0.25rem;
    }

    &__pass-detail {
      font-size: $text-base;
      color: $color-text;
      line-height: 1.5;

      &--expiry {
        font-size: $text-sm;
        opacity: 0.8;
      }
    }

    &__pass-actions {
      display: flex;
      flex-direction: column;
      gap: 1rem;
      min-width: 20rem;
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

    &__booking-card {
      width: 60%;
      padding: 1.5rem;
      margin-bottom: 1.5rem;
      background: $color-card-bg;
      border-radius: $radius-lg;
      border: 1px solid $color-border;
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

      &__pass-wrapper {
        flex-direction: column;
      }

      &__pass-actions {
        min-width: 100%;
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

      &__pass-card {
        flex-direction: column;
        text-align: center;
      }

      &__pass-wrapper {
        flex-direction: column;
      }

      &__pass-actions {
        width: 100%;
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
