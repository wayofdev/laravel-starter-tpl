<?php

declare(strict_types=1);

namespace Laravel\Admin\User\Controllers;

use Laravel\Http\Controller;
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
