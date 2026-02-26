<script setup>
  import { ref } from 'vue';

  const date = ref('5 февраля');
  const price = ref([0, 2000]);

  const toggleFavorite = async (room) => {
    room.isFavorite = !room.isFavorite;

    try {
      await apiFavorite(room.id, room.isFavorite);
    } catch (e) {
      room.isFavorite = !room.isFavorite;
      console.error('Ошибка при добавлении в избранное');
    }
  };

  const apiFavorite = (id, status) => {
    return new Promise((resolve) => {
      console.log(`Запрос в БД: roomId=${id}, favorite=${status}`);
      setTimeout(resolve, 400);
    });
  };

  const rooms = ref([
    {
      id: 1,
      title: 'Кабинет №1',
      price: 1000,
      capacity: 10,
      image: './meeting-room.jpg',
      isFavorite: false,
    },
    {
      id: 2,
      title: 'Кабинет №2',
      price: 1500,
      capacity: 15,
      image: './meeting-room.jpg',
      isFavorite: false,
    },
    {
      id: 3,
      title: 'Кабинет №3',
      price: 400,
      capacity: 2,
      image: './meeting-room.jpg',
      isFavorite: false,
    },
    {
      id: 4,
      title: 'Кабинет №4',
      price: 700,
      capacity: 8,
      image: './meeting-room.jpg',
      isFavorite: false,
    },
    {
      id: 5,
      title: 'Кабинет №5',
      price: 1200,
      capacity: 12,
      image: './meeting-room.jpg',
      isFavorite: false,
    },
    {
      id: 6,
      title: 'Кабинет №6',
      price: 2000,
      capacity: 20,
      image: './meeting-room.jpg',
      isFavorite: false,
    },
  ]);
</script>

<template>
  <main class="service">
    <h1 class="service__title">Переговорные комнаты</h1>

    <div class="service__filters">
      <div class="filter">
        <span>{{ date }}</span>
        <img src="/arrow-square-down.svg" alt="" />
      </div>

      <div class="filter">
        <span>Стоимость</span>
        <img src="/arrow-square-down.svg" alt="" />
      </div>

      <div class="filter__range">
        <span>0</span>
        <input type="range" min="0" max="2000" />
        <span>2000</span>
      </div>
    </div>

    <div class="service__grid">
      <div v-for="room in rooms" :key="room.id" class="room-card">
        <div class="room-card__date">{{ date }}</div>

        <div class="room-card__body">
          <div class="room-card__image">
            <img :src="room.image" alt="" />
          </div>

          <div class="room-card__text">
            <h3>Аренда переговорной</h3>
            <p>{{ room.title }}</p>
            <p>Стоимость: {{ room.price }}р</p>
            <p>Вместимость: {{ room.capacity }} человек</p>
          </div>

          <button class="room-card__fav" @click="toggleFavorite(room)">
            <div class="heart-wrapper">
              <img
                src="/heart-empty.svg"
                class="heart"
                :class="{ active: !room.isFavorite }"
                alt=""
              />

              <img
                src="/heart-filled.svg"
                class="heart"
                :class="{ active: room.isFavorite }"
                alt=""
              />
            </div>
          </button>
        </div>

        <button class="room-card__time">Допустимое время: с 09:00 - 22:00</button>
      </div>
    </div>

    <div class="service__pagination">
      <button>&lt;</button>
      <button class="active">1</button>
      <button>2</button>
      <button>3</button>
      <button>4</button>
      <button>&gt;</button>
    </div>
  </main>
</template>

<style lang="scss" scoped>
  @use '@/assets/styles/variables' as *;
  @use '@/assets/styles/mixins' as *;

  .service {
    @include container;
    margin-top: 4rem;

    &__title {
      text-align: center;
      font-family: $font-heading;
      font-size: $text-3xl;
      margin-bottom: 3rem;
    }

    &__filters {
      display: flex;
      flex-wrap: wrap;
      gap: 1.5rem;
      align-items: center;
      margin-bottom: 3rem;
    }

    &__grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 2rem;
    }

    &__pagination {
      margin: 3rem 0;
      display: flex;
      justify-content: center;
      gap: 0.5rem;

      button {
        padding: 0.4rem 0.75rem;
        border-radius: 0.35rem;
        background: $color-card-bg;

        &.active {
          background: $color-header-bg;
        }
      }
    }
  }

  .filter {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    border: 1px solid $color-border;
    border-radius: 0.4rem;
    padding: 0.35rem 0.8rem;
    cursor: pointer;

    img {
      width: 14px;
    }

    &__range {
      display: flex;
      align-items: center;
      gap: 0.75rem;

      input {
        width: 160px;
      }
    }
  }

  .room-card {
    display: flex;
    flex-direction: column;

    &__date {
      margin-left: 1rem;
      margin-bottom: 0.5rem;
    }

    &__image {
      width: 40%;

      img {
        border: 1px solid $color-footer-bg;
        border-radius: $radius-xs;
        object-fit: cover;
      }
    }

    &__fav {
      position: absolute;
      top: 0.6rem;
      right: 0.6rem;
      border-radius: 50%;
      width: 32px;
      height: 32px;
      display: flex;
      align-items: center;
      justify-content: center;

      img {
        width: 32px;
      }
    }

    &__body {
      position: relative;
      background: $color-card-bg;
      border: 1px solid $color-footer-bg;
      border-radius: $radius-md;
      padding: 1rem;
      display: flex;
      align-items: center;
      gap: 20px;

      font-size: $text-base;
      line-height: 1.6;

      h3 {
        font-weight: 600;
        margin-bottom: 0.5rem;
      }
    }

    &__time {
      border: 1px solid $color-border;
      border-radius: $radius-xxs;
      background: $color-bg;
      text-align: center;
      padding: 0.4rem;
      margin: 0.6rem auto 0;
      width: 80%;
      font-size: $text-base;
      transition: 0.2s;

      &:hover {
        background: $color-card-bg;
        box-shadow: 0 3px 3px rgba(0, 0, 0, 0.5);
      }
    }
  }

  .heart-wrapper {
    position: relative;
    width: 32px;
    height: 32px;
  }

  .heart {
    position: absolute;
    inset: 0;
    width: 32px;
    height: 32px;
    opacity: 0;
    transition: opacity 0.2s ease;
  }

  .heart.active {
    opacity: 1;
  }
</style>
