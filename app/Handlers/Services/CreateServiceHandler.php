<?php
namespace App\Handlers\Services;

use App\DTO\Services\CreateServiceDTO;
use App\Models\Booking;
use App\Models\Service;
use App\Models\ServiceType;
use App\Models\User;
use Illuminate\Validation\ValidationException;

class CreateServiceHandler
{
    public function handle(CreateServiceDTO $dto, User $user): Service
    {
        $booking = Booking::where('id', $dto->booking_id)->where('user_id', $user->id)->where('status', 'active')->first();
        if (!$booking) {
            throw ValidationException::withMessages([
                'booking_id' => ['У вас нет активной аренды этого помещения'],
            ]);
        }
        $existingService = Service::where('booking_id', $booking->id)->where('service_date', $dto->service_date)->where('service_time',$dto->service_time)->whereIn('status', ['pending', 'in_progress'])->first();
        if ($existingService) {
            throw ValidationException::withMessages([
                'service_time' => ['На это время уже есть активная заявка']
            ]);
        }
        return Service::create([
            'user_id' => $user->id,
            'booking_id' => $booking->id,
            'place_id' => $booking->place_id,
            'service_type_id' => $dto->service_type_id,
            'service_date' => $dto->service_date,
            'service_time' => $dto->service_time,
            'comment' => $dto->comment,
            'status' => 'pending',
        ]);
    }
}
