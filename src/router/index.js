import { createRouter, createWebHistory } from 'vue-router';

import Authorization from '../pages/Authorization.vue';
import Main from '../pages/Main.vue';
import Registration from '../pages/Registration.vue';
import Services from '../pages/Services.vue';
import MeetingRooms from '../pages/MeetingRooms.vue';
import PrivacyPolicy from '@/pages/PrivacyPolicy.vue';
import Profile from '@/pages/Profile.vue';
import UpdatePassword from '@/pages/UpdatePassword.vue';
import Reviews from '@/pages/Reviews.vue';
import Offices from '@/pages/Offices.vue';
import Coworking from '@/pages/Coworking.vue';
import Requests from '@/pages/Requests.vue';

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
    path: '/meeting_rooms',
    name: 'MeetingRooms',
    component: MeetingRooms,
  },
  {
    path: '/privacy-policy',
    name: 'Privacy Policy',
    component: PrivacyPolicy,
  },
  {
    path: '/profile',
    name: 'Profile',
    component: Profile,
  },
  {
    path: '/update-password',
    name: 'UpdatePassword',
    component: UpdatePassword,
  },
  {
    path: '/reviews',
    name: 'Reviews',
    component: Reviews,
  },
  {
    path: '/offices',
    name: 'Offices',
    component: Offices,
  },
  {
    path: '/coworking',
    name: 'Coworking',
    component: Coworking,
  },
  {
    path: '/meeting-rooms',
    name: 'MeetingRooms',
    component: MeetingRooms,
  },
  {
    path: '/requests',
    name: 'Requests',
    component: Requests,
  },
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
