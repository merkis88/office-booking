<?php
namespace App\Handlers\Auth;

use App\Models\User;
use App\Mail\VerificationCodeMail;
use Illuminate\Support\Facades\Mail;
use Illuminate\Validation\ValidationException;

class SendVerificationHandler{
    public function handle(User $user): void
    {
        $code = $user->generateVerificationCode();
        Mail::to($user->email)->send(new VerificationCodeMail($user,$code));
    }

    public function resend(string $email): User
    {
        $user = User::where('email', $email)->first();
        if (!$user) {
            throw ValidationException::withMessages([
                'email' => ['Пользователь с таким email не найден']
            ]);
        }
        if($user->is_verified){
            throw ValidationException::withMessages([
                'email' => 'email уже подтвержден'
            ]);
        }
        $this->handle($user);
        return $user;
    }
}
