<?php

namespace App\Http\Controllers\Api\Qr;

use App\Handlers\Qr\CreateGuestQrHandler;
use App\Handlers\Qr\CreateUserQrHandler;
use App\Handlers\Qr\IssueUserQrHandler;
use App\Http\Controllers\Controller;
use App\Http\Requests\Qr\CreateGuestQrRequest;
use App\Http\Requests\Qr\IssueUserQrRequest;
use App\Models\Booking;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class QrController extends Controller
{
    public function createGuestQr(CreateGuestQrRequest $request, Booking $booking,CreateGuestQrHandler $handler): JsonResponse
    {
        $create_guest_qr = $handler->handle($booking, $request->user(), $request->toDTO());

        return response()->json(['data' => $create_guest_qr], 201);
    }

    public function createUserQr(Request $request, Booking $booking, CreateUserQrHandler $handler): JsonResponse
    {
        $create_user_qr = $handler->handle($booking, $request->user());

        return response()->json(['data' => $create_user_qr], 201);
    }

    public function issueUserQr (IssueUserQrRequest $request, Booking $booking, IssueUserQrHandler $handler): JsonResponse
    {
        $issue_user_qr = $handler->handle($booking, $request->user(), $request->toDTO());

        return response()->json(['data' => $issue_user_qr], 201);
    }
}
