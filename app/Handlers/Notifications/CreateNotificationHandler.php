<?php
namespace App\Handlers\Notifications;

use App\DTO\Notifications\CreateNotificationDTO;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class CreateNotificationHandler
{
    public function handle(CreateNotificationDTO $dto, User $creator): void
    {
        if($dto->send_to_all){
            $this->sendToAll($dto, $creator);
        } else {
            $this->sendToEmployee($dto, $creator);
        }
    }
    private function sendToAll(CreateNotificationDTO $dto, User $creator): void
    {
        User::query()->chunk(100, function ($users) use ($dto, $creator) {
            $notifications = [];
            foreach ($users as $user) {
                $notifications[] = [
                    'title' => $dto->title,
                    'message' => $dto->message,
                    'created_by' => $creator->id,
                    'user_id' => $user->id,
                    'is_for_all' => true,
                    'created_at' => now(),
                    'updated_at' => now(),
                ];
            }
            Notification::insert($notifications);
        });
    }
    private function sendToEmployee(CreateNotificationDTO $dto, User $creator): void
    {
        $user = User::where('email', $dto->user_email)->firstOrFail();

        Notification::create([
            'title' => $dto->title,
            'message' => $dto->message,
            'created_by' => $creator->id,
            'user_id' => $user->id,
            'is_for_all' => false,
        ]);
    }
}
