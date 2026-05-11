<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::view('/admin', 'admin.index', ['adminPage' => 'login'])->name('admin.index');
Route::view('/admin/dashboard', 'admin.index', ['adminPage' => 'dashboard'])->name('admin.dashboard');
Route::view('/admin/{path}', 'admin.index', ['adminPage' => 'dashboard'])
    ->where('path', '.*')
    ->name('admin.spa');
