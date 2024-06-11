<?php

declare(strict_types=1);

namespace Bridge\Laravel\Providers\Domain;

use Domain\User\Exceptions\UserNotFoundException;
use Domain\User\Models\User;
use Illuminate\Contracts\Container\BindingResolutionException;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\ServiceProvider;

final class UserServiceProvider extends ServiceProvider
{
    /**
     * @throws BindingResolutionException
     */
    public function boot(): void
    {
        $this->bindUserEntity();
    }

    /**
     * @throws BindingResolutionException
     */
    private function bindUserEntity(): void
    {
        Route::bind('user', static function ($value) {
            /** @var User|null $category */
            // phpstan-ignore-next-line
            $category = User::where('uuid', $value)->first();

            if ($category === null) {
                throw new UserNotFoundException();
            }

            return $category;
        });
    }
}
