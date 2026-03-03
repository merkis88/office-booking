<?php
namespace App\Handlers\Notifications;

use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class GetUserNotificationsHandler
{
    public function handle(User $user, ?int $perPage = 20): LengthAwarePaginator
    {
        return $user->notifications()->with('creator')->orderBy('created_at', 'desc')->paginate($perPage);
    }
}
