<?php

namespace App\Services\Qr;

use Carbon\CarbonInterface;


final class QrWindowService
{
    private int $windowSeconds = 1800;

    public function current(): int
    {
        return intdiv(now()->timestamp, $this->windowSeconds);
    }

    public function forDate(CarbonInterface $date): int
    {
        return intdiv($date->timestamp, $this->windowSeconds);
    }

}
