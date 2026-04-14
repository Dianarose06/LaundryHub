<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ServiceController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\BatchController;
use App\Http\Controllers\Api\CustomerProfileController;

// Public auth routes with tuned rate limits
Route::post('/register', [AuthController::class, 'register'])->middleware('throttle:auth-register');
Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:auth-login');
Route::post('/send-verification-code', [AuthController::class, 'sendVerificationCode'])->middleware('throttle:auth-challenge');
Route::post('/resend-verification', [AuthController::class, 'resendVerification'])->middleware('throttle:auth-challenge');
Route::post('/send-password-reset-code', [AuthController::class, 'sendPasswordResetCode'])->middleware('throttle:auth-challenge');
Route::post('/check-verification-code', [AuthController::class, 'checkVerificationCode'])->middleware('throttle:auth-action');
Route::post('/verify-code', [AuthController::class, 'verifyCode'])->middleware('throttle:auth-action');
Route::post('/reset-password', [AuthController::class, 'resetPassword'])->middleware('throttle:auth-action');

Route::middleware('throttle:api-public')->group(function () {
    Route::get('/services', [ServiceController::class, 'index']);
    Route::get('/services/{service}', [ServiceController::class, 'show']);

    // Public profile route
    Route::get('/profile/{userId}', [CustomerProfileController::class, 'publicProfile']);
});

Route::middleware(['auth:sanctum', 'throttle:api-auth'])->group(function () {
    Route::get('/user', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // Customer batch routes
    Route::get('/batch/home', [BatchController::class, 'home']);
    Route::get('/batch/profile', [BatchController::class, 'profile']);

    // Customer Profile Routes
    Route::get('/profile', [CustomerProfileController::class, 'show']);
    Route::put('/profile', [CustomerProfileController::class, 'update']);
    Route::post('/profile/change-password', [CustomerProfileController::class, 'changePassword']);
    Route::get('/profile/completion-status', [CustomerProfileController::class, 'completionStatus']);
    Route::post('/profile/upload-picture', [CustomerProfileController::class, 'uploadProfilePicture']);
    Route::delete('/profile/picture', [CustomerProfileController::class, 'deleteProfilePicture']);

    Route::get('/orders', [OrderController::class, 'index']);
    Route::post('/orders', [OrderController::class, 'store']);
    Route::get('/orders/{order}', [OrderController::class, 'show']);
    Route::patch('/orders/{order}/cancel', [OrderController::class, 'cancel']);
});

Route::middleware(['auth:sanctum', 'throttle:api-admin'])->prefix('admin')->group(function () {
    // Admin-only routes
    Route::get('/stats', [AdminController::class, 'stats']);
    Route::get('/orders/recent', [AdminController::class, 'recentOrders']);
    Route::get('/orders', [AdminController::class, 'orders']);
    Route::patch('/orders/{order}/status', [AdminController::class, 'updateOrderStatus']);
    Route::get('/top-customers', [AdminController::class, 'topCustomers']);
    Route::get('/analytics', [AdminController::class, 'analytics']);
    Route::get('/booking-summaries', [AdminController::class, 'bookingSummaries']);

    // Admin service management routes
    Route::get('/services', [ServiceController::class, 'adminIndex']);
    Route::post('/services', [ServiceController::class, 'store']);
    Route::put('/services/{service}', [ServiceController::class, 'update']);
    Route::delete('/services/{service}', [ServiceController::class, 'destroy']);

    // Admin customer profile routes
    Route::get('/customers', [AdminController::class, 'getCustomers']);
    Route::get('/customers/{userId}', [AdminController::class, 'getCustomerProfile']);
    Route::put('/customers/{userId}', [AdminController::class, 'updateCustomerProfile']);
    Route::get('/customers/{userId}/orders', [AdminController::class, 'getCustomerOrders']);
});