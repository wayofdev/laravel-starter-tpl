<?php

declare(strict_types=1);

namespace Tests\Functional;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;
use Illuminate\Support\Facades\Artisan;

abstract class TestCase extends BaseTestCase
{
    use CreatesApplication;

    public function setUp(): void
    {
        parent::setUp();

        Artisan::call('migrate:fresh');
        Artisan::call('db:seed');
    }
}
