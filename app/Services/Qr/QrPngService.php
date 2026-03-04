<?php

namespace App\Services\Qr;

use Endroid\QrCode\Builder\Builder;
use Endroid\QrCode\Encoding\Encoding;
use Endroid\QrCode\ErrorCorrectionLevel;
use Endroid\QrCode\Writer\PngWriter;

final class QrPngService
{
    public function makePng(string $text, int $size = 360): string
    {
        $builder = new Builder(
            writer: new PngWriter(),
            data: $text,
            encoding: new Encoding('UTF-8'),
            errorCorrectionLevel: ErrorCorrectionLevel::High,
            size: $size,
            margin: 10,
        );

        $result = $builder->build();

        return $result->getString();
    }
}
