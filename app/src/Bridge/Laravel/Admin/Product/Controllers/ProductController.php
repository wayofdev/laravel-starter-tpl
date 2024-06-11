<?php

declare(strict_types=1);

namespace Bridge\Laravel\Admin\Product\Controllers;

use Bridge\Laravel\Http\Controller;
use Spatie\RouteAttributes\Attributes\Resource;

#[Resource(
    resource: 'products',
    apiResource: true,
    only: ['index', 'show', 'store', 'update', 'delete'],
    names: 'api.admin.products',
    shallow: true
)]
final class ProductController extends Controller
{
}
