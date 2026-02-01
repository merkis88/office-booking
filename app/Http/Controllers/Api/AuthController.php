<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\AuthResource;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function register(RegisterRequest $request)
    {
        $validated = $request->validated();

        $user = User::create([
            'first_name' => $validated['first_name'],
            'last_name' => $validated['last_name'],
            'patronymic' => $validated['patronymic'] ?? null,
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'photo' => $validated['photo'] ?? null,
            'post' => $validated['post'] ?? null,
            'company' => $validated['company'] ?? null,
            'role_id' => $validated['role_id'] ?? 3,
        ]);

        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Регистрация прошла успешно!',
            'user' => new AuthResource($user),
            'token' => $token,
        ],201);
    }

    public function login(LoginRequest $request)
    {
        $validated = $request->validated();
        $user = User::where('email', $validated['email'])->first();

        if (!$user || !Hash::check($validated['password'], $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Неверный логин или пароль!'
            ]);
        }

        $token = $user->createToken('auth-token')->plainTextToken;
        return response()->json([
            'success' => true,
            'message' => 'Авторизация прошла успешно',
            'user' => $user,
            'token' => $token,
        ]);
    }
    public function logout(Request $request){
        $request->user()->currentAccessToken()->delete();
        return response()->json([
            'success' => true,
            'message' => 'Вы успешно вышли'
        ]);
    }

    public function me(Request $request)
    {
        return response()->json([
            'success' => true,
            'user' => $request->user()
        ]);
    }
}
//1|T9grYpVaBSfeu3gI9xt23OwK0r0ySn4lFdBA5LuSa3c6d826 токен 7 айди


