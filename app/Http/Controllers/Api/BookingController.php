<?php

namespace App\Http\Controllers\Api;

use App\Handlers\Bookings\CancelBookingHandler;
use App\Handlers\Bookings\CreateBookingHandler;
use App\Handlers\Bookings\MyBookingHandler;
use App\Http\Controllers\Controller;
use App\Http\Requests\Bookings\StoreBookingRequest;
use App\Models\Booking;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use App\Handlers\Bookings\ShowBookingHandler;

class BookingController extends Controller
{
    public function createBooking(StoreBookingRequest $request, CreateBookingHandler $handler): JsonResponse
    {
        $create_booking = $handler->handle($request->toDTO(), $request->user());

        return response()->json(['data' => $create_booking], 201);
    }

    public function myBookings(Request $request, MyBookingHandler $handler): JsonResponse
    {
        $my_bookings = $handler->handle($request->user());

        return response()->json(['data' => $my_bookings], 200);
    }

    public function showBooking(Request $request, Booking $booking, ShowBookingHandler $handler)
    {
        $show_booking = $handler->handle($booking, $request->user());

        return response()->json(['data' => $show_booking], 200);
    }

    public function cancelBooking(Request $request, Booking $booking, CancelBookingHandler $handler)
    {
        $cansel_booking = $handler->handle($booking, $request->user());

        return response()->json(['data' => $cansel_booking], 200);
    }







}
