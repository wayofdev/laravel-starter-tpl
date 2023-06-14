<?php

declare(strict_types=1);

namespace Laravel\Admin\Network\Controllers;

use Laravel\Http\Controller;
use Spatie\RouteAttributes\Attributes\Resource;

#[Resource(
    resource: 'network',
    apiResource: true,
    only: ['index'],
    names: 'api.admin.network',
    shallow: true
)]
final class NetworkController extends Controller
{
}
