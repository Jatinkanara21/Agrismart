<?php
return ['ml'=>['url'=>env('ML_SERVICE_URL'),'timeout'=>(int) env('ML_SERVICE_TIMEOUT',10),'connect_timeout'=>(int) env('ML_SERVICE_CONNECT_TIMEOUT',3)],'weather'=>['key'=>env('WEATHER_API_KEY')],'ai'=>['key'=>env('AI_API_KEY')]];
