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
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use App\Handlers\Admin\DeleteUserHandler;
use App\Handlers\Admin\BlockUserHandler;
use App\Handlers\Admin\UnblockUserHandler;
use App\Http\Requests\Admin\User\BlockUserRequest;
use App\Http\Requests\Admin\User\UnblockUserRequest;

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
    public function destroy(Request $request, User $user, DeleteUserHandler $handler): JsonResponse // merk
    {
        $delete_user = $handler->handler($user, $request->user());

        return response()->json(['data' => $delete_user], 200);
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

    public function block(BlockUserRequest $request, BlockUserHandler $handler): JsonResponse // merk
    {
        $block_user = $handler->handle($request->toDTO(), $request->user());

        return response()->json(['data' => $block_user], 200);
    }

    public function unBlock(UnblockUserRequest $request, UnblockUserHandler $handler): JsonResponse // merk
    {
        $unBlock_user = $handler->handle($request->getEmail(), $request->user());

        return response()->json(['data' => $unBlock_user], 200);
    }
}
