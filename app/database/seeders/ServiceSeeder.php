<?php

namespace Database\Seeders;

use App\Models\Service;
use Illuminate\Database\Seeder;

class ServiceSeeder extends Seeder
{
    public function run(): void
    {
        if (! Service::where('name', 'Basic Dry Cleaning')->exists()) {
            Service::where('name', 'Dry Cleaning')
                ->update(['name' => 'Basic Dry Cleaning']);
        }

        // Sprint 2 - Final 5 services with 8kg package pricing
        $services = [
            ['name' => 'Express Wash', 'description' => 'Need it fast? Your clothes are washed, dried, and folded in the shortest time possible.', 'price_per_kg' => 200, 'category' => 'Express', 'is_active' => true],
            ['name' => 'Soft Wash', 'description' => 'Gentle washing cycle designed for delicate and sensitive fabrics.', 'price_per_kg' => 75, 'category' => 'Premium', 'is_active' => true],
            ['name' => 'Beddings', 'description' => 'Specialized washing for bulky items like comforters, blankets, pillowcases, and bed sheets.', 'price_per_kg' => 180, 'category' => 'Basic', 'is_active' => true],
            ['name' => 'Wash-Dry-Fold', 'description' => 'Standard washing, drying, and neatly folding of everyday clothes.', 'price_per_kg' => 150, 'category' => 'Standard', 'is_active' => true],
            ['name' => 'Basic Dry Cleaning', 'description' => 'Professional chemical-based cleaning for special and delicate fabrics like suits, gowns, barong, and formal wear.', 'price_per_kg' => 150, 'category' => 'Specialty', 'is_active' => true],
        ];
        foreach ($services as $service) {
            Service::updateOrCreate(['name' => $service['name']], $service);
        }
    }
}