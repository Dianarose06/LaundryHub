<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $beddingsId = DB::table('services')
            ->where('name', 'Beddings')
            ->value('id');

        if (! $beddingsId) {
            return;
        }

        $timestamp = now();

        DB::table('add_on_services')
            ->where('service_id', $beddingsId)
            ->update([
                'is_active' => false,
                'updated_at' => $timestamp,
            ]);

        $catalog = [
            [
                'name' => 'Antibacterial Boost',
                'description' => 'Kills germs, dust mites, and bacteria in your beddings for a cleaner and healthier sleep.',
                'fee' => 30.00,
            ],
            [
                'name' => 'Fabric Softener',
                'description' => 'Leaves your beddings feeling softer and smelling fresh for a more comfortable sleep.',
                'fee' => 30.00,
            ],
            [
                'name' => 'Stain Removal Treatment',
                'description' => 'Pre-treatment for tough stains on beddings like oil, blood, and food stains before washing.',
                'fee' => 35.00,
            ],
        ];

        foreach ($catalog as $addOn) {
            $existingId = DB::table('add_on_services')
                ->where('service_id', $beddingsId)
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
                'service_id' => $beddingsId,
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
        $beddingsId = DB::table('services')
            ->where('name', 'Beddings')
            ->value('id');

        if (! $beddingsId) {
            return;
        }

        DB::table('add_on_services')
            ->where('service_id', $beddingsId)
            ->delete();
    }
};
