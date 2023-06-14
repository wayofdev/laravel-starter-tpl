<?php

declare(strict_types=1);

namespace Laravel\Public\Category\Controllers;

use Laravel\Http\Controller;
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
