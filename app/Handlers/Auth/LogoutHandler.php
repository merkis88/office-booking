<?php
namespace App\Handlers\Auth;

use Illuminate\Http\Request;

class LogoutHandler
{
    public function handle(Request $request): void
    {
        $request->user()->currentAccessToken()->delete();
    }
}
