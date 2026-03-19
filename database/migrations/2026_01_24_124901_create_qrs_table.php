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
        Schema::create('qrs', function (Blueprint $table) {
            $table->id();


            $table->foreignId('booking_id')->constrained('bookings')->cascadeOnDelete();
            $table->unsignedBigInteger('time_window');
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('recipient_email')->nullable();
            $table->string('hash')->unique();
            $table->dateTime('used_at')->nullable();
            $table->timestamps();
            $table->index('booking_id');
            $table->index('time_window');
            $table->index('user_id');
            $table->index('recipient_email');
            $table->index(['booking_id', 'time_window']);
            $table->unique(['booking_id', 'time_window', 'user_id'], 'qrs_booking_window_user_unique');
            $table->unique(['booking_id', 'time_window', 'recipient_email'], 'qrs_booking_window_email_unique');
        });



    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('qrs');
    }
};
