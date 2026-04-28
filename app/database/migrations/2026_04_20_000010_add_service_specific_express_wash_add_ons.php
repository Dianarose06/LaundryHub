<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $expressWashId = DB::table('services')
            ->where('name', 'Express Wash')
            ->value('id');

        if (! $expressWashId) {
            return;
        }

        $timestamp = now();

        DB::table('add_on_services')
            ->where('service_id', $expressWashId)
            ->update([
                'is_active' => false,
                'updated_at' => $timestamp,
            ]);

        $catalog = [
            [
                'name' => 'Antibacterial Boost',
                'description' => 'Kills germs and bacteria in your everyday clothes. Perfect for active and busy lifestyles.',
                'fee' => 30.00,
            ],
            [
                'name' => 'Fabric Softener',
                'description' => 'Makes your everyday clothes softer, reduces static, and leaves a fresh long-lasting scent.',
                'fee' => 30.00,
            ],
            [
                'name' => 'Stain Removal Treatment',
                'description' => 'Pre-treatment for tough stains like oil, blood, and ink on everyday clothes before washing.',
                'fee' => 35.00,
            ],
        ];

        foreach ($catalog as $addOn) {
            $existingId = DB::table('add_on_services')
                ->where('service_id', $expressWashId)
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
                'service_id' => $expressWashId,
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
        $expressWashId = DB::table('services')
            ->where('name', 'Express Wash')
            ->value('id');

        if (! $expressWashId) {
            return;
        }

        DB::table('add_on_services')
            ->where('service_id', $expressWashId)
            ->delete();
    }
};
