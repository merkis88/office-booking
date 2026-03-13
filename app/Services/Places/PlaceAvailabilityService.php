<?php
namespace App\Services\Places;

use App\Models\Booking;
use App\Models\Place;
use Carbon\CarbonImmutable;
use Illuminate\Support\Collection;

class PlaceAvailabilityService
{
    public function getAvailableSlots(Place $place, CarbonImmutable $date): Collection
    {
        $businessStart = 9;
        $businessEnd = 22;
        $slotDuration = 60;


        $bookings = Booking::query()
            ->where('place_id', $place->id)
            ->where('status', 'active')
            ->whereDate('start_time', $date)
            ->orderBy('start_time')
            ->get();

        $slots = collect();


        for ($hour = $businessStart; $hour < $businessEnd; $hour++) {
            $start = $date->setTime($hour, 0);
            $end = $start->addMinutes($slotDuration);

            if ($end->hour > $businessEnd || ($end->hour == $businessEnd && $end->minute > 0)) {
                continue;
            }

            $isAvailable = $this->isSlotAvailable($start, $end, $bookings);

            if ($isAvailable) {
                $slots->push([
                    'start' => $start->format('H:i'),
                    'end' => $end->format('H:i'),
                    'time' => $start->format('H:i') . ' - ' . $end->format('H:i'),
                ]);
            }
        }

        return $slots;
    }

    public function hasAvailableSlots(Place $place, CarbonImmutable $date): bool
    {
        return $this->getAvailableSlots($place, $date)->isNotEmpty();
    }


    private function isSlotAvailable(CarbonImmutable $start, CarbonImmutable $end, Collection $bookings): bool
    {
        foreach ($bookings as $booking) {
            $bookingStart = CarbonImmutable::parse($booking->start_time);
            $bookingEnd = CarbonImmutable::parse($booking->end_time);

            if ($start->between($bookingStart, $bookingEnd->subMinute()) || $end->between($bookingStart->addMinute(), $bookingEnd) || ($bookingStart <= $start && $bookingEnd >= $end)) {
                return false;
            }
        }
        return true;
    }

}
