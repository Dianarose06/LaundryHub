<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            // Index for status filtering
            $table->index('status');
            // Index for date filtering
            $table->index('created_at');
            // Composite index for status + created_at queries (most common dashboard query pattern)
            $table->index(['status', 'created_at']);
        });

        Schema::table('users', function (Blueprint $table) {
            // Index for role filtering (find all customers)
            $table->index('role');
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropIndex(['status']);
            $table->dropIndex(['created_at']);
            $table->dropIndex(['status', 'created_at']);
        });

        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex(['role']);
        });
    }
};
