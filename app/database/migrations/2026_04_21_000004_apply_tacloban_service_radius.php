<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    private const TACLOBAN_CITY = 'Tacloban City, Leyte';
    private const NEAR_START = 30;
    private const NEAR_END = 65;
    private const EXTENDED_START = 20;
    private const EXTENDED_END = 80;

    public function up(): void
    {
        $timestamp = now();

        $barangays = DB::table('barangays')
            ->select(['id', 'name'])
            ->where('city', self::TACLOBAN_CITY)
            ->get();

        foreach ($barangays as $barangay) {
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
                    'is_active' => $zone !== 3,
                    'updated_at' => $timestamp,
                ]);
        }
    }

    public function down(): void
    {
        $timestamp = now();

        $barangays = DB::table('barangays')
            ->select(['id', 'name'])
            ->where('city', self::TACLOBAN_CITY)
            ->get();

        foreach ($barangays as $barangay) {
            $number = $this->extractBarangayNumber((string) $barangay->name);

            if ($number === null) {
                continue;
            }

            $zone = $this->resolveLegacyZone($number);
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

    private function extractBarangayNumber(string $name): ?int
    {
        if (!preg_match('/Brgy\s*(\d+)/i', $name, $matches)) {
            return null;
        }

        return (int) $matches[1];
    }

    private function resolveServiceZone(int $barangayNumber): int
    {
        if ($barangayNumber >= self::NEAR_START && $barangayNumber <= self::NEAR_END) {
            return 1;
        }

        if ($barangayNumber >= self::EXTENDED_START && $barangayNumber <= self::EXTENDED_END) {
            return 2;
        }

        return 3;
    }

    private function resolveLegacyZone(int $barangayNumber): int
    {
        if ($barangayNumber >= 37 && $barangayNumber <= 57) {
            return 1;
        }

        if (($barangayNumber >= 24 && $barangayNumber <= 36)
            || ($barangayNumber >= 58 && $barangayNumber <= 78)) {
            return 2;
        }

        return 3;
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