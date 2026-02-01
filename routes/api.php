<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\PasswordResetController;
/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

Route::apiResources([
    'users' => UserController::class,
    ]);
Route::middleware('auth:sanctum')->group(function () {
    Route::put('user/password', [UserController::class, 'updatePassword']);
});
Route::post('/forgot-password', [PasswordResetController::class, 'forgotPassword'])->name('password.email');
Route::post('/reset-password', [PasswordResetController::class, 'resetPassword'])->name('password.update');
Route::post('/validate-reset-token', [PasswordResetController::class, 'checkToken'])->name('password.validate');
