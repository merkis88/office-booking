<?php

namespace App\Http\Controllers\Api\Profile;

use App\Handlers\Profile\GetProfileHandler;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

final class ProfileController extends Controller
{
    public function profile(Request $request, GetProfileHandler $handler): JsonResponse
    {
        $profile = $handler->handle($request->user());

        return response()->json(['data' => $profile], 200);
    }
}
