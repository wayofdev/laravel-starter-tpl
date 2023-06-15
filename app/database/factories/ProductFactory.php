<?php

declare(strict_types=1);

namespace Database\Factories;

use Domain\Product\Models\Product;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Product>
 */
class ProductFactory extends Factory
{
    protected $model = Product::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'uuid' => $this->faker->uuid(),
            'name' => $this->faker->unique()->word(),
            'sku' => 'S' . $this->faker->numberBetween(1000, 999999),
            'status' => $this->faker->randomElement(['active', 'disabled']),
            'description' => $this->faker->text(),
        ];
    }
}
