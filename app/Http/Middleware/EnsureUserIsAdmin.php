<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class EnsureUserIsAdmin
{
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();

        if (!$user || (int) $user->role_id !== 1) {
            abort(403, 'Требуется права админа');
        }

        return $next($request);
    }
}
