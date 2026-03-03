<?php

namespace App\Http\Controllers\Api\Admin;

use App\Handlers\Notifications\CreateNotificationHandler;
use App\Http\Controllers\Controller;
use App\Http\Requests\Notifications\CreateNotificationRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Nette\Schema\ValidationException;

class AdminNotificationController extends Controller
{
    public function __construct(
        private CreateNotificationHandler $createNotificationHandler,
    )
    {

    }

    public function store(CreateNotificationRequest $request): JsonResponse
    {
        try{
            $this->createNotificationHandler->handle($request->toDTO(), $request->user());
            $message = $request->input('send_to_employee') ? 'Уведомление отправлено сотруднику' : 'Уведомление отправлено всемм';
            return response()->json([
                'success' => true,
                'message' => $message,
            ],201);
        } catch (ValidationException $e){
            return response()->json([
                'success' => false,
                'message' => 'Ошибка при отправке уведомления',
                'errors' => $e->errors()
            ],422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Ошибка при отправке уведомления' . $e->getMessage(),
            ],500);
        }
    }
}
