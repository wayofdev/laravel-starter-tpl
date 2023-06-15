<?php

declare(strict_types=1);

namespace Domain\Shared;

use function array_column;

trait StringEnum
{
    public static function fromString(string $value): static
    {
        return static::from($value);
    }

    /**
     * @return string[]
     */
    public static function toArray(): array
    {
        return array_column(static::cases(), 'value');
    }

    public function toString(): string
    {
        return $this->value;
    }
}
