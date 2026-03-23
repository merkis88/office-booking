<?php

namespace App\Http\Controllers\Api\Admin;

use App\Handlers\Admin\GetUsersHandler;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;

final class AdminUserController extends Controller
{
    public function getUser(GetUsersHandler $handler): JsonResponse
    {
        $getUser = $handler->handle();

        return response()->json(['data' =>  $getUser], 200);
    }
}
