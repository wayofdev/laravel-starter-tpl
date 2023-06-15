<?php

declare(strict_types=1);

namespace Database\Factories;

use Domain\Category\Gender;
use Domain\Category\Models\Category;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Category>
 */
class CategoryFactory extends Factory
{
    protected $model = Category::class;

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
            'gender' => $this->faker->randomElement(Gender::cases()),
        ];
    }
}
