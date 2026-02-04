<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Requests\ResetPassword\PasswordResetRequest;
use App\Http\Requests\ResetPassword\PasswordForgotRequest;
use App\Http\Requests\ResetPassword\ValidateResetRequest;
use App\Handlers\Auth\LoginHandler;
use App\Handlers\Auth\RegisterHandler;
use App\Handlers\Auth\LogoutHandler;
use App\Handlers\Auth\PasswordResetHandler;
use App\DTO\Auth\LoginDTO;
use App\DTO\Auth\RegisterDTO;
use App\DTO\Auth\PasswordResetDTO;
use App\Http\Resources\AuthResource;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Facades\DB;
use App\Models\User;

class AuthController extends Controller
{
    public function __construct(
        private LoginHandler $loginHandler,
        private RegisterHandler $registerHandler,
        private LogoutHandler $logoutHandler,
        private PasswordResetHandler $passwordResetHandler,
    )
    {

    }
    public function register(RegisterRequest $request)
    {
        $dto = RegisterDTO::fromRequest($request->validated());
        $result = $this->registerHandler->handle($dto);

        return response()->json([
            'success' => true,
            'message' => 'Регистрация прошла успешно!',
            'user' => new AuthResource($result['user']),
            'token' => $result['token'],
        ],201);
    }

    public function login(LoginRequest $request)
    {
        $dto = LoginDTO::fromRequest($request->validated());

        try{
            $result = $this->loginHandler->handle($dto);

            return response()->json([
                'success' => true,
                'message' => 'Авторизация прошла успешно!',
                'user' => new AuthResource($result['user']),
                'token' => $result['token'],
            ]);
        }
        catch (\App\Exceptions\Auth\InvalidCredentialsException $e){
            return response()->json([
                'success' => false,
                'message' => 'Неверный логин или пароль!',
            ],401);
        }
    }
    public function logout(){
        $this->logoutHandler->handle(request());
        return response()->json([
            'success' => true,
            'message' => 'Вы успешно вышли'
        ]);
    }

    public function me()
    {
        return response()->json([
            'success' => true,
            'user' => new AuthResource(request()->user()),
        ]);
    }

    public function forgotPassword(PasswordForgotRequest $request)
    {
        $request->validated();

        $status = Password::sendResetLink(
            $request->only('email')
        );
        return response()->json([
            'message' => 'Если email зарегистрирован , на него будет отправлена ссылка для сброса пароля'
        ]);

    }

    public function resetPassword(PasswordResetRequest $request){
        $dto = PasswordResetDTO::fromRequest($request->validated());
        $status = $this->passwordResetHandler->handle($dto);

        if($status == Password::PASSWORD_RESET){
            return response()->json([
                'success' => true,
                'message' => 'пароль успешно изменен'
            ]);
        }
        return response()->json([
            'message' => 'Неверный токен или срок его действия истек'
        ],422);
    }

    public function checkToken(ValidateResetRequest $request)
    {
        $validated = $request->validated();
        $user = User::where('email', $validated['email'])->first();

        if (!$user) {
            return response()->json(['valid' => false]);
        }

        $exists = DB::table('password_reset_tokens')
            ->where('email', $validated['email'])
            ->where('token', hash('sha256', $validated['token']))
            ->exists();

        return response()->json(['valid' => $exists]);
    }

}



