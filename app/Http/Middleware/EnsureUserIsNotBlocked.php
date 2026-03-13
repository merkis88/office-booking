<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

final class EnsureUserIsNotBlocked
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if ($user && $user->is_blocked) {
            return response()->json([
                'message' => 'Ваш профиль заблокирован',
            ], JsonResponse::HTTP_FORBIDDEN);
        }

        return $next($request);
    }
}
