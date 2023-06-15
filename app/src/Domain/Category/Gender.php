<?php

declare(strict_types=1);

namespace Domain\Category;

use Domain\Shared\StringEnum;

enum Gender: string
{
    use StringEnum;

    case MALE = 'male';

    case FEMALE = 'female';

    case OTHER = 'other';
}
