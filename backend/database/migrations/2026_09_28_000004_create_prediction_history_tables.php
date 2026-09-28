<?php
use Illuminate\Database\Migrations\Migration;use Illuminate\Database\Schema\Blueprint;use Illuminate\Support\Facades\Schema;
return new class extends Migration { public function up(): void {
Schema::create('crop_recommendations',function(Blueprint $t){$t->id();$t->foreignId('user_id')->constrained()->cascadeOnDelete();$t->json('inputs');$t->string('crop')->nullable();$t->decimal('confidence',8,5)->nullable();$t->string('status')->default('pending');$t->timestamps();});
Schema::create('disease_predictions',function(Blueprint $t){$t->id();$t->foreignId('user_id')->constrained()->cascadeOnDelete();$t->string('image_path')->nullable();$t->string('disease')->nullable();$t->decimal('confidence',8,5)->nullable();$t->string('status')->default('pending');$t->timestamps();});
Schema::create('yield_predictions',function(Blueprint $t){$t->id();$t->foreignId('user_id')->constrained()->cascadeOnDelete();$t->json('inputs');$t->decimal('estimated_yield',14,4)->nullable();$t->decimal('confidence',8,5)->nullable();$t->string('status')->default('pending');$t->timestamps();});
} public function down(): void { Schema::dropIfExists('yield_predictions');Schema::dropIfExists('disease_predictions');Schema::dropIfExists('crop_recommendations'); } };
