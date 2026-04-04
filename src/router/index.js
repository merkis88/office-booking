import { createRouter, createWebHistory } from 'vue-router';
import { useAuthStore } from '@/store/auth';

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
import Passes from '@/pages/Passes.vue';
import Notifications from '@/pages/admin/Notifications.vue';
import MainAdmin from '@/pages/admin/MainAdmin.vue';
import Places from '@/pages/admin/Places.vue';
import CreatePlace from '@/pages/admin/CreatePlace.vue';
import EditPlace from '@/pages/admin/EditPlace.vue';
import AdminRequestTypes from '@/pages/admin/AdminRequestTypes.vue';
import AdminUserRequests from '@/pages/admin/AdminUserRequests.vue';
import AdminRequestsHistory from '@/pages/admin/AdminRequestsHistory.vue';
import Users from '@/pages/admin/Users.vue';
import NotFound from '@/pages/NotFound.vue';

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
      { path: 'profile', component: Profile, meta: { requiresAuth: true } },
      { path: 'update-password', component: UpdatePassword, meta: { requiresAuth: true } },
      { path: 'reviews', component: Reviews },
      { path: 'offices', component: Offices, meta: { requiresAuth: true } },
      { path: 'coworking', component: Coworking, meta: { requiresAuth: true } },
      { path: 'meeting-rooms', component: MeetingRooms, meta: { requiresAuth: true } },
      { path: 'requests', component: Requests, meta: { requiresAuth: true } },
      { path: 'passes', component: Passes, meta: { requiresAuth: true } },
      {
        path: '/archived-places',
        component: () => import('@/pages/ArchivedPlaces.vue'),
        meta: { requiresAuth: true, requiresAdmin: true },
      },
      {
        path: '/:pathMatch(.*)*',
        name: 'NotFound',
        component: NotFound,
      },
    ],
  },
  {
    path: '/admin',
    component: AdminLayout,
    meta: { requiresAuth: true, requiresAdmin: true },
    children: [
      { path: '', component: MainAdmin },
      { path: 'notifications', component: Notifications },
      { path: 'places', component: Places },
      { path: 'places/booking-history', component: BookingHistory },
      { path: 'places/create', component: CreatePlace },
      { path: 'places/:id/edit', component: EditPlace },
      { path: 'requests', component: AdminUserRequests },
      { path: 'requests/types', component: AdminRequestTypes },
      { path: 'requests/history', component: AdminRequestsHistory },
      { path: 'users', component: Users },
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

router.beforeEach((to, from, next) => {
  const authStore = useAuthStore();

  // Проверка авторизации
  if (to.matched.some((record) => record.meta.requiresAuth)) {
    if (!authStore.isAuthenticated) {
      return next('/authorization');
    }
  }

  // Проверка админских прав
  if (to.matched.some((record) => record.meta.requiresAdmin)) {
    if (!authStore.isAdmin) {
      return next('/');
    }
  }

  next();
});

export default router;
