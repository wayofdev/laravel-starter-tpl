<?php

declare(strict_types=1);

namespace Domain\User\Models;

use Database\Factories\RoleFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

final class Role extends Model
{
    use HasFactory;

    public static function resolveFactoryName(): string
    {
        return RoleFactory::class;
    }

    protected static function newFactory(): RoleFactory
    {
        return RoleFactory::new();
    }
}
