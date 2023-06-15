<?php

declare(strict_types=1);

namespace Laravel\Providers\Domain;

use Domain\Category\Exceptions\CategoryNotFoundException;
use Domain\Category\Models\Category;
use Illuminate\Contracts\Container\BindingResolutionException;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\ServiceProvider;

final class CategoryServiceProvider extends ServiceProvider
{
    /**
     * @throws BindingResolutionException
     */
    public function boot(): void
    {
        $this->bindCategoryEntity();
    }

    /**
     * @throws BindingResolutionException
     */
    private function bindCategoryEntity(): void
    {
        Route::bind('category', static function ($value) {
            /** @var Category|null $category */
            $category = Category::where('uuid', $value)->first();

            if (null === $category) {
                throw new CategoryNotFoundException();
            }

            return $category;
        });
    }
}
