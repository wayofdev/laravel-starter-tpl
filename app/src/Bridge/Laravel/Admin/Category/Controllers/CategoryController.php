<?php

declare(strict_types=1);

namespace Laravel\Admin\Category\Controllers;

use Domain\Category\Models\Category;
use Illuminate\Http\JsonResponse;
use Laravel\Admin\Category\Queries\IndexQuery;
use Laravel\Admin\Category\Transformers\CategoryTransformer;
use Laravel\Http\Controller;
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
