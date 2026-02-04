<?php
namespace App\Handlers\Auth;

use App\DTO\Auth\LoginDTO;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use App\Exceptions\Auth\InvalidCredentialsException;

class LoginHandler
{
    /**
     * Обработка авторизации пользователя
     *
     * @param LoginDTO $dto
     * @return array
     * @throws InvalidCredentialsException
     */

    public function handle(LoginDTO $dto): array
    {
        $user = User::where('email', $dto->email)->first();
        if(!$user || !Hash::check($dto->password, $user->password)) {
            throw new InvalidCredentialsException();
        }

        $token = $user->createToken('auth-token')->plainTextToken;

        return [
            'user' => $user,
            'token' => $token,
        ];
    }
}
