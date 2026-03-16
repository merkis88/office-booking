<?php

namespace App\Http\Controllers\Api\Qr;

use App\Handlers\Qr\TenantQrHandler;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

final class TenantQrController extends Controller
{
    public function createTenantQr(Request $request, TenantQrHandler $handler): JsonResponse
    {

        $show_qrs = $handler->handle($request->user());

        return response()->json(['data' => $show_qrs], 200);
    }
}
