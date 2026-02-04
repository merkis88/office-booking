<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\ResetPassword\PasswordForgotRequest;
use App\Http\Requests\ResetPassword\PasswordResetRequest;
use App\Http\Requests\ResetPassword\ValidateResetRequest;
use App\Models\User;
use Illuminate\Auth\Events\PasswordReset;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;

class PasswordResetController extends Controller
{
    public function forgotPassword(PasswordForgotRequest $request)//запрос на сброс пароля
    {
         $request->validated();

         $status = Password::sendResetLink(
             $request->only('email')
         );
         return response()->json([
             'message' => 'Если email зарегистрирован , на него отправлена ссылка для сброса пароля'
         ]);
    }

    public function resetPassword(PasswordResetRequest $request)
    {
        $validated = $request->validated();

        $status = Password::reset($validated, function ($user, $password) {
            $user->forceFill([
                'password' => Hash::make($password),
            ])->setRememberToken(Str::random(60));
            $user->save();
            event(new PasswordReset($user));
        });

        if ($status == Password::PASSWORD_RESET) {
            return response()->json([
                'success' => true,
                'message' => 'Пароль успешно изменен!'
            ]);
        }
        return response()->json([
            'message' => 'Неверный токен или срок его действия истек'
        ], 422);
    }

    public function checkToken(ValidateResetRequest $request)//для фронта
    {
        $validated = $request->validated();

        $user = User::where('email', $validated['email'])->first();

        if(!$user) {
            return response()->json(['valid'=>false]);
        }
        $exists = DB::table('password_reset_tokens')->where('email', $validated['email'])->where('token', hash('sha256', $validated['token']))->exists();
        return response()->json(['valid'=>$exists]);
    }
}
