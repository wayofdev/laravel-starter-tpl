<?php

declare(strict_types=1);

namespace Laravel\Public\Network\Controllers;

use Laravel\Http\Controller;
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
