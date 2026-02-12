<?php

namespace App\Http\Controllers\Api\Booking;

use App\Handlers\Bookings\CancelBookingHandler;
use App\Handlers\Bookings\CreateBookingHandler;
use App\Handlers\Bookings\CreateGuestBookingHandler;
use App\Handlers\Bookings\ExtendBookingHandler;
use App\Handlers\Bookings\MyBookingHandler;
use App\Handlers\Bookings\RescheduleBookingHandler;
use App\Handlers\Bookings\ShowBookingHandler;
use App\Http\Controllers\Controller;
use App\Http\Requests\Bookings\CreateGuestBookingRequest;
use App\Http\Requests\Bookings\ExtendBookingRequest;
use App\Http\Requests\Bookings\MyBookingsRequest;
use App\Http\Requests\Bookings\RescheduleBookingRequest;
use App\Http\Requests\Bookings\StoreBookingRequest;
use App\Models\Booking;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;


class BookingController extends Controller
{
    public function createBooking(StoreBookingRequest $request, CreateBookingHandler $handler): JsonResponse
    {
        $create_booking = $handler->handle($request->toDTO(), $request->user());

        return response()->json(['data' => $create_booking], 201);
    }

    public function myBookings(MyBookingsRequest $request, MyBookingHandler $handler): JsonResponse
    {
        $result = $handler->handle($request->user(), $request->toDTO());

        return response()->json($result, 200);
    }

    public function showBooking(Request $request, Booking $booking, ShowBookingHandler $handler): JsonResponse
    {
        $show_booking = $handler->handle($booking, $request->user());

        return response()->json(['data' => $show_booking], 200);
    }

    public function cancelBooking(Request $request, Booking $booking, CancelBookingHandler $handler): JsonResponse
    {
        $cansel_booking = $handler->handle($booking, $request->user());

        return response()->json(['data' => $cansel_booking], 200);
    }

    public function rescheduleBooking(RescheduleBookingRequest $request, Booking $booking, RescheduleBookingHandler $handler ): JsonResponse
    {
        $reschedule_booking = $handler->handle($request->toDTO(), $booking, $request->user());

        return response()->json(['data' => $reschedule_booking], 200);
    }

    public function guestBooking(CreateGuestBookingRequest $request, CreateGuestBookingHandler $handler): JsonResponse
    {
        $guest_booking = $handler->handle($request->toDTO(), $request->user());

        return response()->json(['data' => $guest_booking], 201);
    }

    public function extendBooking(ExtendBookingRequest $request, Booking $booking, ExtendBookingHandler $handler): JsonResponse
    {
        $updated = $handler->handle($booking, $request->user(), $request->minutes());

        return response()->json(['data' => $updated], 200);
    }

}
