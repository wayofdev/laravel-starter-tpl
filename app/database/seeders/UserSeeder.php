<?php

declare(strict_types=1);

namespace Database\Seeders;

use Database\Factories\UserFactory;
use Illuminate\Database\Seeder;
use Throwable;

final class UserSeeder extends Seeder
{
    /**
     * @throws Throwable
     */
    public function run(): void
    {
        UserFactory::new()->times(10)->create();
    }
}
