<?php

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| Here is where you can register all of the routes for an application.
| It's a breeze. Simply tell Laravel the URIs it should respond to
| and give it the controller to call when that URI is requested.
|
*/

Route::get('/', 'HomeController@welcome');

Route::auth(); // login & register routes

/*
 * Routes for logged users
 */
Route::group(['middleware' => 'auth'], function() {
    Route::get('/id={id}', 'HomeController@hexawars');

    Route::get('/home', 'HomeController@index');
});

/*
 * //TODO: Routes for admin
 */
Route::group(['prefix' => 'admin', 'middleware' => ['auth', 'admin']], function() {
    Route::get('/', 'AdminController@index');
});

/*

Route::get('/uri-that-users-will-see',
    ['middleware' => ['auth','admin'], 'as' => 'your-route-name',
    'uses' => 'YourController@yourMethod']);

*/