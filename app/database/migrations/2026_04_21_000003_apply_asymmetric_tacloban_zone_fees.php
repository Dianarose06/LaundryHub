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

            $zone = $this->resolveZone($number);
            $fees = $this->symmetricZoneFees($zone);

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
        // Explicit business zones around Brgy 47 (Independencia).
        $zoneOneNumbers = array_flip(range(37, 57));
        $zoneTwoNumbers = array_flip(array_merge(range(24, 36), range(58, 78)));

        if (isset($zoneOneNumbers[$barangayNumber])) {
            return 1;
        }

        if (isset($zoneTwoNumbers[$barangayNumber])) {
            return 2;
        }

        return 3;
    }

    private function zoneFees(int $zone): array
    {
        // Delivery includes return routing and scheduling overhead, so it is priced higher.
        return match ($zone) {
            1 => ['pickup' => 20.00, 'delivery' => 30.00],
            2 => ['pickup' => 35.00, 'delivery' => 50.00],
            default => ['pickup' => 50.00, 'delivery' => 70.00],
        };
    }

    private function symmetricZoneFees(int $zone): array
    {
        return match ($zone) {
            1 => ['pickup' => 20.00, 'delivery' => 20.00],
            2 => ['pickup' => 35.00, 'delivery' => 35.00],
            default => ['pickup' => 50.00, 'delivery' => 50.00],
        };
    }
};
