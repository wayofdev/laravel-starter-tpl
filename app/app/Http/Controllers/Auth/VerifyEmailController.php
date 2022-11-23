<?php

declare(strict_types=1);

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Providers\RouteServiceProvider;
use Illuminate\Auth\Events\Verified;
use Illuminate\Foundation\Auth\EmailVerificationRequest;
use Illuminate\Foundation\Auth\User;
use Illuminate\Http\RedirectResponse;

class VerifyEmailController extends Controller
{
    /**
     * Mark the authenticated user's email address as verified.
     *
     * @return RedirectResponse
     */
    public function __invoke(EmailVerificationRequest $request)
    {
        /** @var User $user */
        $user = $request->user();

        if ($user->hasVerifiedEmail()) {
            return redirect()->intended(
                config('app.frontend_url') . RouteServiceProvider::HOME . '?verified=1'
            );
        }

        if ($user->markEmailAsVerified()) {
            /* @phpstan-ignore-next-line */
            event(new Verified($user));
        }

        return redirect()->intended(
            config('app.frontend_url') . RouteServiceProvider::HOME . '?verified=1'
        );
    }
}
