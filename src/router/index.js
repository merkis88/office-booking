import { createRouter, createWebHistory } from 'vue-router';

import Authorization from '../pages/Authorization.vue';
import Main from '../pages/Main.vue';
import Registration from "../pages/Registration.vue";
import Services from "../pages/Services.vue";

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
  {
    path: '/service',
    name: 'Service',
    component: Services,
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
