<?php

declare(strict_types=1);

namespace Bridge\Laravel;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as BaseConsoleKernel;

final class ConsoleKernel extends BaseConsoleKernel
{
    /**
     * Define the application's command schedule.
     */
    protected function schedule(Schedule $schedule): void
    {
        // $schedule->command('inspire')->hourly();
    }

    /**
     * Register the commands for the application.
     */
    protected function commands(): void
    {
        $this->load(__DIR__ . '/Console/Commands');
    }
}
