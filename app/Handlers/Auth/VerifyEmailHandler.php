<?php
namespace App\Handlers\Auth;

use App\DTO\Auth\VerifyEmailDTO;
use App\Models\User;
use Illuminate\Validation\ValidationException;

class VerifyEmailHandler{
    public function handle(VerifyEmailDTO $dto): User
    {
        $user = User::where('email', $dto->email)->first();

        if(!$user){
            throw ValidationException::withMessages([
                'email' => ['Пользователь с таким email не найден'],
            ]);
        }
        if($user->is_verified){
            throw ValidationException::withMessages([
                'email' => 'email уже подтвержден'
            ]);
        }
        if(!$user->verifyCode($dto->code)){
            throw ValidationException::withMessages([
                'code' => ['Неверный код подтверждения']
            ]);
        }
        $user->markAsVerified();

        return $user;
    }
}
