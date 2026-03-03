<?php
namespace App\Handlers\Notifications;

use App\Models\Notification;
use App\Models\User;
use Illuminate\Validation\ValidationException;

class MarkNotificationAsReadHandler
{
    public function handle(Notification $notification, User $user): Notification
    {
        if($notification->user_id !== $user->id){
            throw ValidationException::withMessages([
                'notification' => ['Уведомление не принадлежит этому пользователю']
            ]);
        }

        if(!$notification->isRead()){
            $notification->markAsRead();
        }
        return $notification->fresh();
    }
}
