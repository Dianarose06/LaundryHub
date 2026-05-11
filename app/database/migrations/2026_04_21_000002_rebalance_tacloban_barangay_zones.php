<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $timestamp = now();

        $barangays = DB::table('barangays')
            ->select(['id', 'name'])
            ->where('city', 'Tacloban City, Leyte')
            ->get();

        foreach ($barangays as $barangay) {
            $number = $this->extractBarangayNumber((string) $barangay->name);

            if ($number === null) {
                continue;
            }

            $zone = $this->resolveZone($number);
            $fees = $this->zoneFees($zone);

            $name = $number === 47
                ? 'Brgy 47 - Independencia'
                : 'Brgy '.$number;

            DB::table('barangays')
                ->where('id', $barangay->id)
                ->update([
                    'name' => $name,
                    'zone' => $zone,
                    'pickup_fee' => $fees['pickup'],
                    'delivery_fee' => $fees['delivery'],
                    'updated_at' => $timestamp,
                ]);
        }
    }

    public function down(): void
    {
        $timestamp = now();

        $barangays = DB::table('barangays')
            ->select(['id', 'name'])
            ->where('city', 'Tacloban City, Leyte')
            ->get();

        foreach ($barangays as $barangay) {
            $number = $this->extractBarangayNumber((string) $barangay->name);

            if ($number === null) {
                continue;
            }

            $distanceFromBase = abs($number - 47);

            $zone = 3;
            if ($distanceFromBase <= 8) {
                $zone = 1;
            } elseif ($distanceFromBase <= 25) {
                $zone = 2;
            }

            $fees = $this->zoneFees($zone);

            DB::table('barangays')
                ->where('id', $barangay->id)
                ->update([
                    'name' => $number === 47 ? 'Brgy 47 - Independencia' : 'Brgy '.$number,
                    'zone' => $zone,
                    'pickup_fee' => $fees['pickup'],
                    'delivery_fee' => $fees['delivery'],
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

    private function resolveZone(int $barangayNumber): int
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
            1 => ['pickup' => 20.00, 'delivery' => 20.00],
            2 => ['pickup' => 35.00, 'delivery' => 35.00],
            default => ['pickup' => 50.00, 'delivery' => 50.00],
        };
    }
};
