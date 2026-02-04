<script setup>
</script>

<template>
  <div class="min-h-screen w-full flex items-center justify-center">
    <div class="flex w-full min-h-160 max-w-6xl bg-[#7C8FA0] rounded-xl overflow-hidden shadow-lg">
      <div class="hidden lg:block lg:w-1/2 relative overflow-hidden">
        <div class="absolute inset-0 bg-linear-to-b from-orange-200 to-red-300 rounded-xl"></div>

        <img src="/people-login.png" alt="people" class="absolute z-10">
      </div>

      <div class="w-full lg:w-1/2 flex items-center justify-center p-4 lg:p-8">
        <div class="w-full max-w-md">
          <div class="p-8 w-full">
            <h2 class="font-heading text-3xl text-center text-gray-800 mb-8">
              Регистрация
            </h2>

            <form class="space-y-6">
              <div>
                <label class="block text-gray-700 text-sm font-medium mb-2">
                  Эл. почта*
                </label>
                <input
                    type="email"
                    placeholder="Введите электронную почту"
                    required
                    class="w-full px-4 py-3 bg-linear-to-r from-orange-200 to-red-300 border border-black rounded-lg focus:outline-none focus:ring-2 focus:ring-black-500 focus:border-transparent transition duration-200"
                />
              </div>

              <div>
                <label class="block text-gray-700 text-sm font-medium mb-2">
                  Пароль*
                </label>
                <input
                    type="password"
                    placeholder="Введите пароль"
                    required
                    class="w-full px-4 py-3 bg-linear-to-r from-orange-200 to-red-300 border border-black rounded-lg focus:outline-none focus:ring-2 focus:ring-black-500 focus:border-transparent transition duration-200"
                />
              </div>

              <div>
                <label class="block text-gray-700 text-sm font-medium mb-2">
                  Подтвердите пароль*
                </label>
                <input
                    type="password"
                    placeholder="Введите пароль"
                    required
                    class="w-full px-4 py-3 bg-linear-to-r from-orange-200 to-red-300 border border-black rounded-lg focus:outline-none focus:ring-2 focus:ring-black-500 focus:border-transparent transition duration-200"
                />
              </div>

              <div class="flex items-center justify-between">
                <label><input type="checkbox">
                  Я принимаю условия обработки персональных данных
                </label>
              </div>

              <button
                  type="submit"
                  class="w-full bg-[#EBCAA3] hover:bg-red-300 font-semibold py-3 px-4 rounded-lg transition duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
              >
                Войти
              </button>

              <div class="flex items-center justify-center">
                <p class="text-sm font-medium">
                  Уже есть аккаунт?
                </p>
                <router-link to="authorization"><p class="ml-1 text-sm hover:text-yellow-100 font-medium transition duration-200">
                  Авторизация
                </p></router-link>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>