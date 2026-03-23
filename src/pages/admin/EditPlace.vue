<script setup>
  import { ref, reactive, onMounted } from 'vue';
  import { useRoute, useRouter } from 'vue-router';
  import { usePlacesStore } from '@/store/places';

  const route = useRoute();
  const router = useRouter();
  const placesStore = usePlacesStore();

  const placeId = parseInt(route.params.id, 10);

  const placeTypes = [
    { value: 'office', label: 'Офис' },
    { value: 'coworking', label: 'Коворкинг' },
    { value: 'meeting', label: 'Переговорная' },
  ];

  const form = reactive({
    name: '',
    type: '',
    number_place: '',
    capacity: '',
    price: '',
    description: '',
    is_active: true,
    photo: null,
    photoName: '',
  });

  const original = ref({});

  const showTypeDropdown = ref(false);
  const isLoading = ref(true);
  const isSaving = ref(false);
  const successMessage = ref('');
  const errorMessage = ref('');

  const errors = reactive({
    name: '',
    type: '',
    number_place: '',
    capacity: '',
    price: '',
    description: '',
  });

  onMounted(async () => {
    await loadPlace();
  });

  async function loadPlace() {
    isLoading.value = true;
    const result = await placesStore.fetchPlace(placeId);

    if (result.success) {
      const place = result.data;

      form.name = place.name || '';
      form.type = place.type || '';
      form.number_place = place.number_place || '';
      form.capacity = place.capacity || '';
      form.price = place.price || '';
      form.description = place.description || '';
      form.is_active = place.is_active !== undefined ? place.is_active : true;

      original.value = {
        name: form.name,
        type: form.type,
        number_place: String(form.number_place),
        capacity: String(form.capacity),
        price: String(form.price),
        description: form.description,
        is_active: form.is_active,
      };
    } else {
      errorMessage.value = result.error;
    }

    isLoading.value = false;
  }

  async function getChangedFields() {
    const changed = {};

    const originalName = original.value.name || '';
    const currentName = form.name || '';
    if (currentName.trim() !== originalName.trim()) {
      changed.name = currentName.trim();
    }

    const originalType = original.value.type || '';
    const currentType = form.type || '';
    if (currentType !== originalType) {
      changed.type = currentType;
    }

    const originalNumber = original.value.number_place || '';
    const currentNumber = String(form.number_place || '');
    if (currentNumber !== originalNumber) {
      changed.number_place = Number(currentNumber);
    }

    const originalCapacity = original.value.capacity || '';
    const currentCapacity = String(form.capacity || '');
    if (currentCapacity !== originalCapacity) {
      changed.capacity = Number(currentCapacity);
    }

    const originalPrice = original.value.price || '';
    const currentPrice = String(form.price || '');
    if (currentPrice !== originalPrice) {
      changed.price = Number(currentPrice);
    }

    const originalDescription = original.value.description || '';
    const currentDescription = form.description || '';
    if (currentDescription.trim() !== originalDescription.trim()) {
      changed.description = currentDescription.trim();
    }

    const originalActive = original.value.is_active;
    const currentActive = form.is_active;
    if (currentActive !== originalActive) {
      changed.is_active = currentActive ? 1 : 0;
    }

    if (form.photo && form.photo instanceof File) {
      changed.photo = form.photo;
    }

    return changed;
  }

  function clearErrors() {
    errors.name = '';
    errors.type = '';
    errors.number_place = '';
    errors.capacity = '';
    errors.price = '';
    errors.description = '';
    errorMessage.value = '';
    successMessage.value = '';
  }

  function selectType(type) {
    form.type = type;
    showTypeDropdown.value = false;
    errors.type = '';
  }

  function getTypeLabel() {
    const type = placeTypes.find((t) => t.value === form.type);
    return type ? type.label : 'Выберите тип помещения';
  }

  function onFileChange(event) {
    const file = event.target.files[0];
    if (file) {
      form.photo = file;
      form.photoName = file.name;
    }
  }

  async function handleSubmit() {
    clearErrors();

    const changedFields = await getChangedFields();

    if (Object.keys(changedFields).length === 0) {
      errorMessage.value = 'Нет изменений для сохранения';
      return;
    }

    let isValid = true;

    if (form.number_place && Number(form.number_place) < 1) {
      errors.number_place = 'Номер должен быть больше 0';
      isValid = false;
    }

    if (form.capacity && Number(form.capacity) < 1) {
      errors.capacity = 'Вместимость должна быть больше 0';
      isValid = false;
    }

    if (form.price !== '' && Number(form.price) < 0) {
      errors.price = 'Стоимость не может быть отрицательной';
      isValid = false;
    }

    if (!isValid) return;

    isSaving.value = true;

    const result = await placesStore.updatePlace(placeId, changedFields);

    isSaving.value = false;

    if (result.success) {
      successMessage.value = 'Помещение успешно обновлено!';

      original.value = {
        name: form.name,
        type: form.type,
        number_place: String(form.number_place),
        capacity: String(form.capacity),
        price: String(form.price),
        description: form.description,
        is_active: form.is_active,
      };

      form.photo = null;
      form.photoName = '';

      setTimeout(() => {
        successMessage.value = '';
        router.push('/admin/places');
      }, 4000);
    } else {
      if (result.errors) {
        Object.keys(result.errors).forEach((key) => {
          if (errors.hasOwnProperty(key)) {
            const error = result.errors[key];
            errors[key] = Array.isArray(error) ? error[0] : error;
          }
        });
      }
      errorMessage.value = result.error;
    }
  }

  function handleCancel() {
    router.push('/admin/places');
  }
</script>

<template>
  <div class="edit-place">
    <div class="edit-place__container">
      <div class="edit-place__form-card">
        <h1 class="edit-place__title">Редактирование помещения</h1>

        <div v-if="isLoading" class="edit-place__loading">
          <div class="edit-place__spinner"></div>
          <p>Загрузка данных...</p>
        </div>

        <template v-else>
          <div v-if="successMessage" class="edit-place__message edit-place__message--success">
            ✓ {{ successMessage }}
          </div>

          <div v-if="errorMessage" class="edit-place__message edit-place__message--error">
            {{ errorMessage }}
          </div>

          <form @submit.prevent="handleSubmit" class="edit-place__form">
            <div class="edit-place__field">
              <label class="edit-place__label">Название</label>
              <input
                v-model="form.name"
                type="text"
                class="edit-place__input"
                :class="{ 'edit-place__input--error': errors.name }"
                placeholder="Введите название"
              />
              <span v-if="errors.name" class="edit-place__error">{{ errors.name }}</span>
            </div>

            <div class="edit-place__field">
              <label class="edit-place__label">Тип помещения</label>
              <div class="edit-place__select-wrapper">
                <button
                  type="button"
                  class="edit-place__select"
                  :class="{ 'edit-place__select--error': errors.type }"
                  @click="showTypeDropdown = !showTypeDropdown"
                >
                  <span>{{ getTypeLabel() }}</span>
                  <img src="/arrow-square-down.svg" alt="" class="edit-place__arrow" />
                </button>

                <transition name="dropdown">
                  <div v-if="showTypeDropdown" class="edit-place__dropdown">
                    <div
                      v-for="type in placeTypes"
                      :key="type.value"
                      class="edit-place__dropdown-item"
                      :class="{ 'edit-place__dropdown-item--active': form.type === type.value }"
                      @click="selectType(type.value)"
                    >
                      {{ type.label }}
                    </div>
                  </div>
                </transition>
              </div>
              <span v-if="errors.type" class="edit-place__error">{{ errors.type }}</span>
            </div>

            <div class="edit-place__field">
              <label class="edit-place__label">Номер кабинета</label>
              <input
                v-model="form.number_place"
                type="number"
                class="edit-place__input"
                :class="{ 'edit-place__input--error': errors.number_place }"
                placeholder="Введите номер"
              />
              <span v-if="errors.number_place" class="edit-place__error">
                {{ errors.number_place }}
              </span>
            </div>

            <div class="edit-place__field">
              <label class="edit-place__label">Вместимость</label>
              <input
                v-model="form.capacity"
                type="number"
                class="edit-place__input"
                :class="{ 'edit-place__input--error': errors.capacity }"
                placeholder="Количество человек"
              />
              <span v-if="errors.capacity" class="edit-place__error">{{ errors.capacity }}</span>
            </div>

            <div class="edit-place__field">
              <label class="edit-place__label">Стоимость</label>
              <input
                v-model="form.price"
                type="number"
                step="0.01"
                class="edit-place__input"
                :class="{ 'edit-place__input--error': errors.price }"
                placeholder="Введите стоимость"
              />
              <span v-if="errors.price" class="edit-place__error">{{ errors.price }}</span>
            </div>

            <div class="edit-place__field">
              <label class="edit-place__label">Описание</label>
              <textarea
                v-model="form.description"
                class="edit-place__textarea"
                :class="{ 'edit-place__textarea--error': errors.description }"
                placeholder="Введите описание"
                rows="3"
              ></textarea>
              <span v-if="errors.description" class="edit-place__error">
                {{ errors.description }}
              </span>
            </div>

            <div class="edit-place__field">
              <label class="edit-place__label">Фото</label>
              <div class="edit-place__file-wrapper">
                <input
                  type="file"
                  accept="image/*"
                  class="edit-place__file-input"
                  @change="onFileChange"
                />
                <div class="edit-place__file-display">
                  <span>{{ form.photoName || 'Выберите файл' }}</span>
                  <img src="/folder-cloud.svg" alt="" class="edit-place__file-icon" />
                </div>
              </div>
            </div>

            <div class="edit-place__buttons">
              <button
                type="submit"
                class="edit-place__btn edit-place__btn--save"
                :disabled="isSaving"
              >
                <span v-if="isSaving" class="edit-place__btn-spinner"></span>
                <span v-else>Сохранить</span>
              </button>
              <button
                type="button"
                class="edit-place__btn edit-place__btn--cancel"
                @click="handleCancel"
                :disabled="isSaving"
              >
                Отмена
              </button>
            </div>
          </form>
        </template>
      </div>

      <div class="edit-place__illustration">
        <img src="/man-edit_place.png" alt="Иллюстрация" />
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;

  .edit-place {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 2rem;

    &__container {
      display: flex;
      gap: 4rem;
      max-width: 1200px;
      width: 100%;
      align-items: center;
    }

    &__form-card {
      flex: 1;
      max-width: 600px;
      background: $color-footer-bg;
      padding: 2rem 3rem;
      border-radius: $radius-lg;
    }

    &__title {
      font-family: $font-title;
      font-weight: 300;
      font-size: 28px;
      color: $color-text;
      margin-bottom: 2rem;
    }

    &__loading {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 1rem;
      padding: 2rem;
    }

    &__spinner {
      width: 40px;
      height: 40px;
      border: 3px solid rgba($color-text, 0.2);
      border-top-color: $color-text;
      border-radius: 50%;
      animation: spin 0.8s linear infinite;
    }

    &__message {
      padding: 1rem;
      border-radius: $radius-sm;
      margin-bottom: 1.5rem;
      font-size: 14px;

      &--success {
        background: #d4edda;
        color: #155724;
        border: 1px solid #c3e6cb;
      }

      &--error {
        background: #f8d7da;
        color: #721c24;
        border: 1px solid #f5c6cb;
      }
    }

    &__form {
      display: flex;
      flex-direction: column;
      gap: 1.25rem;
    }

    &__field {
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
    }

    &__label {
      font-size: 14px;
      font-weight: 500;
      color: $color-text;
    }

    &__input,
    &__textarea {
      padding: 0.75rem 1rem;
      background: $color-input-bg;
      border: 1px solid $color-text;
      border-radius: $radius-xs;
      font-size: 14px;
      color: $color-text;
      transition: border-color 0.2s;

      &:focus {
        outline: none;
      }

      &--error {
        border-color: #dc3545;
      }

      &::placeholder {
        color: rgba($color-text, 0.5);
      }
    }

    &__textarea {
      resize: vertical;
      min-height: 80px;
      font-family: $font-base;
    }

    &__error {
      font-size: 12px;
      color: #dc3545;
    }

    &__select-wrapper {
      position: relative;
    }

    &__select {
      width: 100%;
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0.75rem 1rem;
      background: $color-input-bg;
      border: 1px solid $color-text;
      border-radius: $radius-xs;
      font-size: 14px;
      color: $color-text;
      cursor: pointer;
      transition: border-color 0.2s;
      text-align: left;

      &:hover {
        border-color: darken($color-text, 20%);
      }

      &--error {
        border-color: #dc3545;
      }
    }

    &__arrow {
      width: 20px;
      height: 20px;
    }

    &__dropdown {
      position: absolute;
      top: 100%;
      left: 0;
      right: 0;
      margin-top: 0.5rem;
      background: $color-btn-profile;
      border: 1px solid $color-border;
      border-radius: $radius-sm;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
      z-index: 100;
      overflow: hidden;
    }

    &__dropdown-item {
      padding: 0.75rem 1rem;
      cursor: pointer;
      transition: background 0.2s;

      &:hover {
        background: rgba($color-text, 0.05);
      }

      &--active {
        background: rgba($color-text, 0.1);
        font-weight: 600;
      }
    }

    &__checkbox-label {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      cursor: pointer;
    }

    &__checkbox {
      width: 18px;
      height: 18px;
      cursor: pointer;
    }

    &__file-wrapper {
      position: relative;
    }

    &__file-input {
      position: absolute;
      opacity: 0;
      width: 100%;
      height: 100%;
      cursor: pointer;
    }

    &__file-display {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0.75rem 1rem;
      background: $color-input-bg;
      border: 1px solid $color-text;
      border-radius: $radius-xs;
      cursor: pointer;
    }

    &__file-icon {
      width: 20px;
      height: 20px;
    }

    &__buttons {
      display: flex;
      gap: 1rem;
      margin-top: 1rem;
    }

    &__btn {
      flex: 1;
      padding: 0.75rem;
      border-radius: $radius-sm;
      font-size: 16px;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.2s;
      border: 1px solid $color-text;
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 45px;

      &--save {
        background: $color-input-bg;
        color: $color-text;
      }

      &--cancel {
        background: $color-btn-profile;
        color: $color-text;
      }

      &:disabled {
        opacity: 0.6;
        cursor: not-allowed;
      }
    }

    &__btn-spinner {
      width: 20px;
      height: 20px;
      border: 2px solid rgba($color-text, 0.3);
      border-top-color: $color-text;
      border-radius: 50%;
      animation: spin 0.6s linear infinite;
    }

    &__illustration {
      flex-shrink: 0;

      img {
        max-width: 500px;
        height: auto;
      }
    }

    @media (max-width: 1024px) {
      &__container {
        flex-direction: column;
        gap: 2rem;
      }

      &__illustration {
        display: none;
      }
    }
  }

  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }

  .dropdown-enter-active,
  .dropdown-leave-active {
    transition: all 0.2s;
  }

  .dropdown-enter-from,
  .dropdown-leave-to {
    opacity: 0;
    transform: translateY(-10px);
  }

  /* Hide number input spinners */
  input[type='number']::-webkit-outer-spin-button,
  input[type='number']::-webkit-inner-spin-button {
    -webkit-appearance: none;
    margin: 0;
  }

  input[type='number'] {
    -moz-appearance: textfield;
  }
</style>
