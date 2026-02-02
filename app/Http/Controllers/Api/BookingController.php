<?php

namespace App\Http\Controllers\Api;

use App\Handlers\Bookings\CreateBookingHandler;
use App\Http\Controllers\Controller;
use App\Http\Requests\Bookings\StoreBookingRequest;
use App\Models\Booking;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BookingController extends Controller
{
    public function createBooking(StoreBookingRequest $request, CreateBookingHandler $handler): JsonResponse
    {
        $booking = $handler->handle($request->toDTO(), $request->user());
        return response()->json(['data' => $booking], 201);
    }

    public function myBookings(Request $request): JsonResponse
    {
        $bookings = Booking::query()
            ->with('place')
            ->where('user_id', $request->user()->id)
            ->orderByDesc('start_time')
            ->get();

        return response()->json(['data' => $bookings]);
    }



}
