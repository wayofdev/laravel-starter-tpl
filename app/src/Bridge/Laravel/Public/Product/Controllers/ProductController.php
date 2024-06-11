<?php

declare(strict_types=1);

namespace Bridge\Laravel\Public\Product\Controllers;

use Bridge\Laravel\Http\Controller;
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
