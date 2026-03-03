<?php
namespace App\DTO\Notifications;

use App\DTO\BaseDTO;

class CreateNotificationDTO extends BaseDTO
{
    public function __construct(
        public string $title,
        public string $message,
        public ?string $user_email = null,
        public bool $send_to_all = false,
    )
    {

    }
}
