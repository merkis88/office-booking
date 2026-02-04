<?php
namespace App\Handlers\Users;

use App\DTO\Users\CreateUserDTO;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class CreateUserHandler
{
    /**
     * Создание нового пользователя
     *
     * @param CreateUserDTO $dto
     * @return User
     */
    public function handle(CreateUserDTO $dto): User
    {
        return User::create([
            'role_id' => $dto->role_id,
            'first_name' => $dto->first_name,
            'last_name' => $dto->last_name,
            'patronymic' => $dto->patronymic,
            'email' => $dto->email,
            'password' => Hash::make($dto->password),
            'post' => $dto->post,
            'company' => $dto->company,
            'photo' => $dto->photo,
        ]);
    }
}
