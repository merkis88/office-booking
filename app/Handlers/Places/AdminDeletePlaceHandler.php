<?php
namespace App\Handlers\Places;

use App\Models\Booking;
use App\Models\Notification;
use App\Models\Place;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;

class AdminDeletePlaceHandler
{
    const PHOTO_DIRECTORY = 'public/places';
    public function handle(Place $place): void
    {
        $activeBookings = Booking::where('place_id', $place->id)
            ->where('status', 'active')
            ->get();

        if($activeBookings->isNotEmpty()){
            foreach ($activeBookings as $booking) {
                $userId = $booking->user_id ?? $booking->created_by;

                if ($userId) {
                    $bookingTime = $booking->start_time->format('d.m.Y H:i');

                    Notification::create([
                        'user_id' => $userId,
                        'title' => 'Бронирование отменено (удаление помещения)',
                        'message' => "Помещение {$place->name} удалено. Ваше бронирование на {$bookingTime} было отменено. Для выяснения причин позвоните по номеру +7 (999) 123-45-67",
                        'created_by' => 1,
                        'is_for_all' => false,
                    ]);
                }
            }

            throw ValidationException::withMessages([
                'place' => ['Нельзя удалить помещение с активными бронированиями']
            ]);
        }
        if ($place->photo) {
            $fullPath = self::PHOTO_DIRECTORY . '/' . $place->photo;
            if (Storage::exists($fullPath)) {
                Storage::delete($fullPath);
            }
        }
        $place->delete();
    }
}
