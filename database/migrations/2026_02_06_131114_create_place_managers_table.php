<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        /**
         * Run the migrations.
         */
        Schema::create('place_managers', function (Blueprint $table) {
            $table->id();

            $table->foreignId('place_id')->constrained('places')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();

            $table->foreignId('created_from_booking_id')
                ->nullable()
                ->constrained('bookings')
                ->nullOnDelete();

            $table->timestamps();

            $table->unique(['place_id', 'user_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('place_managers');
    }
};
