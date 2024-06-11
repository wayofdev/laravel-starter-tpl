<?php

declare(strict_types=1);

namespace Bridge\Laravel\Public\Category\Controllers;

use Bridge\Laravel\Http\Controller;
use Spatie\RouteAttributes\Attributes\Resource;

#[Resource(
    resource: 'categories',
    apiResource: true,
    only: ['index', 'show'],
    names: 'api.public.categories',
    shallow: true
)]
final class CategoryController extends Controller
{
}
