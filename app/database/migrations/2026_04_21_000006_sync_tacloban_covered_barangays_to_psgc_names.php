<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    private const TACLOBAN_CITY = 'Tacloban City, Leyte';
    private const NEAR_START = 30;
    private const NEAR_END = 65;

    public function up(): void
    {
        $timestamp = now();
        $officialNames = $this->officialCoveredNames();

        $existingRows = DB::table('barangays')
            ->select(['id', 'name'])
            ->where('city', self::TACLOBAN_CITY)
            ->get();

        $existingBaseByNumber = [];
        foreach ($existingRows as $row) {
            [$number, $suffix] = $this->parseBarangayName((string) $row->name);

            if ($number === null || $suffix !== null) {
                continue;
            }

            if (! array_key_exists($number, $existingBaseByNumber)) {
                $existingBaseByNumber[$number] = (int) $row->id;
            }
        }

        $usedBaseIds = [];

        foreach ($officialNames as $officialName) {
            [$number, $suffix] = $this->parseBarangayName($officialName);

            if ($number === null) {
                continue;
            }

            $zone = $this->resolveServiceZone($number);
            $fees = $this->zoneFees($zone);

            if ($suffix === null && isset($existingBaseByNumber[$number])) {
                $baseId = $existingBaseByNumber[$number];

                if (! in_array($baseId, $usedBaseIds, true)) {
                    DB::table('barangays')
                        ->where('id', $baseId)
                        ->update([
                            'city' => self::TACLOBAN_CITY,
                            'name' => $officialName,
                            'zone' => $zone,
                            'pickup_fee' => $fees['pickup'],
                            'delivery_fee' => $fees['delivery'],
                            'is_active' => true,
                            'updated_at' => $timestamp,
                        ]);

                    $usedBaseIds[] = $baseId;

                    continue;
                }
            }

            $this->upsertBarangayByName($officialName, $zone, $fees, $timestamp);
        }

        DB::table('barangays')
            ->where('city', self::TACLOBAN_CITY)
            ->whereNotIn('name', $officialNames)
            ->delete();
    }

    public function down(): void
    {
        $timestamp = now();
        $simplifiedNames = $this->simplifiedCoveredNames();

        foreach ($simplifiedNames as $name) {
            [$number] = $this->parseBarangayName($name);

            if ($number === null) {
                continue;
            }

            $zone = $this->resolveServiceZone($number);
            $fees = $this->zoneFees($zone);

            $this->upsertBarangayByName($name, $zone, $fees, $timestamp);
        }

        DB::table('barangays')
            ->where('city', self::TACLOBAN_CITY)
            ->whereNotIn('name', $simplifiedNames)
            ->delete();
    }

    private function upsertBarangayByName(string $name, int $zone, array $fees, $timestamp): void
    {
        $existingId = DB::table('barangays')
            ->where('city', self::TACLOBAN_CITY)
            ->where('name', $name)
            ->value('id');

        $payload = [
            'city' => self::TACLOBAN_CITY,
            'name' => $name,
            'zone' => $zone,
            'pickup_fee' => $fees['pickup'],
            'delivery_fee' => $fees['delivery'],
            'is_active' => true,
            'updated_at' => $timestamp,
        ];

        if ($existingId) {
            DB::table('barangays')
                ->where('id', $existingId)
                ->update($payload);

            return;
        }

        DB::table('barangays')->insert($payload + [
            'created_at' => $timestamp,
        ]);
    }

    private function parseBarangayName(string $name): array
    {
        if (! preg_match('/(?:brgy|barangay)\\.?\\s*([0-9]+)(?:\\s*-\\s*([a-z]))?/i', $name, $matches)) {
            return [null, null];
        }

        $number = (int) $matches[1];
        $suffix = isset($matches[2]) && $matches[2] !== ''
            ? strtoupper((string) $matches[2])
            : null;

        return [$number, $suffix];
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
            default => ['pickup' => 35.00, 'delivery' => 50.00],
        };
    }

    private function simplifiedCoveredNames(): array
    {
        $names = [];

        for ($number = 20; $number <= 80; $number++) {
            $names[] = $number === 47
                ? 'Brgy 47 - Independencia'
                : 'Brgy '.$number;
        }

        return $names;
    }

    private function officialCoveredNames(): array
    {
        return [
            'Barangay 20',
            'Barangay 21',
            'Barangay 21-A',
            'Barangay 22',
            'Barangay 23',
            'Barangay 23-A',
            'Barangay 24',
            'Barangay 25',
            'Barangay 26',
            'Barangay 27',
            'Barangay 28',
            'Barangay 29',
            'Barangay 30',
            'Barangay 31',
            'Barangay 32',
            'Barangay 33',
            'Barangay 34',
            'Barangay 35',
            'Barangay 35-A',
            'Barangay 36',
            'Barangay 36-A',
            'Barangay 37',
            'Barangay 37-A',
            'Barangay 38',
            'Barangay 39',
            'Barangay 40',
            'Barangay 41',
            'Barangay 42',
            'Barangay 42-A',
            'Barangay 43',
            'Barangay 43-A',
            'Barangay 43-B',
            'Barangay 44',
            'Barangay 44-A',
            'Barangay 45',
            'Barangay 46',
            'Barangay 47',
            'Barangay 48',
            'Barangay 48-A',
            'Barangay 48-B',
            'Barangay 49',
            'Barangay 50',
            'Barangay 50-A',
            'Barangay 50-B',
            'Barangay 51',
            'Barangay 51-A',
            'Barangay 52',
            'Barangay 53',
            'Barangay 54',
            'Barangay 54-A',
            'Barangay 56',
            'Barangay 56-A',
            'Barangay 57',
            'Barangay 58',
            'Barangay 59',
            'Barangay 59-A',
            'Barangay 59-B',
            'Barangay 60',
            'Barangay 60-A',
            'Barangay 61',
            'Barangay 62',
            'Barangay 62-A',
            'Barangay 62-B',
            'Barangay 63',
            'Barangay 64',
            'Barangay 65',
            'Barangay 66',
            'Barangay 66-A',
            'Barangay 67',
            'Barangay 68',
            'Barangay 69',
            'Barangay 70',
            'Barangay 71',
            'Barangay 72',
            'Barangay 73',
            'Barangay 74',
            'Barangay 75',
            'Barangay 76',
            'Barangay 77',
            'Barangay 78',
            'Barangay 79',
            'Barangay 80',
        ];
    }
};
