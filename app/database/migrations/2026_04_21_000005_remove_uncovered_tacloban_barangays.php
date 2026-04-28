<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    private const TACLOBAN_CITY = 'Tacloban City, Leyte';
    private const COVERED_START = 20;
    private const COVERED_END = 80;
    private const NEAR_START = 30;
    private const NEAR_END = 65;

    public function up(): void
    {
        $barangays = DB::table('barangays')
            ->select(['id', 'name'])
            ->where('city', self::TACLOBAN_CITY)
            ->get();

        $idsToDelete = [];

        foreach ($barangays as $barangay) {
            $number = $this->extractBarangayNumber((string) $barangay->name);

            if ($number === null) {
                continue;
            }

            if ($number < self::COVERED_START || $number > self::COVERED_END) {
                $idsToDelete[] = $barangay->id;
            }
        }

        if (! empty($idsToDelete)) {
            DB::table('barangays')
                ->whereIn('id', $idsToDelete)
                ->delete();
        }

        $timestamp = now();
        $coveredBarangays = DB::table('barangays')
            ->select(['id', 'name'])
            ->where('city', self::TACLOBAN_CITY)
            ->get();

        foreach ($coveredBarangays as $barangay) {
            $number = $this->extractBarangayNumber((string) $barangay->name);

            if ($number === null) {
                continue;
            }

            $zone = $this->resolveServiceZone($number);
            $fees = $this->zoneFees($zone);

            DB::table('barangays')
                ->where('id', $barangay->id)
                ->update([
                    'name' => $number === 47 ? 'Brgy 47 - Independencia' : 'Brgy '.$number,
                    'zone' => $zone,
                    'pickup_fee' => $fees['pickup'],
                    'delivery_fee' => $fees['delivery'],
                    'is_active' => true,
                    'updated_at' => $timestamp,
                ]);
        }
    }

    public function down(): void
    {
        $timestamp = now();

        for ($number = 1; $number <= 109; $number++) {
            if ($number >= self::COVERED_START && $number <= self::COVERED_END) {
                continue;
            }

            $name = $number === 47 ? 'Brgy 47 - Independencia' : 'Brgy '.$number;

            $alreadyExists = DB::table('barangays')
                ->where('city', self::TACLOBAN_CITY)
                ->where('name', $name)
                ->exists();

            if ($alreadyExists) {
                continue;
            }

            $zone = 3;
            $fees = $this->zoneFees($zone);

            DB::table('barangays')->insert([
                'city' => self::TACLOBAN_CITY,
                'name' => $name,
                'zone' => $zone,
                'pickup_fee' => $fees['pickup'],
                'delivery_fee' => $fees['delivery'],
                'is_active' => false,
                'created_at' => $timestamp,
                'updated_at' => $timestamp,
            ]);
        }
    }

    private function extractBarangayNumber(string $name): ?int
    {
        if (! preg_match('/Brgy\s*(\d+)/i', $name, $matches)) {
            return null;
        }

        return (int) $matches[1];
    }

    private function resolveServiceZone(int $barangayNumber): int
    {
        if ($barangayNumber >= self::NEAR_START && $barangayNumber <= self::NEAR_END) {
            return 1;
        }

        return 2;
    }

    private function zoneFees(int $zone): array
    {
        return match ($zone) {
            1 => ['pickup' => 20.00, 'delivery' => 30.00],
            2 => ['pickup' => 35.00, 'delivery' => 50.00],
            default => ['pickup' => 50.00, 'delivery' => 70.00],
        };
    }
};