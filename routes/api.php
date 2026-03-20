<?php

use App\Http\Controllers\Api\Admin\AdminBookingController;
use App\Http\Controllers\Api\Admin\AdminNotificationController;
use App\Http\Controllers\Api\AdminPlaceController;
use App\Http\Controllers\Api\AdminServiceController;
use App\Http\Controllers\Api\AdminServiceTypeController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\Booking\BookingController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\Place\PlaceFavoriteController;
use App\Http\Controllers\Api\PlaceController;
use App\Http\Controllers\Api\Qr\QrController;
use App\Http\Controllers\Api\Qr\TenantQrController;
use App\Http\Controllers\Api\ReviewController;
use App\Http\Controllers\Api\ServiceController;
use App\Http\Controllers\Api\ServiceExportController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\Profile\ProfileController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;


//восстановление пароля
Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);// Osip

// Аутентификация
Route::post('/register', [AuthController::class, 'register']);// Osip
Route::post('/login', [AuthController::class, 'login']);// Osip
Route::post('/verify-email', [AuthController::class, 'verifyEmail']);// Osip
Route::post('/resend-verification', [AuthController::class, 'resendVerification']);// Osip

//Reviews
Route::get('/reviews', [ReviewController::class, 'index']);// Osip
Route::get('/reviews/{review}', [ReviewController::class, 'show']);// Osip
Route::get('/users/{user}/reviews', [ReviewController::class, 'userReviews']);// Osip

// Защищённые пути
Route::middleware(['auth:sanctum', 'not_blocked'])->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    }); // Osip

    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);// Osip
    Route::get('/me', [AuthController::class, 'me']);// Osip
    Route::put('/user/password', [UserController::class, 'updatePassword']);// Osip

    // Profile
    Route::get('/profile/', [ProfileController::class, 'profile']); // merk
    Route::delete('/profile', [ProfileController::class, 'delete']); // merk
    Route::patch('/profile', [ProfileController::class, 'update']); // merk

    // Reviews
    Route::post('/reviews', [ReviewController::class, 'store']);// Osip
    Route::put('/reviews/{review}', [ReviewController::class, 'update']);// Osip
    Route::delete('/reviews/{review}', [ReviewController::class, 'destroy']);// Osip

    // Bookings
    Route::post('/bookings', [BookingController::class, 'createBooking']); // merk
    Route::get('/bookings/my', [BookingController::class, 'myBookings']); // merk
    Route::get('/bookings/{booking}', [BookingController::class, 'showBooking']); // merk
    Route::post('/bookings/{booking}/cancel', [BookingController::class, 'cancelBooking']); // merk
    Route::post('/bookings/{booking}/extend', [BookingController::class, 'extendBooking']); // merk
    Route::post('/bookings/{booking}/reschedule', [BookingController::class, 'rescheduleBooking']); // merk

    // Qr
    Route::get('/tenant/qrs', [TenantQrController::class, 'createTenantQr']); // merk
    Route::post('/qr/{booking}/guest-qr', [QrController::class, 'createGuestQr']); // merk
    Route::post('/qr/{booking}/user-qr', [QrController::class, 'createUserQr']); // merk
    Route::post('/qr/{booking}/issue-qr', [QrController::class, 'issueUserQr']); // merk

    //Places
    Route::get('/places', [PlaceController::class, 'index']);// Osip
    Route::get('/places/{place}', [PlaceController::class, 'show']);// Osip
    Route::post('/places/{place}/store-favorite', [PlaceFavoriteController::class, 'store']); // merk
    Route::delete('/places/{place}/remove-favorite', [PlaceFavoriteController::class, 'remove']); // merk

    //Notifications
    Route::prefix('notifications')->group(function () {
        Route::get('/', [NotificationController::class, 'index']);// Osip
        Route::post('/{notification}/read', [NotificationController::class, 'markAsRead']);// Osip
        Route::post('/mark-all-read', [NotificationController::class, 'markAllAsRead']);// Osip
        Route::delete('/{notification}', [NotificationController::class, 'destroy']);// Osip
    });

    //Services
    Route::prefix('services')->group(function () {
        Route::get('/my-bookings', [ServiceController::class, 'getUserBookings']);// Osip
        Route::get('/', [ServiceController::class, 'index']);// Osip
        Route::post('/', [ServiceController::class, 'store']);// Osip
        //ServicePdf
        Route::get('/{service}/export', [ServiceExportController::class, 'export']);
    });

   // Admin
    Route::middleware('is_admin')->prefix('admin')->group(function () {
        Route::apiResource('users', UserController::class);
        Route::get('/bookings', [AdminBookingController::class, 'index']); // merk
        Route::get('/bookings/export', [AdminBookingController::class, 'export']); // merk
        Route::post('/users/{user}/delete', [UserController::class, 'destroy']); // merk
        Route::post('/users/block', [UserController::class, 'block']);     // merk
        Route::post('/users/unblock', [UserController::class, 'unBlock']); // merk

        //Places admin
        Route::get('/places', [AdminPlaceController::class, 'index']);// Osip
        Route::post('/places', [AdminPlaceController::class, 'store']);// Osip
        Route::get('/places/{place}', [AdminPlaceController::class, 'show']);// Osip
        Route::put('/places/{place}', [AdminPlaceController::class, 'update']);// Osip
        Route::delete('/places/{place}', [AdminPlaceController::class, 'destroy']);// Osip
        Route::post('/places/{place}/photo', [AdminPlaceController::class, 'storePhoto']);// Osip
        Route::delete('/places/{place}/photo', [AdminPlaceController::class, 'deletePhoto']);// Osip
        Route::post('/places/{place}/archive', [AdminPlaceController::class, 'archive']);// Osip
        Route::post('/places/{place}/restore', [AdminPlaceController::class, 'restore']);// Osip
        Route::get('/places/{place}/archive-status', [AdminPlaceController::class, 'archiveStatus']);// Osip

        //Notifications
        Route::post('/notifications', [AdminNotificationController::class, 'store']);// Osip

        //Services
        Route::prefix('services')->group(function () {
            Route::get('/', [AdminServiceController::class, 'index']);// Osip
            Route::get('/completed', [AdminServiceController::class, 'completed']);// Osip
            Route::get('/types', [AdminServiceController::class, 'getServiceTypes']);// Osip
            Route::put('/{service}/status', [AdminServiceController::class, 'updateStatus']);// Osip
        });

        //ServiceTypes
        Route::prefix('service-types')->group(function () {
            Route::get('/', [AdminServiceTypeController::class, 'index']);// Osip
            Route::post('/', [AdminServiceTypeController::class, 'store']);// Osip
            Route::get('/{serviceType}', [AdminServiceTypeController::class, 'show']);// Osip
            Route::put('/{serviceType}', [AdminServiceTypeController::class, 'update']);// Osip
            Route::delete('/{serviceType}', [AdminServiceTypeController::class, 'destroy']);// Osip
        });
    });
});
