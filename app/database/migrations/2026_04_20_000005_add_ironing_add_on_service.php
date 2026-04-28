<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $timestamp = now();

        $ironing = [
            'name' => 'Ironing',
            'description' => 'Flat-rate ironing service to neatly press garments.',
            'fee' => 25.00,
        ];

        $existingId = DB::table('add_on_services')
            ->where('name', $ironing['name'])
            ->value('id');

        if ($existingId) {
            DB::table('add_on_services')
                ->where('id', $existingId)
                ->update([
                    'description' => $ironing['description'],
                    'fee' => $ironing['fee'],
                    'is_active' => true,
                    'updated_at' => $timestamp,
                ]);

            return;
        }

        DB::table('add_on_services')->insert([
            'name' => $ironing['name'],
            'description' => $ironing['description'],
            'fee' => $ironing['fee'],
            'is_active' => true,
            'created_at' => $timestamp,
            'updated_at' => $timestamp,
        ]);
    }

    public function down(): void
    {
        DB::table('add_on_services')
            ->where('name', 'Ironing')
            ->update([
                'is_active' => false,
                'updated_at' => now(),
            ]);
    }
};