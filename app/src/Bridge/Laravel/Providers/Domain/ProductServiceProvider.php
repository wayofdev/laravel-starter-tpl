<?php

declare(strict_types=1);

namespace Laravel\Providers\Domain;

use Domain\Product\Exceptions\ProductNotFoundException;
use Domain\Product\Models\Product;
use Illuminate\Contracts\Container\BindingResolutionException;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\ServiceProvider;

final class ProductServiceProvider extends ServiceProvider
{
    /**
     * @throws BindingResolutionException
     */
    public function boot(): void
    {
        $this->bindProductEntity();
    }

    /**
     * @throws BindingResolutionException
     */
    private function bindProductEntity(): void
    {
        Route::bind('product', static function ($value) {
            /** @var Product|null $category */
            $category = Product::where('uuid', $value)->first();

            if ($category === null) {
                throw new ProductNotFoundException();
            }

            return $category;
        });
    }
}
