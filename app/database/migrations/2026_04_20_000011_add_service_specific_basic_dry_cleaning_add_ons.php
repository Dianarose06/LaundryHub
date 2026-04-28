<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $basicDryCleaningId = DB::table('services')
            ->where('name', 'Basic Dry Cleaning')
            ->value('id');

        if (! $basicDryCleaningId) {
            return;
        }

        $timestamp = now();

        DB::table('add_on_services')
            ->where('service_id', $basicDryCleaningId)
            ->update([
                'is_active' => false,
                'updated_at' => $timestamp,
            ]);

        $catalog = [
            [
                'name' => 'Stain Pre-Treatment',
                'description' => "Targeted treatment for tough stains like oil, ink, and food that basic dry cleaning alone can't fully remove.",
                'fee' => 50.00,
            ],
            [
                'name' => 'Garment Bag',
                'description' => 'Clean garments are placed in a protective bag to keep them fresh and dust-free after dry cleaning.',
                'fee' => 25.00,
            ],
        ];

        foreach ($catalog as $addOn) {
            $existingId = DB::table('add_on_services')
                ->where('service_id', $basicDryCleaningId)
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
                'service_id' => $basicDryCleaningId,
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
        $basicDryCleaningId = DB::table('services')
            ->where('name', 'Basic Dry Cleaning')
            ->value('id');

        if (! $basicDryCleaningId) {
            return;
        }

        DB::table('add_on_services')
            ->where('service_id', $basicDryCleaningId)
            ->delete();
    }
};
