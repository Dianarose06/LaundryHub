<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        RateLimiter::for('auth-login', function (Request $request) {
            $email = strtolower((string) $request->input('email', 'guest'));

            return [
                Limit::perMinute(5)->by('login|ip|' . $request->ip()),
                Limit::perMinute(5)->by('login|email|' . $email . '|' . $request->ip()),
            ];
        });

        RateLimiter::for('auth-register', function (Request $request) {
            return Limit::perMinute(3)->by('register|' . $request->ip());
        });

        RateLimiter::for('auth-challenge', function (Request $request) {
            $email = strtolower((string) $request->input('email', 'guest'));

            return Limit::perMinute(3)->by('challenge|' . $email . '|' . $request->ip());
        });

        RateLimiter::for('auth-action', function (Request $request) {
            $email = strtolower((string) $request->input('email', 'guest'));

            return Limit::perMinute(8)->by('action|' . $email . '|' . $request->ip());
        });

        RateLimiter::for('api-public', function (Request $request) {
            return Limit::perMinute(120)->by('public|' . $request->ip());
        });

        RateLimiter::for('api-auth', function (Request $request) {
            $key = $request->user()?->id !== null
                ? 'auth|user|' . $request->user()->id
                : 'auth|ip|' . $request->ip();

            return Limit::perMinute(90)->by($key);
        });

        RateLimiter::for('api-admin', function (Request $request) {
            $key = $request->user()?->id !== null
                ? 'admin|user|' . $request->user()->id
                : 'admin|ip|' . $request->ip();

            return Limit::perMinute(180)->by($key);
        });
    }
}
