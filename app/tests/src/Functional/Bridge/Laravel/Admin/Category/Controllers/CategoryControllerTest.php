<?php

declare(strict_types=1);

namespace Tests\Functional\Bridge\Laravel\Admin\Category\Controllers;

use Domain\Category\Models\Category;
use Illuminate\Testing\Fluent\AssertableJson;
use PHPUnit\Framework\Attributes\Test;
use Tests\Functional\TestCase;

final class CategoryControllerTest extends TestCase
{
    private const string API_BASE_PATH = '/api/admin/categories';

    #[Test]
    public function it_gets_list_of_categories(): void
    {
        $category = Category::findOrFail(1);

        $response = $this->json('GET', self::API_BASE_PATH);
        $response
            ->assertJson(
                static fn (AssertableJson $json) => $json->has('current_page')
                    ->has('data')
                    ->has('first_page_url')
                    ->has('from')
                    ->has('last_page')
                    ->has('last_page_url')
                    ->has('links')
                    ->has('next_page_url')
                    ->has('path')
                    ->has('per_page')
                    ->has('prev_page_url')
                    ->has('to')
                    ->has('total')
                    ->has(
                        'data.0',
                        fn ($json) => $json->where('id', $category->id)
                            ->where('uuid', $category->uuid)
                            ->where('name', $category->name)
                            ->where('gender', $category->gender)
                            ->has('created_at')
                            ->has('updated_at')
                            ->etc()
                    )
            );
    }

    #[Test]
    public function it_gets_single_category(): void
    {
        $category = Category::findOrFail(1);

        $response = $this->json('GET', self::API_BASE_PATH . '/' . $category->uuid);

        // dd($response->getContent());

        $response
            ->assertJson(
                static fn (AssertableJson $json) => $json->has('data')
                    ->has(
                        'data.0',
                        fn ($json) => $json->where('id', $category->uuid)
                            ->where('name', $category->name)
                            ->where('gender', $category->gender)
                            ->has('created_at')
                            ->has('updated_at')
                            ->etc()
                    )
            );
    }
}
