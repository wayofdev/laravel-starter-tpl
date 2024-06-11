<?php

declare(strict_types=1);

namespace Bridge\Laravel\Console\Commands;

use Illuminate\Console\Command;

final class DemoCommand extends Command
{
    protected $signature = 'demo:command';

    protected $description = 'Demo command';

    public function handle(): void
    {
        $this->info('Demo command');
    }
}
