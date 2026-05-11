<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Barangay;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class BarangayController extends Controller
{
    private const TACLOBAN_CITY = 'Tacloban City, Leyte';

    private static ?array $psgcOldNameByBarangayName = null;

    private function psgcOldNameByBarangayName(): array
    {
        if (self::$psgcOldNameByBarangayName !== null) {
            return self::$psgcOldNameByBarangayName;
        }

        $path = base_path('../psgc_tacloban_barangays.json');
        $map = [];

        if (is_file($path)) {
            $json = @file_get_contents($path);
            $rows = is_string($json) ? json_decode($json, true) : null;
            if (is_array($rows)) {
                foreach ($rows as $row) {
                    if (!is_array($row)) {
                        continue;
                    }

                    $name = isset($row['name']) ? trim((string) $row['name']) : '';
                    if ($name === '') {
                        continue;
                    }

                    $oldName = isset($row['oldName']) ? trim((string) $row['oldName']) : '';
                    if ($oldName === '') {
                        continue;
                    }

                    $map[$name] = $oldName;
                }
            }
        }

        // Manual overrides where we have known/common aliases.
        $map['Barangay 47'] = $map['Barangay 47'] ?? 'Independencia';

        self::$psgcOldNameByBarangayName = $map;

        return self::$psgcOldNameByBarangayName;
    }

    private function formatDisplayName(string $name, ?string $oldName = null): string
    {
        $normalizedName = trim($name);
        $normalizedOldName = trim((string) $oldName);

        if ($normalizedOldName === '') {
            return $normalizedName;
        }

        if (Str::contains(Str::lower($normalizedName), Str::lower($normalizedOldName))) {
            return $normalizedName;
        }

        return $normalizedName.' ('.$normalizedOldName.')';
    }

    private function debugLog(string $runId, string $hypothesisId, string $location, string $message, array $data = []): void
    {
        // #region agent log
        try {
            $payload = [
                'sessionId' => '1ad334',
                'runId' => $runId,
                'hypothesisId' => $hypothesisId,
                'location' => $location,
                'message' => $message,
                'data' => $data,
                'timestamp' => (int) round(microtime(true) * 1000),
            ];
            $path = storage_path('logs/debug-1ad334.log');
            @file_put_contents($path, json_encode($payload, JSON_UNESCAPED_SLASHES).PHP_EOL, FILE_APPEND);
        } catch (\Throwable $e) {
            // swallow
        }
        // #endregion
    }

    private function logisticsFeeExplanation(): array
    {
        return [
            'delivery_can_be_higher' => true,
            'pickup_applies_when' => 'delivery_type is pickup',
            'delivery_applies_when' => 'always',
            'reason' => 'Delivery includes route planning, customer handoff coordination, and possible wait time.',
        ];
    }

    public function index(Request $request)
    {
        $validated = $request->validate([
            'search' => 'nullable|string|max:100',
        ]);

        $search = trim((string) ($validated['search'] ?? ''));
        $runId = $request->header('X-Debug-Run-Id', 'pre-fix');
        $this->debugLog(
            (string) $runId,
            'H1',
            __FILE__.':'.__LINE__,
            'BarangayController@index called',
            [
                'search_present' => $search !== '',
                'search_len' => Str::length($search),
            ]
        );

        $query = Barangay::query()
            ->active()
            ->where('city', self::TACLOBAN_CITY);

        if ($search !== '') {
            $query->where('name', 'like', '%'.$search.'%');
        }

        $oldNameByName = $this->psgcOldNameByBarangayName();

        $barangays = $query
            ->orderBy('zone')
            ->orderBy('id')
            ->get()
            ->map(function (Barangay $barangay) use ($oldNameByName) {
                $name = (string) $barangay->name;
                $oldName = trim((string) ($oldNameByName[$name] ?? ''));

                return [
                    'id' => $barangay->id,
                    'city' => $barangay->city,
                    'name' => $name,
                    'old_name' => $oldName !== '' ? $oldName : null,
                    'display_name' => $this->formatDisplayName($name, $oldName),
                    'zone' => (int) $barangay->zone,
                    'pickup_fee' => (float) $barangay->pickup_fee,
                    'delivery_fee' => (float) $barangay->delivery_fee,
                ];
            });

        $sample = $barangays
            ->take(8)
            ->map(function (array $b) {
                return [
                    'name' => (string) ($b['name'] ?? ''),
                    'oldName_present' => ($b['old_name'] ?? null) !== null,
                ];
            })
            ->values()
            ->all();

        $this->debugLog(
            (string) $runId,
            'H2',
            __FILE__.':'.__LINE__,
            'BarangayController@index returning barangays',
            [
                'count' => $barangays->count(),
                'sample' => $sample,
            ]
        );

        return response()->json([
            'data' => $barangays,
            'meta' => [
                'city' => self::TACLOBAN_CITY,
                'base_barangay' => 'Barangay 47',
                'gps_required' => false,
                'logistics_fee_explanation' => $this->logisticsFeeExplanation(),
            ],
        ]);
    }
}
