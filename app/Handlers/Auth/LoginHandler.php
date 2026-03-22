<?php
namespace App\Handlers\Auth;

use App\DTO\Auth\LoginDTO;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use App\Exceptions\Auth\InvalidCredentialsException;
use Illuminate\Validation\ValidationException;

class LoginHandler
{
    public function handle(LoginDTO $dto): array
    {
        $user = User::where('email', $dto->email)->first();

        if(!$user || !Hash::check($dto->password, $user->password)) {
            throw new InvalidCredentialsException();
        }

        if ($user->is_blocked) { // merk
            throw ValidationException::withMessages([ // merk
                'email' => ['Ваш профиль заблокирован'], // merk
            ]);
        }

        if (!$user->is_verified) {
            throw ValidationException::withMessages([
                'email' => ['Email не подтвержден. Пожалуйста, подтвердите регистрацию']
            ]);
        }

        $token = $user->createToken('auth-token')->plainTextToken;

        return [
            'user' => $user,
            'token' => $token,
        ];
    }
}
