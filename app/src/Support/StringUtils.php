<?php

declare(strict_types=1);

namespace Support;

use function strtolower;
use function ucwords;

/**
 * This is a stub class, just to show purpose of Support layer.
 */
final class StringUtils
{
    public static function toTitleCase(string $str): string
    {
        return ucwords(strtolower($str));
    }
}
