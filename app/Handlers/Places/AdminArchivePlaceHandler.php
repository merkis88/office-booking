<?php
namespace App\Handlers\Places;

use App\Models\Booking;
use App\Models\Notification;
use App\Models\Place;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\Log;

class AdminArchivePlaceHandler
{
    public function archive(Place $place , bool $force = false): Place
    {
        if ($place->is_active == 0) {
            throw ValidationException::withMessages([
                'place' => ['Помещение "' . $place->name . '" уже находится в архиве']
            ]);
        }

        $activeBookingsCount = DB::table('bookings')
            ->where('place_id', $place->id)
            ->where('status', 'active')
            ->count();

        if ($activeBookingsCount > 0) {
            if($force){
                $activeBookings = Booking::where('place_id', $place->id)
                    ->where('status', 'active')
                    ->get();
                $updated = DB::table('bookings')
                    ->where('place_id', $place->id)
                    ->where('status', 'active')
                    ->update(['status' => 'cancelled']);

                if ($updated > 0) {
                    $this->sendCancellationNotifications($activeBookings, $place);
                    $place->update(['is_active' => false]);
                } else {
                    throw new \Exception('Не удалось отменить бронирования');
                }
            } else {
                throw ValidationException::withMessages([
                    'place' => ["У помещения {$activeBookingsCount} активных бронирований. Используйте force = 1 для принудительной архивации, все брони будут отменены"]
                ]);
            }
        }
        else{
            $place->update(['is_active' => false]);
        }

        return $place->fresh();
    }
    private function sendCancellationNotifications($bookings, Place $place): void
    {
        foreach ($bookings as $booking) {
            $userId = $booking->user_id ?? $booking->created_by;

            if (!$userId) {
                continue;
            }

            $bookingTime = $booking->start_time->format('d.m.Y H:i');

            Notification::create([
                'user_id' => $userId,
                'title' => 'Бронирование отменено (архивация помещения)',
                'message' => "Помещение {$place->name} отправлено в архив. Ваше бронирование на {$bookingTime} было отменено. Для выяснения причин позвоните по номеру +7 (999) 123-45-67",
                'created_by' => 1,
                'is_for_all' => false,
            ]);
        }
    }

    public function restore(Place $place): Place
    {
        if ($place->is_active == 1) {
            throw ValidationException::withMessages([
                'place' => ['Помещение "' . $place->name . '" не находится в архиве']
            ]);
        }
        $place->update(['is_active' => true]);
        return $place->fresh();
    }
}
