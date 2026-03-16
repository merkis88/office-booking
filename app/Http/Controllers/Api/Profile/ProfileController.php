<?php

namespace App\Http\Controllers\Api\Profile;

use App\Handlers\Profile\DeleteProfileHandler;
use App\Handlers\Profile\GetProfileHandler;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use App\Http\Requests\Profile\DeleteProfileRequest;

final class ProfileController extends Controller
{
    public function profile(Request $request, GetProfileHandler $handler): JsonResponse
    {
        $profile = $handler->handle($request->user());

        return response()->json(['data' => $profile], 200);
    }

    public function delete(DeleteProfileRequest $request, DeleteProfileHandler $handler): JsonResponse
    {
        $handler->handle($request->user(), $request->string('password')->toString());

        return response()->json([], 200);
    }
}
