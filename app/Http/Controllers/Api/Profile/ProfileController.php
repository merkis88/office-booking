<?php

namespace App\Http\Controllers\Api\Profile;

use App\Handlers\Profile\DeleteProfileHandler;
use App\Handlers\Profile\GetProfileHandler;
use App\Handlers\Profile\UpdateProfileHandler;
use App\Handlers\Profile\UpdateProfilePhotoHandler;
use App\Http\Controllers\Controller;
use App\Http\Requests\Profile\UpdateProfileRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use App\Http\Requests\Profile\DeleteProfileRequest;
use App\Http\Requests\Profile\UpdateProfilePhotoRequest;

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

    public function update(UpdateProfileRequest $request, UpdateProfileHandler $handler): JsonResponse
    {
        $update = $handler->handle($request->user(), $request->validated());

        return response()->json(['data' => $update], 200);
    }

    public function updatePhoto(UpdateProfilePhotoRequest $request, UpdateProfilePhotoHandler $handler): JsonResponse
    {
        $update_photo = $handler->handle($request->user(), $request->photo());

        return response()->json(['data' => $update_photo], 200);
    }
}
