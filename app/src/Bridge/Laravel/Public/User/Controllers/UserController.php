<?php

declare(strict_types=1);

namespace Bridge\Laravel\Public\User\Controllers;

use Bridge\Laravel\Http\Controller;
use Spatie\RouteAttributes\Attributes\Resource;

#[Resource(
    resource: 'users',
    apiResource: true,
    only: ['index', 'show'],
    names: 'api.public.users',
    shallow: true
)]
final class UserController extends Controller
{
}
