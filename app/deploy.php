<?php

declare(strict_types=1);

namespace Deployer;

require 'recipe/laravel.php';
require 'contrib/slack.php';

set('application', 'laravel-starter-tpl');
set('repository', 'git@github.com:wayofdev/laravel-starter-tpl.git');

set('composer_options', '--verbose --no-progress --no-interaction --optimize-autoloader');
set('branch', function () {
    $stage = input()->getArgument('stage');

    return host($stage)->get('branch');
});

set('keep_releases', 3);

function getDefaultEnv(mixed $variable, mixed $default = null)
{
    $value = getenv($variable);
    return $value !== false ? $value : $default;
}

host('staging')
    ->set('branch', getDefaultEnv('DEPLOYER_STAGING_BRANCH', 'develop'))
    ->set('remote_user', getDefaultEnv('DEPLOYER_STAGING_REMOTE_USER', 'staging-trpqg'))
    ->set('base_deploy_path', '/home/{{ remote_user }}')
    ->set('hostname', getDefaultEnv('DEPLOYER_STAGING_HOST', 'staging.laravel-starter-tpl.wayof.dev'))
    ->set('deploy_path', '{{ base_deploy_path }}/{{ hostname}}')
    ->set('slack_webhook', getDefaultEnv('DEPLOYER_STAGING_SLACK_WEBHOOK'))
    ->set('sub_directory', 'app');

host('prod')
    ->set('branch', getDefaultEnv('DEPLOYER_PROD_BRANCH', 'master'))
    ->set('remote_user', getDefaultEnv('DEPLOYER_PROD_REMOTE_USER', 'prod-hi2sb'))
    ->set('base_deploy_path', '/home/{{ remote_user }}')
    ->set('hostname', getDefaultEnv('DEPLOYER_PROD_HOST', 'prod.laravel-starter-tpl.wayof.dev'))
    ->set('deploy_path', '{{ base_deploy_path }}/{{ hostname }}')
    ->set('slack_webhook', getDefaultEnv('DEPLOYER_PROD_SLACK_WEBHOOK'))
    ->set('sub_directory', 'app');

before('deploy', 'slack:notify');

task('deploy', [
    'deploy:prepare',
    'deploy:vendors',
    'artisan:storage:link',
    'artisan:cache:clear',
    'artisan:config:cache',
    'artisan:route:cache',
    'artisan:view:cache',
    'artisan:event:cache',
    'artisan:migrate',
    // 'artisan:db:seed',
    'deploy:publish',
]);

after('deploy:failed', 'deploy:unlock');
after('deploy:failed', 'slack:notify:failure');

after('deploy:success', 'slack:notify:success');
