<?php
namespace App\Handlers\Notifications;

use App\Models\Notification;
use App\Models\User;
use Illuminate\Validation\ValidationException;

class DeleteNotificationHandler
{
    public function handle(Notification $notification, User $user): Void
    {
        if($notification->user_id !== $user->id){
            throw ValidationException::withMessages([
                'notification' => 'Уведомление не принадлежит этому пользователю',
            ]);
        }
        $notification->delete();
    }
}
