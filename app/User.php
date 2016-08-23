<?php

namespace App; // this might be just 'App' for you, as I prefer to put it in a folder called models
use Illuminate\Auth\Authenticatable;
//use Jenssegers\Mongodb\Eloquent\Model as Eloquent;

class User extends Moloquent implements \Illuminate\Contracts\Auth\Authenticatable
{
    use Authenticatable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'name', 'email', 'password',
    ];

    /**
     * The attributes excluded from the model's JSON form.
     *
     * @var array
     */
    protected $hidden = [
        'password', 'remember_token',
    ];

}
