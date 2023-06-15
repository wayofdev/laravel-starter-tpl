<?php

declare(strict_types=1);

namespace Database\Seeders;

use Database\Factories\CategoryFactory;
use Illuminate\Database\Seeder;
use Throwable;

final class CategorySeeder extends Seeder
{
    /**
     * @throws Throwable
     */
    public function run(): void
    {
        CategoryFactory::new()->times(10)->create();
    }
}
