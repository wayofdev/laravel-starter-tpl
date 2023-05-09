<?php

declare(strict_types=1);

namespace Deployer;

require 'recipe/laravel.php';
require 'contrib/slack.php';

if (getenv('DEPLOYER_SENTRY_TOKEN')) {
    require 'contrib/sentry.php';
}

set('application', 'laravel-starter-tpl');
set('repository', 'git@github.com:wayofdev/laravel-starter-tpl.git');
set('base_deploy_path', '/home/ploi');

set('composer_options', '--verbose --no-progress --no-interaction --optimize-autoloader');
set('branch', function () {
    $stage = input()->getArgument('stage');

    return host($stage)->get('branch');
});

function getDefaultEnv(mixed $variable, mixed $default = null)
{
    $value = getenv($variable);
    return $value !== false ? $value : $default;
}

host('staging')
    ->set('branch', getDefaultEnv('DEPLOYER_STAGING_BRANCH', 'develop'))
    ->set('remote_user', getDefaultEnv('DEPLOYER_STAGING_REMOTE_USER', 'staging-crhev'))
    ->set('base_deploy_path', '/home/{{ remote_user }}')
    ->set('hostname', getDefaultEnv('DEPLOYER_STAGING_HOST', 'staging.laravel-starter-tpl.wayof.dev'))
    ->set('deploy_path', '{{ base_deploy_path }}/{{ hostname}}')
    ->set('slack_webhook', getDefaultEnv('DEPLOYER_STAGING_SLACK_WEBHOOK'))
    ->set('sub_directory', 'app');

host('prod')
    ->set('branch', getDefaultEnv('DEPLOYER_PROD_BRANCH', 'master'))
    ->set('remote_user', getDefaultEnv('DEPLOYER_PROD_REMOTE_USER', 'prod-ibce8'))
    ->set('base_deploy_path', '/home/{{ remote_user }}')
    ->set('hostname', getDefaultEnv('DEPLOYER_PROD_HOST', 'prod.laravel-starter-tpl.wayof.dev'))
    ->set('deploy_path', '{{ base_deploy_path }}/{{ hostname }}')
    ->set('slack_webhook', getDefaultEnv('DEPLOYER_PROD_SLACK_WEBHOOK'))
    ->set('sub_directory', 'app');

if (getenv('DEPLOYER_SENTRY_TOKEN')) {
    set('sentry', [
        'organization' => getDefaultEnv('DEPLOYER_SENTRY_ORG', 'wayofdev'),
        'projects' => [getDefaultEnv('DEPLOYER_SENTRY_PROJECT', 'laravel-starter-tpl')],
        'token' => getDefaultEnv('DEPLOYER_SENTRY_TOKEN'),
        'sentry_server' => getDefaultEnv('DEPLOYER_SENTRY_SERVER', 'https://sentry.io/'),
    ]);
}

before('deploy', 'slack:notify');

task('deploy', [
    'deploy:prepare',
    'deploy:vendors',
    'artisan:storage:link',
    'artisan:config:cache',
    'artisan:route:cache',
    'artisan:view:cache',
    'artisan:event:cache',
    'artisan:migrate',
    'deploy:publish',
]);

after('deploy:failed', [
    'deploy:unlock',
    'slack:notify:failure',
]);

after('deploy:success', 'slack:notify:success');

if (getenv('DEPLOYER_SENTRY_TOKEN')) {
    after('deploy', 'deploy:sentry');
}
