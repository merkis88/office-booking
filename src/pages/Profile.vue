<script setup>
  import { ref, onMounted, watch } from 'vue';
  import { useAuthStore } from '@/store/auth';
  import { useBookingsStore } from '@/store/bookings';
  import { storeToRefs } from 'pinia';
  import { useRouter } from 'vue-router';
  import QRCode from 'qrcode';

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
  const router = useRouter();
  const { user } = storeToRefs(authStore);

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

      // data.data = ["string", "string"]
      const images = await Promise.all(data.data.map((qrString) => QRCode.toDataURL(qrString)));

      qrImages.value = images;
    } catch (e) {
      console.error(e);
    }
  };

  const handleSave = async () => {
    try {
      // Заглушка запроса
      console.log('Отправка данных:', editableUser.value);

      // await authStore.updateUser(editableUser.value)

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
            <button class="profile__tab profile__tab--active">Активные аренды</button>
            <button class="profile__tab">Избранное</button>
            <button class="profile__tab">История аренды</button>
            <button class="profile__tab">Заявки</button>
          </div>

          <div class="profile__bottom-content">
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
      padding: 0.75rem 2rem;
      border-radius: $radius-sm;
      border: 1px solid $color-border;
      background: $color-input-bg;
      font-size: $text-base;
      transition: 0.2s;

      &:hover {
        background: $color-input-bg-dark;
      }

      &--active {
        background: white;
      }
    }

    &__bottom-content {
      display: flex;
      justify-content: center;
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
    }
  }
</style>
