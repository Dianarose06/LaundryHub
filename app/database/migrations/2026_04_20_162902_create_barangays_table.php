<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('barangays', function (Blueprint $table) {
            $table->id();
            $table->string('city', 100)->default('Tacloban City, Leyte');
            $table->string('name', 120);
            $table->unsignedTinyInteger('zone');
            $table->decimal('pickup_fee', 10, 2);
            $table->decimal('delivery_fee', 10, 2);
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->unique(['city', 'name']);
            $table->index(['city', 'zone']);
        });

        $this->seedTaclobanBarangays();
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('barangays');
    }

    private function seedTaclobanBarangays(): void
    {
        $city = 'Tacloban City, Leyte';
        $timestamp = now();
        $rows = [];

        for ($barangayNumber = 1; $barangayNumber <= 109; $barangayNumber++) {
            $zone = $this->resolveZone($barangayNumber);
            $fees = $this->zoneFees($zone);
            $name = $barangayNumber === 47
                ? 'Brgy 47 - Independencia'
                : 'Brgy '.$barangayNumber;

            $rows[] = [
                'city' => $city,
                'name' => $name,
                'zone' => $zone,
                'pickup_fee' => $fees['pickup'],
                'delivery_fee' => $fees['delivery'],
                'is_active' => true,
                'created_at' => $timestamp,
                'updated_at' => $timestamp,
            ];
        }

        DB::table('barangays')->insert($rows);
    }

    private function resolveZone(int $barangayNumber): int
    {
        $distanceFromBase = abs($barangayNumber - 47);

        if ($distanceFromBase <= 8) {
            return 1;
        }

        if ($distanceFromBase <= 25) {
            return 2;
        }

        return 3;
    }

    private function zoneFees(int $zone): array
    {
        return match ($zone) {
            1 => ['pickup' => 20.00, 'delivery' => 20.00],
            2 => ['pickup' => 35.00, 'delivery' => 35.00],
            default => ['pickup' => 50.00, 'delivery' => 50.00],
        };
    }
};
