<?php

declare(strict_types=1);

use WayOfDev\OpenDocs\Bridge\Laravel\Http\Controllers\RedocController;
use WayOfDev\OpenDocs\Bridge\Laravel\Http\Controllers\SwaggerController;

return [
    /*
     * Should documentation be generated on fly or loaded from file.
     */
    'on_fly' => true,

    'frontend' => [
        /*
         * Should swagger be enabled by default
         */
        'swagger' => [
            'enabled' => env('OPEN_DOCS_SWAGGER_ENABLED', true),

            'version' => '4.19.0',

            'controller' => SwaggerController::class,
        ],

        /*
         * Should redoc be enabled by default
         */
        'redoc' => [
            'enabled' => env('OPEN_DOCS_REDOC_ENABLED', true),

            'version' => '2.0.0',

            'controller' => RedocController::class,
        ],
    ],

    'collections' => [
        'public' => [
            'docs' => [
                'route' => [
                    'url' => '/api/public/docs',
                ],
            ],
            'redoc' => [
                'route' => [
                    'url' => '/api/public/redoc',
                ],
            ],
            'swagger' => [
                'route' => [
                    'url' => '/api/public/swagger',
                ],
            ],
            'paths' => [
                base_path('src/Application/Dto'),
                app_path('Public'),
            ],
        ],

        'admin' => [
            'docs' => [
                'route' => [
                    'url' => '/api/admin/docs',
                ],
            ],
            'redoc' => [
                'route' => [
                    'url' => '/api/admin/redoc',
                ],
            ],
            'swagger' => [
                'route' => [
                    'url' => '/api/admin/swagger',
                ],
            ],
            'paths' => [
                base_path('src/Application/Dto'),
                app_path('Admin'),
            ],
        ],
    ],
];
