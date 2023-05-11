<?php

declare(strict_types=1);

namespace Laravel;

use Illuminate\Foundation\Application as LaravelApplication;

class Application extends LaravelApplication
{
    protected $namespace = 'Laravel\\';

    public function path($path = ''): string
    {
        return $this->basePath . DIRECTORY_SEPARATOR . 'src/Bridge/Laravel' . ($path ? DIRECTORY_SEPARATOR . $path : $path);
    }
}
