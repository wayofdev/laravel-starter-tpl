<?php

declare(strict_types=1);

namespace Bridge\Laravel\Public\Network\Controllers;

use Bridge\Laravel\Http\Controller;
use Spatie\RouteAttributes\Attributes\Resource;

#[Resource(
    resource: 'network',
    apiResource: true,
    only: ['index'],
    names: 'api.public.network',
    shallow: true
)]
final class NetworkController extends Controller
{
}
