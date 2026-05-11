<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('add_on_services', function (Blueprint $table) {
            $table->foreignId('service_id')
                ->nullable()
                ->after('id')
                ->constrained('services')
                ->nullOnDelete();
        });

        DB::table('services')
            ->where('name', 'Soft Wash')
            ->update([
                'description' => 'Gentle washing cycle designed for delicate and sensitive fabrics.',
                'updated_at' => now(),
            ]);

        $softWashId = DB::table('services')
            ->where('name', 'Soft Wash')
            ->value('id');

        if (! $softWashId) {
            return;
        }

        $timestamp = now();

        DB::table('add_on_services')
            ->where('service_id', $softWashId)
            ->update([
                'is_active' => false,
                'updated_at' => $timestamp,
            ]);

        $catalog = [
            [
                'name' => 'Antibacterial Boost',
                'description' => 'Kills germs and bacteria in your delicate clothes. Ideal for baby clothes and sensitive skin.',
                'fee' => 30.00,
            ],
            [
                'name' => 'Fabric Softener',
                'description' => 'Makes your delicate clothes softer and leaves a fresh long-lasting scent.',
                'fee' => 30.00,
            ],
            [
                'name' => 'Stain Removal Treatment',
                'description' => 'Pre-treatment for tough stains like oil, blood, and ink on delicate fabrics before washing.',
                'fee' => 35.00,
            ],
            [
                'name' => 'Ironing',
                'description' => 'Delicate clothes are neatly pressed and ironed after washing for a ready-to-wear finish.',
                'fee' => 50.00,
            ],
        ];

        foreach ($catalog as $addOn) {
            $existingId = DB::table('add_on_services')
                ->where('service_id', $softWashId)
                ->where('name', $addOn['name'])
                ->value('id');

            if ($existingId) {
                DB::table('add_on_services')
                    ->where('id', $existingId)
                    ->update([
                        'description' => $addOn['description'],
                        'fee' => $addOn['fee'],
                        'is_active' => true,
                        'updated_at' => $timestamp,
                    ]);

                continue;
            }

            DB::table('add_on_services')->insert([
                'service_id' => $softWashId,
                'name' => $addOn['name'],
                'description' => $addOn['description'],
                'fee' => $addOn['fee'],
                'is_active' => true,
                'created_at' => $timestamp,
                'updated_at' => $timestamp,
            ]);
        }
    }

    public function down(): void
    {
        DB::table('services')
            ->where('name', 'Soft Wash')
            ->update([
                'description' => 'Gentle wash for delicates and baby clothes',
                'updated_at' => now(),
            ]);

        DB::table('add_on_services')
            ->whereNotNull('service_id')
            ->delete();

        Schema::table('add_on_services', function (Blueprint $table) {
            $table->dropConstrainedForeignId('service_id');
        });
    }
};
