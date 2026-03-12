<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('booking_summaries', function (Blueprint $table) {
            $table->id();
            $table->date('summary_date');
            $table->integer('total_bookings')->default(0);
            $table->integer('requested_bookings')->default(0);
            $table->integer('accepted_bookings')->default(0);
            $table->integer('declined_bookings')->default(0);
            $table->integer('completed_bookings')->default(0);
            $table->integer('cancelled_bookings')->default(0);
            $table->decimal('total_revenue', 10, 2)->default(0);
            $table->decimal('total_weight_kg', 10, 2)->default(0);
            $table->timestamps();
            
            $table->unique('summary_date');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('booking_summaries');
    }
};
