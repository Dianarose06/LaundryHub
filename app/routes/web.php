<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::redirect('/admin', '/admin/dashboard')->name('admin.index');
Route::view('/admin/dashboard', 'admin.index')->name('admin.dashboard');
Route::view('/admin/{path}', 'admin.index')
    ->where('path', '.*')
    ->name('admin.spa');
