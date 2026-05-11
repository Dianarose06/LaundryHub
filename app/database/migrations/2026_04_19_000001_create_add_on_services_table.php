<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('add_on_services', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description')->nullable();
            $table->decimal('fee', 8, 2);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        DB::table('add_on_services')->insert([
            [
                'name' => 'Antibacterial Boost',
                'description' => 'Typical price range: PHP 20-50 per load.',
                'fee' => 20.00,
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Fabric Softener',
                'description' => 'Typical price range: PHP 15-35 per load.',
                'fee' => 15.00,
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Stain Removal Treatment',
                'description' => 'Typical price range: PHP 20-50 per garment or per load.',
                'fee' => 20.00,
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Ironing',
                'description' => 'Flat-rate ironing service to neatly press garments.',
                'fee' => 25.00,
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('add_on_services');
    }
};
