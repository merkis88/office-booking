<?php

namespace App\Handlers\Bookings;

use App\DTO\Bookings\AdminBookingsDTO;
use Symfony\Component\HttpFoundation\StreamedResponse;

final class AdminExportBookingsHandler
{
    public function handle(AdminBookingsDTO $dto, AdminListBookingsHandler $listHandler): StreamedResponse
    {
        $query = $listHandler->buildQuery($dto);

        $filename = 'bookings_' . now()->format('Ymd_His') . '.csv';

        return response()->streamDownload(function () use ($query) {
            $out = fopen('php://output', 'w');

            fprintf($out, chr(0xEF) . chr(0xBB) . chr(0xBF));

            fputcsv($out, [
                'id', 'status', 'place_id', 'place_name',
                'user_id', 'guest_name', 'created_by',
                'start_time', 'end_time', 'pass_type'
            ], ';');

            $query->chunk(500, function ($bookings) use ($out) {
                foreach ($bookings as $b) {
                    $placeName = $b->place->name ?? null;

                    fputcsv($out, [
                        $b->id,
                        $b->status,
                        $b->place_id,
                        $placeName,
                        $b->user_id,
                        $b->guest_name,
                        $b->created_by,
                        optional($b->start_time)?->format('Y-m-d H:i:s'),
                        optional($b->end_time)?->format('Y-m-d H:i:s'),
                        $b->pass_type,
                    ], ';');
                }
            });

            fclose($out);
        }, $filename, [
            'Content-Type' => 'text/csv; charset=UTF-8',
        ]);
    }
}
