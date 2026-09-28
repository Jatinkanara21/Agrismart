<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration { public function up(): void { Schema::create('farmer_profiles', function(Blueprint $table){ $table->id(); $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete(); $table->string('phone',30)->nullable(); $table->string('location')->nullable(); $table->string('soil_type')->nullable(); $table->string('farm_size')->nullable(); $table->timestamps(); }); } public function down(): void { Schema::dropIfExists('farmer_profiles'); } };
