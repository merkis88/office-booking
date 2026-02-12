<?php

namespace App\Http\Controllers\Api\Admin;

use App\Handlers\Bookings\AdminApproveBookingHandler;
use App\Handlers\Bookings\AdminExportBookingsHandler;
use App\Handlers\Bookings\AdminListBookingsHandler;
use App\Http\Controllers\Controller;
use App\Http\Requests\Bookings\AdminBookingsRequest;
use App\Models\Booking;
use Illuminate\Http\JsonResponse;
use Symfony\Component\HttpFoundation\StreamedResponse;

class AdminBookingController extends Controller
{
    public function index(AdminBookingsRequest $request ,AdminListBookingsHandler $handler): JsonResponse
    {
        $result = $handler->handle($request->toDTO());

        return response()->json($result, 200);
    }

    public function approve(Booking $booking, AdminApproveBookingHandler $handler): JsonResponse
    {
        $approve = $handler->handle($booking);

        return response()->json(['data' => $approve], 200);
    }

    public function export(AdminBookingsRequest $request, AdminExportBookingsHandler $handler, AdminListBookingsHandler $listHandler): StreamedResponse
    {
        return $handler->handle($request->toDTO(), $listHandler);
    }
}
