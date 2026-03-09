<?php

return [
    'timezone' => env('BC_TIMEZONE', config('app.timezone')),
    'open_hour' => (int) env('BC_OPEN_HOUR', 9),
    'close_hour' => (int) env('BC_CLOSE_HOUR', 22),
];
