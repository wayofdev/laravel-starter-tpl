<?php

declare(strict_types=1);

namespace Database\Seeders;

use Database\Factories\CategoryFactory;
use Database\Factories\ProductFactory;
use Illuminate\Database\Seeder;
use Throwable;

final class ProductSeeder extends Seeder
{
    /**
     * @throws Throwable
     */
    public function run(): void
    {
        $category = CategoryFactory::new()->create();

        ProductFactory::new()
            ->times(10)
            ->for($category)
            ->create();
    }
}
