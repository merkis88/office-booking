import { createRouter, createWebHistory } from 'vue-router';

import MainLayout from '@/layouts/MainLayout.vue';
import AdminLayout from '@/layouts/AdminLayout.vue';

import Authorization from '../pages/Authorization.vue';
import Main from '../pages/Main.vue';
import Registration from '../pages/Registration.vue';
import Services from '../pages/Services.vue';
import MeetingRooms from '../pages/MeetingRooms.vue';
import PrivacyPolicy from '@/pages/PrivacyPolicy.vue';
import Profile from '@/pages/Profile.vue';
import UpdatePassword from '@/pages/UpdatePassword.vue';
import Reviews from '@/pages/Reviews.vue';
import BookingHistory from '@/pages/admin/BookingHistory.vue';
import Offices from '@/pages/Offices.vue';
import Coworking from '@/pages/Coworking.vue';
import Requests from '@/pages/Requests.vue';
import Notifications from '@/pages/admin/Notifications.vue';

const routes = [
  {
    path: '/',
    component: MainLayout,
    children: [
      { path: '', component: Main },
      { path: 'authorization', component: Authorization },
      { path: 'registration', component: Registration },
      { path: 'service', component: Services },
      { path: 'privacy-policy', component: PrivacyPolicy },
      { path: 'profile', component: Profile },
      { path: 'update-password', component: UpdatePassword },
      { path: 'reviews', component: Reviews },
      { path: 'offices', component: Offices },
      { path: 'coworking', component: Coworking },
      { path: 'meeting-rooms', component: MeetingRooms },
      { path: '/requests', component: Requests },
    ],
  },
  {
    path: '/admin',
    component: AdminLayout,
    children: [
      {
        path: 'notifications',
        component: Notifications,
      },
      {
        path: 'booking-history',
        component: BookingHistory,
      },
    ],
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
