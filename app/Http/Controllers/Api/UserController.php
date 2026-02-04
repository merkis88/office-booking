<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\UserStoreRequest;
use App\Http\Requests\UserUpdateRequest;
use App\Http\Requests\UserUpdatePasswordRequest;
use App\Handlers\Users\CreateUserHandler;
use App\Handlers\Users\UpdateUserHandler;
use App\Handlers\Users\UpdatePasswordHandler;
use App\DTO\Users\CreateUserDTO;
use App\DTO\Users\UpdateUserDTO;
use App\DTO\Users\UpdatePasswordDTO;
use App\Http\Resources\UserResource;
use App\Models\User;

class UserController extends Controller
{
    /**
     * Display a listing of the resource.
     */

    public function __construct(
        private CreateUserHandler $createUserHandler,
        private UpdateUserHandler $updateUserHandler,
        private UpdatePasswordHandler $updatePasswordHandler,
    )
    {

    }
    public function index()
    {
        return UserResource::collection(User::all());
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(UserStoreRequest $request)
    {
        $dto = CreateUserDTO::fromRequest($request->validated());
        $user = $this->createUserHandler->handle($dto);

        return new UserResource($user);
    }

    /**
     * Display the specified resource.
     */
    public function show(User $user)
    {
        return new UserResource($user);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UserUpdateRequest $request, User $user)
    {
        $dto = UpdateUserDTO::fromRequest($request->validated());
        $updatedUser = $this->updateUserHandler->handle($user, $dto);

        return new UserResource($updatedUser);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(User $user)
    {
        $user->delete();
        return response(null,204);
    }

    public function updatePassword(UserUpdatePasswordRequest $request)
    {
        $dto = UpdatePasswordDTO::fromRequest($request->validated());
        try {
            $this->updatePasswordHandler->handle($request->user(), $dto);
            return response()->json([
               'message' => 'Пароль успешно обновлен'
            ],200);
        }
        catch(\Illuminate\Validation\ValidationException $e){
            return response()->json([
                'errors' => $e->errors()
            ],422);
        }
    }
}
