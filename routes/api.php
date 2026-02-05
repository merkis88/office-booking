<?php

use App\Http\Controllers\Api\AdminBookingController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\PasswordResetController;
use App\Http\Controllers\Api\UserController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

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

   // Booking
    Route::post('/bookings', [BookingController::class, 'createBooking']);
    Route::get('/bookings/my', [BookingController::class, 'myBookings']);
    Route::get('/bookings/{booking}', [BookingController::class, 'showBooking']);
    Route::post('/bookings/{booking}/cancel', [BookingController::class, 'cancelBooking']);
    Route::post('/bookings/{booking}/reschedule', [BookingController::class, 'rescheduleBooking']);

   // Admin
    Route::middleware('is_admin')->prefix('admin')->group(function () {
        Route::apiResource('users', UserController::class);
        Route::get('/bookings', [AdminBookingController::class, 'index']);
        Route::post('/bookings/{booking}/approve', [AdminBookingController::class, 'approve']);
    });
});
