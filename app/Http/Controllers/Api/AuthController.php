<?php

namespace App\Http\Controllers\Api;

use App\DTO\Auth\ForgotPasswordDTO;
use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\ForgotPasswordRequest;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Requests\Auth\ResendVerificationRequest;
use App\Http\Requests\Auth\VerifyEmailRequest;
use App\Handlers\Auth\LoginHandler;
use App\Handlers\Auth\RegisterHandler;
use App\Handlers\Auth\LogoutHandler;
use App\Handlers\Auth\VerifyEmailHandler;
use App\Handlers\Auth\SendVerificationHandler;
use App\Handlers\Auth\SendTemporaryPasswordHandler;
use App\DTO\Auth\LoginDTO;
use App\DTO\Auth\RegisterDTO;
use App\Http\Resources\AuthResource;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Facades\DB;
use App\Models\User;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function __construct(
        private LoginHandler $loginHandler,
        private RegisterHandler $registerHandler,
        private LogoutHandler $logoutHandler,
        private VerifyEmailHandler $verifyEmailHandler,
        private SendVerificationHandler $sendVerificationHandler,
        private SendTemporaryPasswordHandler $sendTemporaryPasswordHandler,
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
        ],201);
    }
    public function verifyEmail(VerifyEmailRequest $request)
    {
        try {
            $dto = $request->toDTO();
            $user = $this->verifyEmailHandler->handle($dto);

            $token = $user->createToken('auth-token')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'Email успешно подтвержден',
                'user' => new AuthResource($user),
                'token' => $token,
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Ошибка подтверждения',
                'errors' => $e->errors()
            ], 422);
        }
    }
    public function resendVerification(ResendVerificationRequest $request)
    {
        try {
            $dto = $request->toDTO();
            $user = $this->sendVerificationHandler->resend($dto->email);

            return response()->json([
                'success' => true,
                'message' => 'Код подтверждения отправлен повторно',
            ]);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Ошибка',
                'errors' => $e->errors()
            ], 422);
        }
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

    public function forgotPassword(ForgotPasswordRequest $request)
    {
        try{
            $this->sendTemporaryPasswordHandler->handle($request->toDTO());
            return response()->json([
                'success' => true,
                'message' => 'Временный пароль отправлен на вашу почту'
            ]);
        }catch (ValidationException $e){
            return response()->json([
                'success' => false,
                'message' => 'Ошибка',
                'errors' => $e->errors()
            ],422);
        }catch(\Exception $e){
            return response()->json([
                'success' => false,
                'message' => 'Ошибка при отправке'
            ],500);
        }
    }


}



