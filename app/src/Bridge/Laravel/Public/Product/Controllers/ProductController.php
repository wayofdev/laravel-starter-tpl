<?php

declare(strict_types=1);

namespace Laravel\Public\Product\Controllers;

use Laravel\Http\Controller;
use Spatie\RouteAttributes\Attributes\Resource;

#[Resource(
    resource: 'products',
    apiResource: true,
    only: ['index', 'show'],
    names: 'api.public.products',
    shallow: true
)]
final class ProductController extends Controller
{
}
