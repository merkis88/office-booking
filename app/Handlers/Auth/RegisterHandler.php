<?php
namespace App\Handlers\Auth;

use App\DTO\Auth\RegisterDTO;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class RegisterHandler
{
    /**
     * Обработка регистрации пользователя
     *
     * @param RegisterDTO $dto
     * @return array
     */
    public function handle(RegisterDTO $dto): array
    {
        $user = User::create([
            'first_name' => $dto->first_name,
            'last_name' => $dto->last_name,
            'patronymic' => $dto->patronymic,
            'email' => $dto->email,
            'password' => Hash::make($dto->password),
            'photo' => $dto->photo,
            'post' => $dto->post,
            'company' => $dto->company,
            'role_id' => $dto->role_id ?? 3,
        ]);

        $token = $user->createToken('auth-token')->plainTextToken;

        return [
            'user' => $user,
            'token' => $token,
        ];
    }
}
