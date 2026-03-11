<?php
namespace App\Handlers\Services;

use App\Models\Service;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpFoundation\Response;

class ExportServiceHandler
{
    public function handle(Service $service): Response
    {
        $service->load([
            'user',
            'booking.place',
            'serviceType'
        ]);
        if(!$service->booking || !$service->booking->place){
            throw ValidationException::withMessages([
                'service' => ['Данные о бронировании или помещении не найдены']
            ]);
        }
        $data = [
            'service' => $service,
            'user' => $service->user,
            'booking' => $service->booking,
            'place' => $service->booking->place,
            'service_type' => $service->serviceType,
            'generated_at' => now()->format('d-m-Y H:i'),
            'company_name' => 'Бизнес центр "Рабочая точка."'
        ];

        $pdf = Pdf::loadView('pdfs.service', $data);
        $pdf->setPaper('A4');
        $pdf->setOptions([
            'defaultFont' => 'PT Sans',
            'isRemoteEnabled' => true,
            'isHtml5ParserEnabled' => true,
            'fontDir' => '/usr/share/fonts/truetype/custom',
        ]);
        $filename = sprintf(
            'Заявка_%d_%s.pdf',
            $service->id,
            $service->created_at->format('d.m.Y')
        );
        return $pdf->download($filename);
    }
}
