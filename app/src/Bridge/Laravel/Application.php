<?php

declare(strict_types=1);

namespace Bridge\Laravel;

use Illuminate\Foundation\Application as LaravelApplication;

class Application extends LaravelApplication
{
    protected $namespace = 'Bridge\\Laravel\\';

    public function path($path = ''): string
    {
        return $this->basePath . DIRECTORY_SEPARATOR . 'src/Bridge/Laravel' . ($path !== '' ? DIRECTORY_SEPARATOR . $path : $path);
    }
}
