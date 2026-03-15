<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            // Change status from varchar to enum with all valid statuses
            $table->enum('status', ['pending', 'ongoing', 'ready', 'completed', 'cancelled'])->default('pending')->change();
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            // Revert to varchar
            $table->string('status')->default('pending')->change();
        });
    }
};
