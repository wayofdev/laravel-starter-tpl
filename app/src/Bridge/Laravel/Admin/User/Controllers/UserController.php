<?php

declare(strict_types=1);

namespace Bridge\Laravel\Admin\User\Controllers;

use Bridge\Laravel\Http\Controller;
use Spatie\RouteAttributes\Attributes\Resource;

#[Resource(
    resource: 'users',
    apiResource: true,
    only: ['index', 'show', 'store', 'update', 'delete'],
    names: 'api.admin.users',
    shallow: true
)]
final class UserController extends Controller
{
}
