import { createRouter, createWebHistory } from 'vue-router';

import Authorization from '../pages/Authorization.vue';
import Main from '../pages/Main.vue';
import Registration from "../pages/Registration.vue";

const routes = [
  {
    path: '/',
    name: 'Main',
    component: Main,
  },
  {
    path: '/authorization',
    name: 'Authorization',
    component: Authorization,
  },
  {
    path: '/registration',
    name: 'Registration',
    component: Registration,
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
