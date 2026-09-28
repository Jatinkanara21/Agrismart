<?php
use Illuminate\Database\Migrations\Migration;use Illuminate\Database\Schema\Blueprint;use Illuminate\Support\Facades\Schema;
return new class extends Migration { public function up(): void {
Schema::create('weather_records',function(Blueprint $t){$t->id();$t->foreignId('user_id')->nullable()->constrained()->nullOnDelete();$t->string('location');$t->json('payload');$t->timestamp('observed_at')->nullable();$t->timestamps();});
Schema::create('chat_sessions',function(Blueprint $t){$t->id();$t->foreignId('user_id')->constrained()->cascadeOnDelete();$t->string('title')->nullable();$t->timestamps();});
Schema::create('chat_messages',function(Blueprint $t){$t->id();$t->foreignId('chat_session_id')->constrained()->cascadeOnDelete();$t->string('role',20);$t->text('message');$t->timestamps();});
Schema::create('farming_decisions',function(Blueprint $t){$t->id();$t->foreignId('user_id')->constrained()->cascadeOnDelete();$t->json('inputs');$t->json('recommendation')->nullable();$t->string('status')->default('pending');$t->timestamps();});
Schema::create('notifications',function(Blueprint $t){$t->id();$t->foreignId('user_id')->constrained()->cascadeOnDelete();$t->string('title');$t->text('message');$t->timestamp('read_at')->nullable();$t->timestamps();});
} public function down(): void {foreach(['notifications','farming_decisions','chat_messages','chat_sessions','weather_records'] as $t) Schema::dropIfExists($t);} };
