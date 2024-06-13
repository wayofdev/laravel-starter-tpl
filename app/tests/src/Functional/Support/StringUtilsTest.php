<?php

declare(strict_types=1);

namespace Tests\Functional\Support;

use PHPUnit\Framework\Attributes\Test;
use PHPUnit\Framework\TestCase;
use Support\StringUtils;

class StringUtilsTest extends TestCase
{
    #[Test]
    public function it_converts_string(): void
    {
        $input = 'hello world';
        $expectedOutput = 'Hello World';

        $actualOutput = StringUtils::toTitleCase($input);

        self::assertSame($expectedOutput, $actualOutput);
    }
}
