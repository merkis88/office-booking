<?php

namespace App\Services\Qr;

final class QrWindowService
{
    private int $windowSeconds = 1800;

    public function current(): int
    {
        return intdiv(now()->timestamp, $this->windowSeconds);
    }
}
