<?php


use App\Http\Controllers\Api\Admin\AdminBookingController;
use App\Http\Controllers\Api\AdminPlaceController;

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\Booking\BookingController;
use App\Http\Controllers\Api\PasswordResetController;
use App\Http\Controllers\Api\Qr\QrController;


use App\Http\Controllers\Api\PlaceController;

use App\Http\Controllers\Api\ReviewController;
use App\Http\Controllers\Api\UserController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\Profile\ProfileQrController;

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});


// Восстановление пароля
Route::post('/forgot-password', [PasswordResetController::class, 'forgotPassword'])->name('password.email');// Osip
Route::post('/reset-password', [PasswordResetController::class, 'resetPassword'])->name('password.update');// Osip
Route::post('/validate-reset-token', [PasswordResetController::class, 'checkToken'])->name('password.validate');// Osip

// Аутентификация
Route::post('/register', [AuthController::class, 'register']);// Osip
Route::post('/login', [AuthController::class, 'login']);// Osip
Route::post('/verify-email', [AuthController::class, 'verifyEmail']);// Osip
Route::post('/resend-verification', [AuthController::class, 'resendVerification']);// Osip


// Защищённые пути
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    }); // Osip

    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);// Osip
    Route::get('/me', [AuthController::class, 'me']);// Osip
    Route::put('/user/password', [UserController::class, 'updatePassword']);// Osip

    // Profile
    Route::get('/profile/qrs', [ProfileQrController::class, 'index']); // merk

    // Reviews
    Route::apiResource('reviews', ReviewController::class)->except('create', 'edit');// Osip
    Route::get('/users/{user}/reviews', [ReviewController::class, 'userReviews']);// Osip

    // Bookings
    Route::post('/bookings', [BookingController::class, 'createBooking']); // merk
    Route::post('/bookings/guest', [BookingController::class, 'guestBooking']); // merk
    Route::get('/bookings/my', [BookingController::class, 'myBookings']); // merk
    Route::get('/bookings/{booking}', [BookingController::class, 'showBooking']); // merk
    Route::post('/bookings/{booking}/cancel', [BookingController::class, 'cancelBooking']); // merk
    Route::post('/bookings/{booking}/extend', [BookingController::class, 'extendBooking']); // merk
    Route::post('/bookings/{booking}/reschedule', [BookingController::class, 'rescheduleBooking']); // merk

    // Qr
    Route::post('/qr/{booking}/guest-qr', [QrController::class, 'createGuestQr']); // merk
    Route::post('/qr/{booking}/user-qr', [QrController::class, 'createUserQr']); // merk


    //Places
    Route::get('/places', [PlaceController::class, 'index']);// Osip
    Route::get('/places/{place}', [PlaceController::class, 'show']);// Osip

   // Admin
    Route::middleware('is_admin')->prefix('admin')->group(function () {

        Route::apiResource('users', UserController::class);
        Route::get('/bookings', [AdminBookingController::class, 'index']); // merk
        Route::get('/bookings/export', [AdminBookingController::class, 'export']); // merk


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

        Route::apiResource('users', UserController::class); // merk
        Route::get('/bookings', [AdminBookingController::class, 'index']); // merk
        Route::get('/bookings/export', [AdminBookingController::class, 'export']); // merk
    });
});
