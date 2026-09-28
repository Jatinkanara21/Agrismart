<?php

use IlluminateFoundationApplication;
use IlluminateFoundationConfigurationExceptions;
use IlluminateFoundationConfigurationMiddleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->statefulApi();
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        // Centralized exception customization can be added without leaking traces.
    })->create();
