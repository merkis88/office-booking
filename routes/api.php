<?php

use App\Http\Controllers\Api\AdminBookingController;
use App\Http\Controllers\Api\AdminPlaceController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\PasswordResetController;

use App\Http\Controllers\Api\PlaceController;
use App\Http\Controllers\Api\ReviewController;
use App\Http\Controllers\Api\UserController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;


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

    // Reviews
    Route::apiResource('reviews', ReviewController::class)->except('create', 'edit');
    Route::get('/users/{user}/reviews', [ReviewController::class, 'userReviews']);

    // Bookings
    Route::post('/bookings', [BookingController::class, 'createBooking']);
    Route::get('/bookings/my', [BookingController::class, 'myBookings']);
    Route::get('/bookings/{booking}', [BookingController::class, 'showBooking']);
    Route::post('/bookings/{booking}/cancel', [BookingController::class, 'cancelBooking']);
    Route::post('/bookings/{booking}/reschedule', [BookingController::class, 'rescheduleBooking']);

    //Places
    Route::get('/places', [PlaceController::class, 'index']);
    Route::get('/places/{place}', [PlaceController::class, 'show']);

   // Admin
    Route::middleware('is_admin')->prefix('admin')->group(function () {
        Route::apiResource('users', UserController::class);
        Route::get('/bookings', [AdminBookingController::class, 'index']);
        Route::post('/bookings/{booking}/approve', [AdminBookingController::class, 'approve']);

        //Places admin
        Route::get('/places', [AdminPlaceController::class, 'index']);
        Route::post('/places', [AdminPlaceController::class, 'store']);
        Route::get('/places/{place}', [AdminPlaceController::class, 'show']);
        Route::put('/places/{place}', [AdminPlaceController::class, 'update']);
        Route::delete('/places/{place}', [AdminPlaceController::class, 'destroy']);
        Route::post('/places/{place}/photo', [AdminPlaceController::class, 'storePhoto']);
        Route::delete('/places/{place}/photo', [AdminPlaceController::class, 'deletePhoto']);
    });
});
