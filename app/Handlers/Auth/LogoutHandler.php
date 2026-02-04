<?php
namespace App\Handlers\Auth;

use Illuminate\Http\Request;

class LogoutHandler
{
    /**
     * Обработка выхода пользователя
     *
     * @param Request $request
     * @return void
     */
    public function handle(Request $request): void
    {
        $request->user()->currentAccessToken()->delete();
    }
}
