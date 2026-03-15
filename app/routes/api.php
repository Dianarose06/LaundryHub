<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ServiceController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\AdminController;

// Public auth routes with rate limiting
Route::post('/register', [AuthController::class, 'register'])->middleware('throttle:5,15');
Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:5,15');
Route::post('/send-verification-code', [AuthController::class, 'sendVerificationCode'])->middleware('throttle:3,15');
Route::post('/check-verification-code', [AuthController::class, 'checkVerificationCode'])->middleware('throttle:5,15');
Route::post('/resend-verification', [AuthController::class, 'resendVerification'])->middleware('throttle:3,15');
Route::post('/verify-code', [AuthController::class, 'verifyCode'])->middleware('throttle:5,15');
Route::post('/send-password-reset-code', [AuthController::class, 'sendPasswordResetCode'])->middleware('throttle:3,15');
Route::post('/reset-password', [AuthController::class, 'resetPassword'])->middleware('throttle:5,15');

Route::get('/services', [ServiceController::class, 'index']);
Route::get('/services/{service}', [ServiceController::class, 'show']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/orders', [OrderController::class, 'index']);
    Route::post('/orders', [OrderController::class, 'store']);
    Route::get('/orders/{order}', [OrderController::class, 'show']);
    Route::patch('/orders/{order}/cancel', [OrderController::class, 'cancel']);

    // Admin-only routes
    Route::get('/admin/stats', [AdminController::class, 'stats']);
    Route::get('/admin/orders/recent', [AdminController::class, 'recentOrders']);
    Route::get('/admin/orders', [AdminController::class, 'orders']);
    Route::patch('/admin/orders/{order}/status', [AdminController::class, 'updateOrderStatus']);
    Route::get('/admin/top-customers', [AdminController::class, 'topCustomers']);
    Route::get('/admin/analytics', [AdminController::class, 'analytics']);
    
    // Admin service management routes
    Route::get('/admin/services', [ServiceController::class, 'adminIndex']);
    Route::post('/admin/services', [ServiceController::class, 'store']);
    Route::put('/admin/services/{service}', [ServiceController::class, 'update']);
    Route::delete('/admin/services/{service}', [ServiceController::class, 'destroy']);
});