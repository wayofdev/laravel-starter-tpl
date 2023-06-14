<?php

declare(strict_types=1);

namespace Laravel\Public\User\Controllers;

use Laravel\Http\Controller;
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
