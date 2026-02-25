import { createRouter, createWebHistory } from 'vue-router';

import Authorization from '../pages/Authorization.vue';
import Main from '../pages/Main.vue';
import Registration from "../pages/Registration.vue";
import Services from "../pages/Services.vue";
import PrivacyPolicy from '@/pages/PrivacyPolicy.vue';

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
  {
    path: '/privacy-policy',
    name: 'Privacy Policy',
    component: PrivacyPolicy
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) {
      return savedPosition;
    } else {
      return { top: 0 };
    }
  },
});



export default router;
