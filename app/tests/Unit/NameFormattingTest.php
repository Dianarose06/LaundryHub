<?php

namespace Tests\Unit;

use Tests\TestCase;

class NameFormattingTest extends TestCase
{
    // ── Helper: mirrors AuthController::formatRegisteredName() exactly ────────
    private function formatName(array $data): string
    {
        $firstName     = isset($data['first_name'])     ? trim($data['first_name'])                    : '';
        $lastName      = isset($data['last_name'])      ? trim($data['last_name'])                     : '';
        $middleInitial = isset($data['middle_initial']) ? strtoupper(trim($data['middle_initial']))    : '';
        $fallbackName  = trim((string) ($data['name'] ?? ''));

        if ($firstName !== '' && $lastName !== '') {
            return $middleInitial !== ''
                ? "{$lastName}, {$firstName} {$middleInitial}."
                : "{$lastName}, {$firstName}";
        }

        return $fallbackName;
    }

    // ── 1. First + Last name only ─────────────────────────────────────────────

    public function test_formats_first_and_last_name(): void
    {
        $result = $this->formatName([
            'first_name' => 'Juan',
            'last_name'  => 'Dela Cruz',
        ]);

        $this->assertSame('Dela Cruz, Juan', $result);
    }

    // ── 2. First + Last + Middle Initial ─────────────────────────────────────

    public function test_formats_name_with_middle_initial(): void
    {
        $result = $this->formatName([
            'first_name'     => 'Juan',
            'last_name'      => 'Dela Cruz',
            'middle_initial' => 'P',
        ]);

        $this->assertSame('Dela Cruz, Juan P.', $result);
    }

    // ── 3. Middle initial is uppercased automatically ─────────────────────────

    public function test_middle_initial_is_uppercased(): void
    {
        $result = $this->formatName([
            'first_name'     => 'Juan',
            'last_name'      => 'Dela Cruz',
            'middle_initial' => 'p', // lowercase input
        ]);

        $this->assertSame('Dela Cruz, Juan P.', $result);
    }

    // ── 4. Falls back to name field if no first/last name ─────────────────────

    public function test_falls_back_to_name_field(): void
    {
        $result = $this->formatName([
            'name' => 'Juan Dela Cruz',
        ]);

        $this->assertSame('Juan Dela Cruz', $result);
    }

    // ── 5. Trims extra whitespace from names ──────────────────────────────────

    public function test_trims_whitespace_from_names(): void
    {
        $result = $this->formatName([
            'first_name' => '  Juan  ',
            'last_name'  => '  Dela Cruz  ',
        ]);

        $this->assertSame('Dela Cruz, Juan', $result);
    }

    // ── 6. Empty middle initial is ignored ───────────────────────────────────

    public function test_empty_middle_initial_is_ignored(): void
    {
        $result = $this->formatName([
            'first_name'     => 'Juan',
            'last_name'      => 'Dela Cruz',
            'middle_initial' => '',
        ]);

        $this->assertSame('Dela Cruz, Juan', $result);
    }

    // ── 7. Missing middle initial key is ignored ──────────────────────────────

    public function test_missing_middle_initial_key_is_ignored(): void
    {
        $result = $this->formatName([
            'first_name' => 'Maria',
            'last_name'  => 'Santos',
        ]);

        $this->assertSame('Santos, Maria', $result);
    }

    // ── 8. Fallback name is trimmed ───────────────────────────────────────────

    public function test_fallback_name_is_trimmed(): void
    {
        $result = $this->formatName([
            'name' => '  Maria Santos  ',
        ]);

        $this->assertSame('Maria Santos', $result);
    }
}