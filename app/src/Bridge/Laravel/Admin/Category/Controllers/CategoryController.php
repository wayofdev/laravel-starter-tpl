<?php

declare(strict_types=1);

namespace Bridge\Laravel\Admin\Category\Controllers;

use Bridge\Laravel\Admin\Category\Queries\IndexQuery;
use Bridge\Laravel\Admin\Category\Transformers\CategoryTransformer;
use Bridge\Laravel\Http\Controller;
use Domain\Category\Models\Category;
use Illuminate\Http\JsonResponse;
use Spatie\RouteAttributes\Attributes\Resource;

#[Resource(
    resource: 'categories',
    apiResource: true,
    only: ['index', 'show', 'store', 'update', 'delete'],
    names: 'api.admin.categories',
    shallow: true
)]
final class CategoryController extends Controller
{
    public function index(IndexQuery $query): JsonResponse
    {
        $categories = $query->paginate();

        return response()->json($categories);
    }

    public function show(Category $category): JsonResponse
    {
        return fractal([$category], new CategoryTransformer())->respond(function (JsonResponse $response): void {
            $response->setStatusCode(200);
        });
    }
}
