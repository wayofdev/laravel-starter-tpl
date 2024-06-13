<?php

declare(strict_types=1);

namespace Tests\Functional\Bridge\Laravel;

use PHPUnit\Framework\Attributes\Test;
use Tests\Functional\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic test example.
     */
    #[Test]
    public function the_application_returns_a_successful_response(): void
    {
        $response = $this->get('/');

        $response->assertStatus(200);
    }
}
