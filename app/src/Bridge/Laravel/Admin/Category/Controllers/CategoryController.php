<?php

declare(strict_types=1);

namespace Laravel\Admin\Category\Controllers;

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

}
