<?php

use App\Http\Controllers\Web\AdminWebController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::view('/login', 'admin.index', ['adminPage' => 'login'])->name('login');

Route::get('/admin/bridge-login', [AdminWebController::class, 'bridgeLogin'])->name('admin.bridge-login');

Route::middleware(['auth', 'admin'])->group(function () {
        Route::view('/admin', 'admin.index', ['adminPage' => 'dashboard'])->name('admin.dashboard');
        Route::view('/admin/dashboard', 'admin.index', ['adminPage' => 'dashboard']);
        Route::view('/admin/{path}', 'admin.index', ['adminPage' => 'dashboard'])
            ->where('path', '.*')
            ->name('admin.spa');

        Route::patch('/admin/orders/{order}/status', [AdminWebController::class, 'updateOrderStatus'])
            ->name('admin.orders.status');

        Route::post('/admin/services', [AdminWebController::class, 'storeService'])
            ->name('admin.services.store');
        Route::put('/admin/services/{service}', [AdminWebController::class, 'updateService'])
            ->name('admin.services.update');
        Route::delete('/admin/services/{service}', [AdminWebController::class, 'destroyService'])
            ->name('admin.services.destroy');

        Route::post('/admin/add-ons', [AdminWebController::class, 'storeAddOnService'])
            ->name('admin.add-ons.store');
        Route::post('/admin/add-on-services', [AdminWebController::class, 'storeAddOnService']);
        Route::put('/admin/add-ons/{addOnService}', [AdminWebController::class, 'updateAddOnService'])
            ->name('admin.add-ons.update');
        Route::put('/admin/add-on-services/{addOnService}', [AdminWebController::class, 'updateAddOnService']);
        Route::delete('/admin/add-ons/{addOnService}', [AdminWebController::class, 'destroyAddOnService'])
            ->name('admin.add-ons.destroy');
        Route::delete('/admin/add-on-services/{addOnService}', [AdminWebController::class, 'destroyAddOnService']);
    });
