<?php

use App\Http\Controllers\Api\Admin\AdminBookingController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\Booking\BookingController;
use App\Http\Controllers\Api\PasswordResetController;
use App\Http\Controllers\Api\ReviewController;
use App\Http\Controllers\Api\UserController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\Profile\ProfileQrController;

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// Круд для юзеров
Route::apiResources([
    'users' => UserController::class,
]);


// Восстановление пароля
Route::post('/forgot-password', [PasswordResetController::class, 'forgotPassword'])->name('password.email');
Route::post('/reset-password', [PasswordResetController::class, 'resetPassword'])->name('password.update');
Route::post('/validate-reset-token', [PasswordResetController::class, 'checkToken'])->name('password.validate');

// Аутентификация
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);



// Защищённые пути
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::put('/user/password', [UserController::class, 'updatePassword']);

    // Profile
    Route::get('/profile/qrs', [ProfileQrController::class, 'index']); // merk

    // Reviews
    Route::apiResource('reviews', ReviewController::class)->except('create', 'edit');
    Route::get('/users/{user}/reviews', [ReviewController::class, 'userReviews']);

    // Bookings
    Route::post('/bookings', [BookingController::class, 'createBooking']); // merk
    Route::post('/bookings/guest', [BookingController::class, 'guestBooking']); // merk
    Route::get('/bookings/my', [BookingController::class, 'myBookings']); // merk
    Route::get('/bookings/{booking}', [BookingController::class, 'showBooking']); // merk
    Route::post('/bookings/{booking}/cancel', [BookingController::class, 'cancelBooking']); // merk
    Route::post('/bookings/{booking}/extend', [BookingController::class, 'extendBooking']); // merk
    Route::post('/bookings/{booking}/reschedule', [BookingController::class, 'rescheduleBooking']); // merk


   // Admin
    Route::middleware('is_admin')->prefix('admin')->group(function () {
        Route::apiResource('users', UserController::class); // merk
        Route::get('/bookings', [AdminBookingController::class, 'index']); // merk
        Route::get('/bookings/export', [AdminBookingController::class, 'export']); // merk
        Route::post('/bookings/{booking}/approve', [AdminBookingController::class, 'approve']); // merk
    });
});
