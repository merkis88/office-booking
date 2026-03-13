<?php

namespace App\Http\Controllers\Api\Qr;

use App\DTO\Qr\IssueUserQrDTO;
use App\Handlers\Qr\CreateUserQrHandler;
use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\Qr;
use App\Models\User;

final class IssueUserQrController extends Controller
{
    public function __construct(private readonly CreateUserQrHandler $createUserQr){}

    public function handle(Booking $booking, User $user, IssueUserQrDTO $dto): Qr
    {
        $recipient = User::query()->findOrFail($dto->recipientUserId);

        return $this->createUserQr->createForRecipient($booking, $user, $recipient);

    }

}
