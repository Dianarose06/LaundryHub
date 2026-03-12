<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->date('pickup_date')->nullable()->after('pickup_address');
            $table->time('pickup_time')->nullable()->after('pickup_date');
            $table->date('delivery_date')->nullable()->after('pickup_time');
            $table->time('delivery_time')->nullable()->after('delivery_date');
            $table->text('admin_notes')->nullable()->after('notes');
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropColumn(['pickup_date', 'pickup_time', 'delivery_date', 'delivery_time', 'admin_notes']);
        });
    }
};
