<?php

namespace App\Http\Controllers\Api;

use App\Handlers\Bookings\AdminListBookingsHandler;
use App\Http\Controllers\Controller;
use App\Http\Requests\Bookings\AdminBookingsRequest;
use Illuminate\Http\JsonResponse;

class AdminBookingController extends Controller
{
    public function index(AdminBookingsRequest $request ,AdminListBookingsHandler $handler): JsonResponse
    {
        $result = $handler->handle($request->toDTO());

        return response()->json($result, 200);
    }
}
