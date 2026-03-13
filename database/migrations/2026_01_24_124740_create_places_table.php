<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('places', function (Blueprint $table) {
            $table->id();
            $table->string('photo')->nullable();
            $table->string('name');
            $table->enum('type', ['office', 'coworking', 'meeting'])->default('office');
            $table->integer('capacity')->default(1);
            $table->text('description');
            $table->decimal('price', 10, 2)->default(0);
            $table->integer('number_place');
            $table->boolean('is_active')->default(true);
            $table->dateTime('booking_start_time')->nullable();
            $table->dateTime('booking_end_time')->nullable();
            $table->smallInteger('cleanup_minutes')->nullable();
            $table->smallInteger('slot_step_minutes')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('places');
    }
};
