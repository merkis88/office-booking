<script setup>
  import { ref, reactive } from 'vue';
  import { useRouter } from 'vue-router';
  import { usePlacesStore } from '@/store/places';

  const router = useRouter();
  const placesStore = usePlacesStore();

  const placeTypeOptions = [
    { value: 'office', label: 'Офис' },
    { value: 'coworking', label: 'Коворкинг' },
    { value: 'meeting', label: 'Переговорная' },
  ];

  const showTypeDropdown = ref(false);

  const name = ref('');
  const placeType = ref('');
  const cabinetNumber = ref('');
  const capacity = ref('');
  const price = ref('');
  const description = ref('');
  const isActive = ref(true);
  const photo = ref(null);
  const photoName = ref('');

  const isLoading = ref(false);
  const isSuccess = ref(false);
  const serverError = ref('');

  const errors = reactive({
    name: '',
    type: '',
    capacity: '',
    number_place: '',
    price: '',
    description: '',
    photo: '',
  });

  function clearErrors() {
    errors.name = '';
    errors.type = '';
    errors.capacity = '';
    errors.number_place = '';
    errors.price = '';
    errors.description = '';
    errors.photo = '';
    serverError.value = '';
  }

  function validateForm() {
    clearErrors();
    let isValid = true;

    if (!name.value.trim()) {
      errors.name = 'Введите название помещения';
      isValid = false;
    }

    if (!placeType.value) {
      errors.type = 'Выберите тип помещения';
      isValid = false;
    }

    if (!capacity.value && capacity.value !== 0) {
      errors.capacity = 'Введите вместимость';
      isValid = false;
    } else if (Number(capacity.value) <= 0 || !Number.isInteger(Number(capacity.value))) {
      errors.capacity = 'Вместимость должна быть положительным целым числом';
      isValid = false;
    }

    if (!cabinetNumber.value && cabinetNumber.value !== 0) {
      errors.number_place = 'Введите номер кабинета';
      isValid = false;
    } else if (Number(cabinetNumber.value) <= 0 || !Number.isInteger(Number(cabinetNumber.value))) {
      errors.number_place = 'Номер кабинета должен быть положительным целым числом';
      isValid = false;
    }

    if (!price.value && price.value !== 0) {
      errors.price = 'Введите стоимость';
      isValid = false;
    } else if (Number(price.value) < 0) {
      errors.price = 'Стоимость не может быть отрицательной';
      isValid = false;
    }

    if (!description.value.trim()) {
      errors.description = 'Введите описание помещения';
      isValid = false;
    }

    if (!photo.value) {
      errors.photo = 'Загрузите фотографию';
      isValid = false;
    }

    return isValid;
  }

  function onFileChange(event) {
    const file = event.target.files[0];
    if (file) {
      photo.value = file;
      photoName.value = file.name;
      errors.photo = '';
    }
  }

  async function handleCreate() {
    if (!validateForm()) return;

    isLoading.value = true;
    isSuccess.value = false;
    serverError.value = '';

    const result = await placesStore.createPlace({
      name: name.value.trim(),
      type: placeType.value,
      capacity: Number(capacity.value),
      number_place: Number(cabinetNumber.value),
      price: Number(price.value),
      description: description.value.trim(),
      is_active: isActive.value,
      photo: photo.value,
    });

    isLoading.value = false;

    if (result.success) {
      isSuccess.value = true;
      resetForm();
      setTimeout(() => {
        isSuccess.value = false;
      }, 4000);
    } else {
      if (result.errors) {
        Object.keys(result.errors).forEach((key) => {
          if (errors.hasOwnProperty(key)) {
            errors[key] = Array.isArray(result.errors[key])
              ? result.errors[key][0]
              : result.errors[key];
          }
        });
      }
      serverError.value = result.error || 'Произошла ошибка при создании помещения';
    }
  }

  function getTypeLabel(value) {
    const option = placeTypeOptions.find((o) => o.value === value);
    return option ? option.label : 'Выберите тип помещения';
  }

  function selectType(value) {
    placeType.value = value;
    showTypeDropdown.value = false;
    errors.type = '';
  }

  function resetForm() {
    name.value = '';
    placeType.value = '';
    cabinetNumber.value = '';
    capacity.value = '';
    price.value = '';
    description.value = '';
    isActive.value = true;
    photo.value = null;
    photoName.value = '';
    showTypeDropdown.value = false;
    clearErrors();
  }
</script>

<template>
  <div class="create-place">
    <div class="create-place__wrapper">
      <div class="create-place__form-section">
        <h1 class="create-place__title">Создание помещения</h1>

        <div v-if="isSuccess" class="create-place__success">
          <span class="create-place__success-icon">✓</span>
          Помещение успешно создано!
        </div>

        <div v-if="serverError" class="create-place__server-error">
          {{ serverError }}
        </div>

        <form class="create-place__form" @submit.prevent="handleCreate">
          <div class="create-place__field">
            <label class="create-place__label">Название*</label>
            <input
              v-model="name"
              type="text"
              class="create-place__input"
              :class="{ 'create-place__input--error': errors.name }"
              placeholder="Введите название помещения"
            />
            <span v-if="errors.name" class="create-place__error">{{ errors.name }}</span>
          </div>

          <div class="create-place__field">
            <label class="create-place__label">Тип помещения*</label>
            <div class="create-place__dropdown-wrapper">
              <button
                type="button"
                class="create-place__dropdown-btn"
                :class="{
                  'create-place__dropdown-btn--error': errors.type,
                  'create-place__dropdown-btn--placeholder': !placeType,
                }"
                @click="showTypeDropdown = !showTypeDropdown"
              >
                <span>{{ getTypeLabel(placeType) }}</span>
              </button>

              <transition name="dropdown">
                <div v-if="showTypeDropdown" class="create-place__dropdown">
                  <div
                    v-for="option in placeTypeOptions"
                    :key="option.value"
                    class="create-place__dropdown-item"
                    :class="{ 'create-place__dropdown-item--active': placeType === option.value }"
                    @click="selectType(option.value)"
                  >
                    {{ option.label }}
                  </div>
                </div>
              </transition>
            </div>
            <span v-if="errors.type" class="create-place__error">{{ errors.type }}</span>
          </div>

          <div class="create-place__field">
            <label class="create-place__label">Кабинет №*</label>
            <input
              v-model="cabinetNumber"
              type="number"
              class="create-place__input"
              :class="{ 'create-place__input--error': errors.number_place }"
              placeholder="Введите номер кабинета"
            />
            <span v-if="errors.number_place" class="create-place__error">
              {{ errors.number_place }}
            </span>
          </div>

          <div class="create-place__field">
            <label class="create-place__label">Вместимость*</label>
            <input
              v-model="capacity"
              type="number"
              class="create-place__input"
              :class="{ 'create-place__input--error': errors.capacity }"
              placeholder="Вместимость человек в помещении"
            />
            <span v-if="errors.capacity" class="create-place__error">{{ errors.capacity }}</span>
          </div>

          <div class="create-place__field">
            <label class="create-place__label">Стоимость*</label>
            <input
              v-model="price"
              type="number"
              step="0.01"
              class="create-place__input"
              :class="{ 'create-place__input--error': errors.price }"
              placeholder="Введите стоимость помещения"
            />
            <span v-if="errors.price" class="create-place__error">{{ errors.price }}</span>
          </div>

          <div class="create-place__field">
            <label class="create-place__label">Описание*</label>
            <textarea
              v-model="description"
              class="create-place__input create-place__textarea"
              :class="{ 'create-place__input--error': errors.description }"
              placeholder="Введите описание помещения"
              rows="3"
            ></textarea>
            <span v-if="errors.description" class="create-place__error">
              {{ errors.description }}
            </span>
          </div>

          <div class="create-place__field">
            <label class="create-place__label">Фотография*</label>
            <div class="create-place__file-wrapper">
              <input
                type="file"
                accept="image/*"
                class="create-place__file-input"
                @change="onFileChange"
              />
              <div
                class="create-place__file-display"
                :class="{ 'create-place__file-display--error': errors.photo }"
              >
                <span class="create-place__file-text">
                  {{ photoName || 'Загрузите изображение' }}
                </span>
                <img src="@/assets/images/icons/folder-cloud.svg" alt="upload" class="create-place__file-icon" />
              </div>
            </div>
            <span v-if="errors.photo" class="create-place__error">{{ errors.photo }}</span>
          </div>

          <button type="submit" class="create-place__submit" :disabled="isLoading">
            <span v-if="isLoading" class="create-place__spinner"></span>
            <span v-else>Создать</span>
          </button>
        </form>
      </div>

      <div class="create-place__image-section">
        <img src="@/assets/images/photos/man-create_place.png" alt="Иллюстрация" class="create-place__illustration" />
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;

  .create-place {
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: calc(100vh - 80px);

    &__wrapper {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 10rem;
      max-width: 1000px;
      width: 100%;
    }

    &__form-section {
      flex: 1;
      max-width: 600px;
      background: $color-footer-bg;
      padding: 2rem 5rem;
      border-radius: $radius-sm;
    }

    &__title {
      font-family: $font-title;
      font-size: 28px;
      font-weight: 400;
      color: $color-text;
      margin-bottom: 28px;
    }

    &__success {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 12px 16px;
      background: #d4edda;
      border: 1px solid #c3e6cb;
      border-radius: $radius-xs;
      color: #155724;
      font-family: $font-base;
      font-size: 14px;
      font-weight: 500;
      margin-bottom: 16px;
      animation: fadeIn 0.3s ease;
    }

    &__success-icon {
      font-size: 18px;
      font-weight: 700;
    }

    &__server-error {
      padding: 12px 16px;
      background: #f8d7da;
      border: 1px solid #f5c6cb;
      border-radius: $radius-xs;
      color: #721c24;
      font-family: $font-base;
      font-size: 14px;
      margin-bottom: 16px;
      animation: fadeIn 0.3s ease;
    }

    &__form {
      display: flex;
      flex-direction: column;
      gap: 16px;
    }

    &__field {
      display: flex;
      flex-direction: column;
      gap: 6px;

      &--checkbox {
        flex-direction: row;
        align-items: center;
      }
    }

    &__label {
      font-family: $font-base;
      font-size: 14px;
      font-weight: 500;
      color: $color-text;
    }

    &__input {
      width: 100%;
      padding: 12px 16px;
      background: $color-input-bg;
      border: solid 1px $color-text;
      border-radius: $radius-xs;
      font-family: $font-base;
      font-size: 14px;
      color: $color-text;
      outline: none;
      transition: border-color 0.2s;
      box-sizing: border-box;

      &::placeholder {
        color: rgba(0, 0, 0, 0.5);
      }


      &--error {
        border-color: #dc3545;
      }
    }

    /* Hide number input spinners */
    input[type='number'] {
      -moz-appearance: textfield;

      &::-webkit-outer-spin-button,
      &::-webkit-inner-spin-button {
        -webkit-appearance: none;
        margin: 0;
      }
    }

    &__dropdown-wrapper {
      position: relative;
    }

    &__dropdown-btn {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      width: 100%;
      padding: 0.75rem 1.25rem;
      background: $color-input-bg;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      cursor: pointer;
      transition: all 0.2s;
      font-size: $text-base;
      color: $color-text;
      font-family: $font-base;
      box-sizing: border-box;
      text-align: left;

      &--placeholder {
        color: rgba(0, 0, 0, 0.5);
      }

      &--error {
        border-color: #dc3545;
      }

      &:hover {
        background: $color-input-bg;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
      }
    }

    &__dropdown-icon {
      width: 20px;
      height: 20px;
    }

    &__dropdown {
      position: absolute;
      top: 100%;
      left: 0;
      right: 0;
      margin-top: 0.5rem;
      background: $color-input-bg;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
      z-index: 100;
      overflow: hidden;
    }

    &__dropdown-item {
      padding: 0.875rem 1.25rem;
      cursor: pointer;
      transition: all 0.2s;
      color: $color-text;
      font-family: $font-base;
      font-size: $text-base;

      &:hover {
        background: rgba($color-text, 0.05);
      }

      &--active {
        background: rgba($color-text, 0.08);
        font-weight: 500;
      }
    }

    &__textarea {
      resize: vertical;
      min-height: 70px;
    }

    &__error {
      font-family: $font-base;
      font-size: 12px;
      color: #dc3545;
      font-weight: 500;
    }

    &__checkbox-label {
      display: flex;
      align-items: center;
      gap: 8px;
      font-family: $font-base;
      font-size: 14px;
      color: $color-text;
      cursor: pointer;
    }

    &__checkbox {
      width: 18px;
      height: 18px;
      cursor: pointer;
    }

    &__file-wrapper {
      position: relative;
      cursor: pointer;
    }

    &__file-input {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      opacity: 0;
      cursor: pointer;
      z-index: 2;
    }

    &__file-display {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 12px 16px;
      background: $color-input-bg;
      border: solid 1px $color-text;
      border-radius: $radius-xs;
      font-family: $font-base;
      font-size: 14px;
      color: rgba(0, 0, 0, 0.5);

      &--error {
        border-color: #dc3545;
      }
    }

    &__file-text {
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
      flex: 1;
    }

    &__file-icon {
      width: 20px;
      height: 20px;
      opacity: 0.6;
      margin-left: 8px;
      flex-shrink: 0;
    }

    &__submit {
      align-self: center;
      padding: 0.6rem 3rem;
      background: $color-input-bg;
      border: solid 1px $color-text;
      border-radius: $radius-xs;
      font-family: $font-base;
      font-size: 16px;
      font-weight: 500;
      color: $color-text;
      cursor: pointer;
      transition:
        background 0.2s,
        transform 0.1s;
      margin-top: 8px;
      min-width: 140px;
      min-height: 42px;
      display: flex;
      align-items: center;
      justify-content: center;


      &:active:not(:disabled) {
        transform: scale(0.98);
      }

      &:disabled {
        opacity: 0.7;
        cursor: not-allowed;
      }
    }

    &__spinner {
      width: 20px;
      height: 20px;
      border: 2px solid rgba(0, 0, 0, 0.2);
      border-top-color: $color-text;
      border-radius: 50%;
      animation: spin 0.7s linear infinite;
    }

    &__image-section {
      flex-shrink: 0;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    &__illustration {
      max-height: 600px;
      width: auto;
      object-fit: contain;
    }

    @media (max-width: 768px) {
      &__wrapper {
        flex-direction: column;
        gap: 30px;
      }

      &__form-section {
        max-width: 100%;
      }

      &__image-section {
        display: none;
      }
    }
  }

  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }

  @keyframes fadeIn {
    from {
      opacity: 0;
      transform: translateY(-8px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  .dropdown-enter-active,
  .dropdown-leave-active {
    transition:
      opacity 0.2s ease,
      transform 0.2s ease;
  }

  .dropdown-enter-from,
  .dropdown-leave-to {
    opacity: 0;
    transform: translateY(-8px);
  }
</style>
