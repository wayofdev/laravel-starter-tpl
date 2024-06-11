<?php

declare(strict_types=1);

namespace Tests\Functional\Bridge\Laravel;

// use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Functional\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic test example.
     *
     * @test
     */
    public function the_application_returns_a_successful_response(): void
    {
        $response = $this->get('/');

        $response->assertStatus(200);
    }
}
