<?php
namespace App\Handlers\Auth;

use App\DTO\Auth\ForgotPasswordDTO;
use App\Mail\TemporaryPasswordMail;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class SendTemporaryPasswordHandler
{
    public function handle(ForgotPasswordDTO $dto): void
    {
        $user = User::where('email', $dto->email)->first();
        if(!$user){
            throw ValidationException::withMessages([
                'email' => ['Пользователя с такой почтой не найден']
            ]);
        }
        $temporaryPassword = Str::random(8);
        $user->password = Hash::make($temporaryPassword);
        $user->save();
        Mail::to($user->email)->send(new TemporaryPasswordMail($user, $temporaryPassword));
    }
}
