<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\BookingController;

Route::post('/bookings', [BookingController::class, 'createBooking']);
Route::get('/bookings/my', [BookingController::class, 'myBookings']);
Route::get('bookings/{bookingId}', [BookingController::class, 'showBooking']);
Route::post('bookings{bookingId}/cancel', [BookingController::class, 'cancelBooking']);
Route::post('bookings{bookingId}/reschedule', [BookingController::class, 'rescheduleBooking']);


