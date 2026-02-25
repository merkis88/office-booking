<?php

namespace App\Services\Qr;

use Illuminate\Support\Facades\DB;

final class QrCleanupService
{
    public function cleanupExpired(int $afterMinutes = 15, int $batch = 500): int
    {
        $cutoff = now()->subMinutes($afterMinutes);

        $totalDeleted = 0;

        while (true) {
            $ids = DB::table('qrs')
                ->join('bookings', 'bookings.id', '=', 'qrs.booking_id')
                ->where('bookings.end_time', '<=', $cutoff)
                ->orderBy('qrs.id')
                ->limit($batch)
                ->distinct()
                ->pluck('qrs.id');

            if ($ids->isEmpty()) {
                break;
            }

            $deleted = DB::table('qrs')
                ->whereIn('id', $ids)
                ->delete();

            $totalDeleted += $deleted;
        }
        return $totalDeleted;
    }
}
