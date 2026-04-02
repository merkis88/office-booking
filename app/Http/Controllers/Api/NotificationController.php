<?php

namespace App\Http\Controllers\Api;

use App\Handlers\Notifications\DeleteNotificationHandler;
use App\Handlers\Notifications\GetUserNotificationsHandler;
use App\Handlers\Notifications\MarkNotificationAsReadHandler;
use App\Http\Controllers\Controller;
use App\Http\Resources\NotificationResource;
use App\Models\Notification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function __construct(
        private GetUserNotificationsHandler $getUserNotificationsHandler,
        private DeleteNotificationHandler $deleteNotificationHandler,
        private MarkNotificationAsReadHandler $markNotificationAsReadHandler,
    ) {}

    public function index(Request $request)
    {
        $perPage = $request->query('perPage', 20);
        $notifications = $this->getUserNotificationsHandler->handle($request->user(), $perPage);

        return response()->json([
            'data' => NotificationResource::collection($notifications),
            'meta' => [
                'current_page' => $notifications->currentPage(),
                'last_page' => $notifications->lastPage(),
                'per_page' => $notifications->perPage(),
                'total' => $notifications->total(),
                'unread_count' => $request->user()->notifications()->unread()->count(),
            ],
        ]);
    }

    public function markAsRead(Request $request, Notification $notification): JsonResponse
    {
        $notification = $this->markNotificationAsReadHandler->handle($notification, $request->user());

        return response()->json([
            'message' => 'Уведомление отмечено как прочитанное',
            'data' => new NotificationResource($notification),
        ]);
    }

    public function markAllAsRead(Request $request): JsonResponse
    {
        $request->user()->notifications()->unread()->update(['read_at' => now()]);

        return response()->json([
            'message' => 'Все уведомления отмечены как прочитанные',
        ]);
    }

    public function destroy(Request $request, Notification $notification): JsonResponse
    {
        $this->deleteNotificationHandler->handle($notification, $request->user());

        return response()->json([
            'message' => 'Сообщение удалено',
        ]);
    }
}
