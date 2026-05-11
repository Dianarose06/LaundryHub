<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $timestamp = now();

        // Keep historical records intact by deactivating old catalog entries instead of deleting rows.
        DB::table('add_on_services')->update([
            'is_active' => false,
            'updated_at' => $timestamp,
        ]);

        $catalog = [
            [
                'name' => 'Antibacterial Boost',
                'description' => 'Typical price range: PHP 20-50 per load.',
                'fee' => 20.00,
            ],
            [
                'name' => 'Fabric Softener',
                'description' => 'Typical price range: PHP 15-35 per load.',
                'fee' => 15.00,
            ],
            [
                'name' => 'Stain Removal Treatment',
                'description' => 'Typical price range: PHP 20-50 per garment or per load.',
                'fee' => 20.00,
            ],
            [
                'name' => 'Ironing',
                'description' => 'Flat-rate ironing service to neatly press garments.',
                'fee' => 25.00,
            ],
        ];

        foreach ($catalog as $addOn) {
            $existingId = DB::table('add_on_services')
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
            } else {
                DB::table('add_on_services')->insert([
                    'name' => $addOn['name'],
                    'description' => $addOn['description'],
                    'fee' => $addOn['fee'],
                    'is_active' => true,
                    'created_at' => $timestamp,
                    'updated_at' => $timestamp,
                ]);
            }
        }
    }

    public function down(): void
    {
        $timestamp = now();

        DB::table('add_on_services')->update([
            'is_active' => false,
            'updated_at' => $timestamp,
        ]);

        $legacyCatalog = [
            [
                'name' => 'Free Delivery Promo',
                'description' => 'Promo add-on for free delivery when available.',
                'fee' => 0.00,
            ],
            [
                'name' => 'Downy Fabric Softener',
                'description' => 'Add Downy fabric softener to your laundry load.',
                'fee' => 15.00,
            ],
            [
                'name' => 'FabCon Fabric Conditioner',
                'description' => 'Add FabCon fabric conditioner for extra softness.',
                'fee' => 20.00,
            ],
            [
                'name' => 'Antibacterial Boost',
                'description' => 'Antibacterial treatment for added hygiene.',
                'fee' => 25.00,
            ],
        ];

        foreach ($legacyCatalog as $addOn) {
            $existingId = DB::table('add_on_services')
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
            } else {
                DB::table('add_on_services')->insert([
                    'name' => $addOn['name'],
                    'description' => $addOn['description'],
                    'fee' => $addOn['fee'],
                    'is_active' => true,
                    'created_at' => $timestamp,
                    'updated_at' => $timestamp,
                ]);
            }
        }
    }
};
