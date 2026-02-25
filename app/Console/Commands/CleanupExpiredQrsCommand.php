<?php

namespace App\Console\Commands;

use App\Services\Qr\QrCleanupService;
use Illuminate\Console\Command;

final class CleanupExpiredQrsCommand extends Command
{
    protected $signature = 'qrs:cleanup-expired {--after=15} {--batch=500}';

    public function handle(QrCleanupService $service): int
    {
        $after = (int) $this->option('after');
        $batch = (int) $this->option('batch');

        $deleted = $service->cleanupExpired(afterMinutes: $after, batch: $batch);

        $this->info("Удалено Qr-кодов: {$deleted}");
        return self::SUCCESS;
    }
}
