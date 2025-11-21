<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ProductController;

Route::get('/', function () {
    return view('welcome');
});
Route::get('/products', function(){ return redirect()->route('products.index'); });
Route::resource('products', ProductController::class);