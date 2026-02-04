<script setup>
</script>

<template>
  <div class="min-h-screen w-full flex items-center justify-center">
    <div class="flex w-full min-h-160 max-w-6xl bg-[#7C8FA0] rounded-xl overflow-hidden shadow-lg">
      <div class="hidden lg:block lg:w-1/2 relative overflow-hidden">
        <div class="absolute inset-0 bg-gradient-to-b from-orange-200 to-red-300 rounded-xl"></div>

        <img
            src="/people-login.png"
            alt="people"
            class="absolute z-10 transform -translate-x-1/2 -translate-y-1/2 top-1/2 left-1/2 max-h-full max-w-full object-contain"
        >
      </div>

      <div class="w-full lg:w-1/2 flex items-center justify-center p-4 lg:p-8">
        <div class="w-full max-w-md">
          <div class="p-8 w-full">
            <h2 class="font-heading text-3xl text-center text-gray-800 mb-8">
              Авторизация
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
                    class="w-full px-4 py-3 bg-gradient-to-r from-orange-200 to-red-300 border border-black rounded-lg focus:outline-none focus:ring-2 focus:ring-black-500 focus:border-transparent transition duration-200"
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
                    class="w-full px-4 py-3 bg-gradient-to-r from-orange-200 to-red-300 border border-black rounded-lg focus:outline-none focus:ring-2 focus:ring-black-500 focus:border-transparent transition duration-200"
                />
              </div>

              <div class="flex items-center justify-between">
                <a href="#" class="text-sm hover:text-yellow-100 transition duration-200">
                  Забыли пароль?
                </a>
                <router-link to="/registration"><p class="ml-1 text-sm hover:text-yellow-100 font-medium transition duration-200">
                  Зарегистрироваться
                </p></router-link>
              </div>

              <button
                  type="submit"
                  class="w-full bg-[#EBCAA3] hover:bg-red-300 font-semibold py-3 px-4 rounded-lg transition duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
              >
                Войти
              </button>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>