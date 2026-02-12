<?php

namespace App\Http\Controllers\Api\Profile;

use App\Http\Controllers\Controller;
use App\Handlers\Profile\GetProfileQrsHandler;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

final class ProfileQrController extends Controller
{
    public function index(Request $request, GetProfileQrsHandler $handler): JsonResponse
    {

        $show_qrs = $handler->handle($request->user());

        return response()->json(['data' => $show_qrs], 200);
    }
}
