<script setup>
  import { ref, onMounted, onBeforeUnmount, computed, watch } from 'vue';
  import { useServicesStore } from '@/store/services';
  import { storeToRefs } from 'pinia';
  import DatePickerInput from '@/components/DatePickerInput.vue';
  import RequestConfirmModal from '@/components/modals/RequestConfirmModal.vue';

  const servicesStore = useServicesStore();
  const {
    bookings,
    isLoading: isLoadingBookings,
    error,
    successMessage,
  } = storeToRefs(servicesStore);

  const bookingList = ref(null);
  const bookingLabel = ref('');
  const showBookingDropdown = ref(false);

  const selectedDate = ref('');
  const selectedTime = ref(null);
  const selectedTimeLabel = ref('');
  const showTimeDropdown = ref(false);

  const requestType = ref(null);
  const requestTypeLabel = ref('');
  const comment = ref('');
  const isSubmitting = ref(false);
  const showRequestTypeDropdown = ref(false);

  const showConfirmModal = ref(false);
  const pendingRequestData = ref(null);

  const validationError = ref('');

  const requestTypes = [
    { id: 1, label: 'Клининг' },
    { id: 2, label: 'Техобслуживание' },
  ];

  const timeSlots = computed(() => {
    const slots = [];
    for (let hour = 9; hour < 19; hour++) {
      const startTime = `${hour.toString().padStart(2, '0')}:00`;
      const endTime = `${((hour + 1) % 24).toString().padStart(2, '0')}:00`;
      slots.push({
        value: startTime,
        label: `${startTime} - ${endTime}`,
      });
    }
    return slots;
  });

  function clearErrors() {
    validationError.value = '';
    servicesStore.clearMessages();
  }

  watch(selectedDate, (val) => {
    if (val) clearErrors();
  });

  async function loadBookings() {
    await servicesStore.fetchMyBookings();
  }

  function selectBooking(booking) {
    bookingList.value = booking.id;
    bookingLabel.value = `${booking.place_name} №${booking.place_number}`;
    showBookingDropdown.value = false;
    clearErrors();
  }

  function toggleBookingDropdown() {
    showBookingDropdown.value = !showBookingDropdown.value;
    showTimeDropdown.value = false;
    showRequestTypeDropdown.value = false;
  }

  function selectTime(timeSlot) {
    selectedTime.value = timeSlot.value;
    selectedTimeLabel.value = timeSlot.label;
    showTimeDropdown.value = false;
    clearErrors();
  }

  function toggleTimeDropdown() {
    showTimeDropdown.value = !showTimeDropdown.value;
    showBookingDropdown.value = false;
    showRequestTypeDropdown.value = false;
  }

  function selectRequestType(type) {
    requestType.value = type.id;
    requestTypeLabel.value = type.label;
    showRequestTypeDropdown.value = false;
    clearErrors();
  }

  function toggleRequestTypeDropdown() {
    showRequestTypeDropdown.value = !showRequestTypeDropdown.value;
    showBookingDropdown.value = false;
    showTimeDropdown.value = false;
  }

  function handleClickOutside(event) {
    const bookingDropdown = document.querySelector('.requests__dropdown--booking');
    const bookingInput = document.querySelector('.requests__booking-input');
    const timeDropdown = document.querySelector('.requests__dropdown--time-select');
    const timeInput = document.querySelector('.requests__time-input');
    const typeDropdown = document.querySelector('.requests__dropdown--type');
    const typeInput = document.querySelector('.requests__request-type-input');

    if (
      bookingDropdown &&
      !bookingDropdown.contains(event.target) &&
      !bookingInput?.contains(event.target)
    ) {
      showBookingDropdown.value = false;
    }

    if (
      timeDropdown &&
      !timeDropdown.contains(event.target) &&
      !timeInput?.contains(event.target)
    ) {
      showTimeDropdown.value = false;
    }

    if (
      typeDropdown &&
      !typeDropdown.contains(event.target) &&
      !typeInput?.contains(event.target)
    ) {
      showRequestTypeDropdown.value = false;
    }
  }

  onMounted(() => {
    loadBookings();
    document.addEventListener('click', handleClickOutside);
  });

  onBeforeUnmount(() => {
    document.removeEventListener('click', handleClickOutside);
    servicesStore.clearMessages();
  });

  function handleDateUpdate(value) {
    selectedDate.value = value;
  }

  function handleSubmit() {
    clearErrors();

    if (!bookingList.value) {
      validationError.value = 'Выберите бронирование';
      return;
    }

    if (!selectedDate.value) {
      validationError.value = 'Выберите дату';
      return;
    }

    if (!selectedTime.value) {
      validationError.value = 'Выберите время';
      return;
    }

    if (!requestType.value) {
      validationError.value = 'Выберите тип заявки';
      return;
    }

    pendingRequestData.value = {
      booking_id: bookingList.value,
      booking_label: bookingLabel.value,
      service_type_id: requestType.value,
      service_type_label: requestTypeLabel.value,
      service_date: selectedDate.value,
      service_time: selectedTime.value,
      comment: comment.value || null,
    };

    showConfirmModal.value = true;
  }

  async function handleConfirmRequest() {
    if (!pendingRequestData.value) return;

    isSubmitting.value = true;
    showConfirmModal.value = false;

    try {
      const result = await servicesStore.createServiceRequest(pendingRequestData.value);

      if (result.success) {
        bookingList.value = null;
        bookingLabel.value = '';
        selectedDate.value = '';
        selectedTime.value = null;
        selectedTimeLabel.value = '';
        requestType.value = null;
        requestTypeLabel.value = '';
        comment.value = '';
        pendingRequestData.value = null;

        setTimeout(() => {
          servicesStore.clearMessages();
        }, 5000);
      }
    } catch (err) {
      console.log(err);
    } finally {
      isSubmitting.value = false;
    }
  }

  function handleCancelRequest() {
    showConfirmModal.value = false;
    pendingRequestData.value = null;
  }
</script>

<template>
  <div class="requests">
    <div class="requests__container">
      <h1 class="requests__title">Заявки</h1>

      <div class="requests__content">
        <div class="requests__image">
          <img src="/men-request.png" alt="Заявки" />
        </div>

        <div class="requests__form-wrapper">
          <form class="requests__form" @submit.prevent="handleSubmit">
            <div v-if="successMessage" class="requests__success">
              <div class="requests__success-icon">✓</div>
              <div class="requests__success-text">{{ successMessage }}</div>
              <button class="requests__success-close" @click="servicesStore.clearMessages()">
                ✕
              </button>
            </div>

            <div v-if="error" class="requests__error">
              <div class="requests__error-icon">!</div>
              <div class="requests__error-text">{{ error }}</div>
              <button class="requests__error-close" @click="servicesStore.clearMessages()">
                ✕
              </button>
            </div>

            <div v-if="validationError" class="requests__validation-error">
              <div class="requests__validation-error-icon">!</div>
              <div class="requests__validation-error-text">{{ validationError }}</div>
              <button class="requests__validation-error-close" @click="clearErrors()">✕</button>
            </div>
            <div class="requests__field">
              <label class="requests__label">Список бронирований*</label>
              <div class="requests__select-wrapper">
                <div
                  class="requests__input-wrapper requests__booking-input"
                  @click="toggleBookingDropdown"
                >
                  <input
                    :value="bookingLabel"
                    type="text"
                    class="requests__input"
                    placeholder="Выберите бронь"
                    readonly
                  />
                  <img
                    src="/arrow-square-down.svg"
                    alt=""
                    class="requests__icon"
                    :class="{ 'requests__icon--rotate': showBookingDropdown }"
                  />
                </div>

                <Transition name="dropdown">
                  <div
                    v-if="showBookingDropdown"
                    class="requests__dropdown requests__dropdown--booking"
                  >
                    <div v-if="isLoadingBookings" class="requests__dropdown-loading">
                      Загрузка...
                    </div>
                    <div v-else-if="bookings.length === 0" class="requests__dropdown-empty">
                      У вас нет активных бронирований
                    </div>
                    <div
                      v-else
                      v-for="booking in bookings"
                      :key="booking.id"
                      class="requests__dropdown-item"
                      @click="selectBooking(booking)"
                    >
                      <div class="requests__booking-name">{{ booking.place_name }}</div>
                      <div class="requests__booking-details">
                        №{{ booking.place_number }} • {{ booking.date }} • {{ booking.time }}
                      </div>
                    </div>
                  </div>
                </Transition>
              </div>
            </div>

            <div class="requests__field">
              <label class="requests__label">Дата*</label>
              <DatePickerInput :model-value="selectedDate" @update:model-value="handleDateUpdate" />
            </div>

            <div class="requests__field">
              <label class="requests__label">Время*</label>
              <div class="requests__select-wrapper">
                <div
                  class="requests__input-wrapper requests__time-input"
                  @click="toggleTimeDropdown"
                >
                  <input
                    :value="selectedTimeLabel"
                    type="text"
                    class="requests__input"
                    placeholder="Выберите время"
                    readonly
                  />
                  <img
                    src="/arrow-square-down.svg"
                    alt=""
                    class="requests__icon"
                    :class="{ 'requests__icon--rotate': showTimeDropdown }"
                  />
                </div>

                <Transition name="dropdown">
                  <div
                    v-if="showTimeDropdown"
                    class="requests__dropdown requests__dropdown--time-select"
                  >
                    <div
                      v-for="timeSlot in timeSlots"
                      :key="timeSlot.value"
                      class="requests__dropdown-item"
                      @click="selectTime(timeSlot)"
                    >
                      {{ timeSlot.label }}
                    </div>
                  </div>
                </Transition>
              </div>
            </div>

            <div class="requests__field">
              <label class="requests__label">Тип заявки*</label>
              <div class="requests__select-wrapper">
                <div
                  class="requests__input-wrapper requests__request-type-input"
                  @click="toggleRequestTypeDropdown"
                >
                  <input
                    :value="requestTypeLabel"
                    type="text"
                    class="requests__input"
                    placeholder="Выберите тип заявки"
                    readonly
                  />
                  <img
                    src="/arrow-square-down.svg"
                    alt=""
                    class="requests__icon"
                    :class="{ 'requests__icon--rotate': showRequestTypeDropdown }"
                  />
                </div>

                <Transition name="dropdown">
                  <div
                    v-if="showRequestTypeDropdown"
                    class="requests__dropdown requests__dropdown--type"
                  >
                    <div
                      v-for="type in requestTypes"
                      :key="type.id"
                      class="requests__dropdown-item"
                      @click="selectRequestType(type)"
                    >
                      {{ type.label }}
                    </div>
                  </div>
                </Transition>
              </div>
            </div>

            <div class="requests__field">
              <label class="requests__label">Комментарий (необязательно)</label>
              <textarea
                v-model="comment"
                class="requests__textarea"
                placeholder="Введите комментарий"
                rows="3"
              ></textarea>
            </div>

            <button type="submit" class="requests__submit" :disabled="isSubmitting">
              {{ isSubmitting ? 'Отправка...' : 'Отправить заявку' }}
            </button>
          </form>
        </div>
      </div>
    </div>

    <RequestConfirmModal
      :is-open="showConfirmModal"
      :request-data="pendingRequestData || {}"
      @confirm="handleConfirmRequest"
      @cancel="handleCancelRequest"
      @close="handleCancelRequest"
    />
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;
  @use '@/assets/styles/mixins' as *;

  .requests {
    min-height: 100vh;
    padding: 4rem 2rem;

    &__container {
      @include container;
    }

    &__title {
      font-family: $font-title;
      font-size: $text-3xl;
      font-weight: 500;
      color: $color-text;
      text-align: center;
      margin-bottom: 3rem;
    }

    &__success {
      max-width: 1200px;
      margin: 0 auto 2rem;
      padding: 1rem 1.5rem;
      background: rgba(46, 204, 113, 0.1);
      border: 1px solid #2ecc71;
      border-radius: $radius-sm;
      display: flex;
      align-items: center;
      gap: 1rem;
      animation: slideDown 0.3s ease;
    }

    &__success-icon {
      width: 2rem;
      height: 2rem;
      background: #2ecc71;
      color: white;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 600;
      flex-shrink: 0;
    }

    &__success-text {
      flex: 1;
      color: #27ae60;
      font-weight: 500;
    }

    &__success-close {
      background: transparent;
      border: none;
      color: #27ae60;
      font-size: 1.5rem;
      cursor: pointer;
      padding: 0.25rem 0.5rem;
      line-height: 1;
      transition: opacity 0.2s;

      &:hover {
        opacity: 0.7;
      }
    }

    &__error {
      max-width: 1200px;
      margin: 0 auto 2rem;
      padding: 1rem 1.5rem;
      background: rgba(231, 76, 60, 0.1);
      border: 1px solid #e74c3c;
      border-radius: $radius-sm;
      display: flex;
      align-items: center;
      gap: 1rem;
      animation: slideDown 0.3s ease;
    }

    &__error-icon {
      width: 2rem;
      height: 2rem;
      background: #e74c3c;
      color: white;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 600;
      flex-shrink: 0;
    }

    &__error-text {
      flex: 1;
      color: #c0392b;
      font-weight: 500;
    }

    &__error-close {
      background: transparent;
      border: none;
      color: #c0392b;
      font-size: 1.5rem;
      cursor: pointer;
      padding: 0.25rem 0.5rem;
      line-height: 1;
      transition: opacity 0.2s;

      &:hover {
        opacity: 0.7;
      }
    }

    &__validation-error {
      max-width: 1200px;
      margin: 0 auto 2rem;
      padding: 1rem 1.5rem;
      background: rgba(255, 193, 7, 0.1);
      border: 1px solid #ffc107;
      border-radius: $radius-sm;
      display: flex;
      align-items: center;
      gap: 1rem;
      animation: slideDown 0.3s ease;
    }

    &__validation-error-icon {
      width: 2rem;
      height: 2rem;
      background: #ffc107;
      color: white;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 600;
      flex-shrink: 0;
    }

    &__validation-error-text {
      flex: 1;
      color: #f57c00;
      font-weight: 500;
    }

    &__validation-error-close {
      background: transparent;
      border: none;
      color: #f57c00;
      font-size: 1.5rem;
      cursor: pointer;
      padding: 0.25rem 0.5rem;
      line-height: 1;
      transition: opacity 0.2s;

      &:hover {
        opacity: 0.7;
      }
    }

    &__content {
      display: flex;
      gap: 2rem;
      background: $color-bg-request;
      border-radius: $radius-lg;
      overflow: hidden;
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
      max-width: 1200px;
      margin: 0 auto;
    }

    &__image {
      flex: 1;
      position: relative;
      background: linear-gradient(135deg, #fbd3a2 0%, #f8a5a5 50%, #7c8fa0 100%);
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 3rem;

      img {
        max-width: 100%;
        max-height: 500px;
        object-fit: contain;
        z-index: 2;
      }
    }

    &__form-wrapper {
      flex: 1;
      padding: 3rem;
      display: flex;
      align-items: center;
    }

    &__form {
      width: 100%;
      display: flex;
      flex-direction: column;
      gap: 1.5rem;
      align-items: center;
    }

    &__field {
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
      position: relative;
    }

    &__label {
      font-size: $text-sm;
      color: $color-text;
      font-weight: 500;
    }

    &__input-wrapper {
      position: relative;
      display: flex;
      align-items: center;
      cursor: pointer;
    }

    &__select-wrapper {
      position: relative;
      width: 30rem;
    }

    &__input {
      width: 30rem;
      padding: 0.875rem 3rem 0.875rem 1.25rem;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      background: $color-btn-profile;
      font-size: $text-base;
      color: $color-text;
      outline: none;
      transition: all 0.2s;

      &:focus {
        border-color: $color-text;
        box-shadow: 0 0 0 3px rgba($color-text, 0.1);
      }

      &::placeholder {
        color: rgba($color-text, 0.5);
      }

      &[readonly] {
        cursor: pointer;
      }
    }

    &__icon {
      position: absolute;
      right: 1rem;
      width: 1.75rem;
      height: 1.75rem;
      pointer-events: none;
      transition: transform 0.2s;

      &--rotate {
        transform: rotate(180deg);
      }
    }

    &__dropdown {
      position: absolute;
      top: 100%;
      left: 0;
      right: 0;
      margin-top: 0.5rem;
      background: $color-card-bg;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
      z-index: 100;
      overflow: hidden;
      max-height: 300px;
      overflow-y: auto;

      &::-webkit-scrollbar {
        width: 8px;
      }

      &::-webkit-scrollbar-track {
        background: rgba($color-border, 0.3);
      }

      &::-webkit-scrollbar-thumb {
        background: rgba($color-text, 0.3);
        border-radius: 4px;

        &:hover {
          background: rgba($color-text, 0.5);
        }
      }
    }

    &__dropdown-item {
      padding: 0.875rem 1.25rem;
      cursor: pointer;
      transition: all 0.2s;
      font-size: $text-base;
      color: $color-text;

      &:hover {
        background: rgba($color-text, 0.05);
      }
    }

    &__booking-name {
      font-weight: 600;
      margin-bottom: 0.25rem;
    }

    &__booking-details {
      font-size: $text-sm;
      color: rgba($color-text, 0.7);
    }

    &__dropdown-loading,
    &__dropdown-empty {
      padding: 1.5rem 1.25rem;
      text-align: center;
      color: rgba($color-text, 0.6);
      font-size: $text-sm;
    }

    &__textarea {
      width: 30rem;
      padding: 0.875rem 1.25rem;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      background: $color-btn-profile;
      font-size: $text-base;
      color: $color-text;
      font-family: $font-base;
      resize: vertical;
      outline: none;
      transition: all 0.2s;

      &:focus {
        border-color: $color-text;
        box-shadow: 0 0 0 3px rgba($color-text, 0.1);
      }

      &::placeholder {
        color: rgba($color-text, 0.5);
      }
    }

    &__submit {
      padding: 1rem 2rem;
      background: $color-btn-profile;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      font-size: $text-base;
      color: $color-text;
      cursor: pointer;
      transition: all 0.2s;
      margin-top: 1rem;
      max-width: 20rem;

      &:hover:not(:disabled) {
        background: $color-input-bg-dark;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        transform: translateY(-2px);
      }

      &:active:not(:disabled) {
        transform: translateY(0);
      }

      &:disabled {
        opacity: 0.6;
        cursor: not-allowed;
      }
    }

    @media (max-width: 1024px) {
      &__content {
        flex-direction: column;
      }

      &__image {
        min-height: 300px;

        img {
          max-height: 300px;
        }
      }

      &__form-wrapper {
        padding: 2rem;
      }
    }

    @media (max-width: 768px) {
      padding: 2rem 1rem;

      &__title {
        font-size: $text-2xl;
        margin-bottom: 2rem;
      }

      &__image {
        display: none;
      }

      &__form-wrapper {
        padding: 1.5rem;
      }

      &__input,
      &__textarea,
      &__select-wrapper {
        width: 100%;
      }
    }
  }

  @keyframes slideDown {
    from {
      opacity: 0;
      transform: translateY(-20px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  .dropdown-enter-active {
    animation: dropdown-in 0.2s ease-out;
  }

  .dropdown-leave-active {
    animation: dropdown-out 0.2s ease-in;
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
