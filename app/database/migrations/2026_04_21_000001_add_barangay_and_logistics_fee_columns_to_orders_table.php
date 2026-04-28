<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasColumn('orders', 'pickup_barangay_id')) {
            Schema::table('orders', function (Blueprint $table) {
                $table->foreignId('pickup_barangay_id')
                    ->nullable()
                    ->after('pickup_address')
                    ->constrained('barangays')
                    ->nullOnDelete();
            });
        }

        if (!Schema::hasColumn('orders', 'pickup_city')) {
            Schema::table('orders', function (Blueprint $table) {
                $table->string('pickup_city', 100)
                    ->nullable()
                    ->after('pickup_barangay_id');
            });
        }

        if (!Schema::hasColumn('orders', 'pickup_barangay')) {
            Schema::table('orders', function (Blueprint $table) {
                $table->string('pickup_barangay', 120)
                    ->nullable()
                    ->after('pickup_city');
            });
        }

        if (!Schema::hasColumn('orders', 'pickup_fee')) {
            Schema::table('orders', function (Blueprint $table) {
                $table->decimal('pickup_fee', 10, 2)
                    ->default(0)
                    ->after('add_on_total');
            });
        }

        if (!Schema::hasColumn('orders', 'delivery_fee')) {
            Schema::table('orders', function (Blueprint $table) {
                $table->decimal('delivery_fee', 10, 2)
                    ->default(0)
                    ->after('pickup_fee');
            });
        }

        if (!Schema::hasColumn('orders', 'fee_zone')) {
            Schema::table('orders', function (Blueprint $table) {
                $table->string('fee_zone', 30)
                    ->nullable()
                    ->after('delivery_fee');
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('orders', 'pickup_barangay_id')) {
            Schema::table('orders', function (Blueprint $table) {
                $table->dropConstrainedForeignId('pickup_barangay_id');
            });
        }

        if (Schema::hasColumn('orders', 'pickup_city')) {
            Schema::table('orders', function (Blueprint $table) {
                $table->dropColumn('pickup_city');
            });
        }

        if (Schema::hasColumn('orders', 'pickup_barangay')) {
            Schema::table('orders', function (Blueprint $table) {
                $table->dropColumn('pickup_barangay');
            });
        }

        if (Schema::hasColumn('orders', 'pickup_fee')) {
            Schema::table('orders', function (Blueprint $table) {
                $table->dropColumn('pickup_fee');
            });
        }

        if (Schema::hasColumn('orders', 'delivery_fee')) {
            Schema::table('orders', function (Blueprint $table) {
                $table->dropColumn('delivery_fee');
            });
        }

        if (Schema::hasColumn('orders', 'fee_zone')) {
            Schema::table('orders', function (Blueprint $table) {
                $table->dropColumn('fee_zone');
            });
        }
    }
};
