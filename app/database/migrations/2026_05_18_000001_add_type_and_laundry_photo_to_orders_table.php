<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasColumn('orders', 'type')) {
            Schema::table('orders', function (Blueprint $table) {
                $table->string('type', 20)
                    ->default('pickup')
                    ->after('delivery_type');
            });
        }

        if (!Schema::hasColumn('orders', 'laundry_photo')) {
            Schema::table('orders', function (Blueprint $table) {
                $table->string('laundry_photo')
                    ->nullable()
                    ->after('type');
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('orders', 'laundry_photo')) {
            Schema::table('orders', function (Blueprint $table) {
                $table->dropColumn('laundry_photo');
            });
        }

        if (Schema::hasColumn('orders', 'type')) {
            Schema::table('orders', function (Blueprint $table) {
                $table->dropColumn('type');
            });
        }
    }
};
