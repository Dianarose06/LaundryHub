<?php

use App\Http\Controllers\Web\AdminWebController;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::middleware('guest')->group(function () {
    Route::get('/admin/bridge-login', [AdminWebController::class, 'bridgeLogin'])->name('admin.bridge-login');

    Route::get('/login', function () {
        return view('auth.login');
    })->name('login');

    Route::post('/login', function (Request $request) {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        if (! Auth::attempt($credentials)) {
            return back()->withErrors([
                'email' => 'Invalid credentials.',
            ])->onlyInput('email');
        }

        $request->session()->regenerate();
        $loggedInUser = Auth::user();

        if (! $loggedInUser instanceof User || ! $loggedInUser->isAdmin()) {
            Auth::logout();

            return back()->withErrors([
                'email' => 'Admin access is required.',
            ])->onlyInput('email');
        }

        return redirect()->intended('/admin');
    })->name('login.attempt');
});

Route::middleware(['auth', 'isAdmin'])->group(function () {
    Route::get('/admin', [AdminWebController::class, 'dashboard'])->name('admin.dashboard');
    Route::patch('/admin/orders/{order}/status', [AdminWebController::class, 'updateOrderStatus'])
        ->name('admin.orders.status');
    Route::post('/admin/services', [AdminWebController::class, 'storeService'])
        ->name('admin.services.store');
    Route::put('/admin/services/{service}', [AdminWebController::class, 'updateService'])
        ->name('admin.services.update');
    Route::delete('/admin/services/{service}', [AdminWebController::class, 'destroyService'])
        ->name('admin.services.destroy');

    Route::post('/admin/add-on-services', [AdminWebController::class, 'storeAddOnService'])
        ->name('admin.add-ons.store');
    Route::put('/admin/add-on-services/{addOnService}', [AdminWebController::class, 'updateAddOnService'])
        ->name('admin.add-ons.update');
    Route::delete('/admin/add-on-services/{addOnService}', [AdminWebController::class, 'destroyAddOnService'])
        ->name('admin.add-ons.destroy');

    Route::post('/logout', function (Request $request) {
        Auth::logout();

        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('login');
    })->name('logout');
});
