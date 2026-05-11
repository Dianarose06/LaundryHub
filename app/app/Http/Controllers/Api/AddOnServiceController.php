<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AddOnService;
use Illuminate\Http\Request;

class AddOnServiceController extends Controller
{
    public function index(Request $request)
    {
        $validated = $request->validate([
            'service_id' => 'nullable|integer|exists:services,id',
            'page' => 'nullable|integer|min:1',
            'per_page' => 'nullable|integer|min:1|max:100',
        ]);

        $serviceId = $validated['service_id'] ?? null;
        $query = AddOnService::query()->where('is_active', true);

        if ($serviceId !== null) {
            $serviceSpecificQuery = (clone $query)->where('service_id', $serviceId);

            if ($serviceSpecificQuery->exists()) {
                $query = $serviceSpecificQuery;
            } else {
                $query->whereNull('service_id');
            }
        } else {
            $query->whereNull('service_id');
        }

        $query->orderBy('name');

        $shouldPaginate =
            array_key_exists('page', $validated)
            || array_key_exists('per_page', $validated);

        if ($shouldPaginate) {
            $perPage = (int) ($validated['per_page'] ?? 10);
            $page = (int) ($validated['page'] ?? 1);

            $paginator = $query->paginate($perPage, ['*'], 'page', $page);

            $addOns = collect($paginator->items())
                ->map(fn (AddOnService $addOn) => [
                    'id' => $addOn->id,
                    'name' => $addOn->name,
                    'description' => $addOn->description,
                    'fee' => (float) $addOn->fee,
                ])
                ->values();

            return response()->json([
                'data' => $addOns,
                'meta' => [
                    'current_page' => $paginator->currentPage(),
                    'per_page' => $paginator->perPage(),
                    'total' => $paginator->total(),
                    'last_page' => $paginator->lastPage(),
                    'from' => $paginator->firstItem(),
                    'to' => $paginator->lastItem(),
                    'has_more_pages' => $paginator->hasMorePages(),
                ],
            ]);
        }

        $addOns = $query
            ->get()
            ->map(fn (AddOnService $addOn) => [
                'id' => $addOn->id,
                'name' => $addOn->name,
                'description' => $addOn->description,
                'fee' => (float) $addOn->fee,
            ]);

        return response()->json(['data' => $addOns]);
    }

    public function adminIndex(Request $request)
    {
        $this->ensureAdmin($request);

        $validated = $request->validate([
            'service_id' => 'nullable|integer|exists:services,id',
        ]);

        $query = AddOnService::query()
            ->with('service:id,name')
            ->orderBy('id');

        if (array_key_exists('service_id', $validated)) {
            $serviceId = $validated['service_id'];

            if ($serviceId === null) {
                $query->whereNull('service_id');
            } else {
                $query->where('service_id', $serviceId);
            }
        }

        $addOns = $query->get()->map(fn (AddOnService $addOn) => [
            'id' => $addOn->id,
            'service_id' => $addOn->service_id,
            'service_name' => $addOn->service?->name,
            'name' => $addOn->name,
            'description' => $addOn->description,
            'fee' => (float) $addOn->fee,
            'is_active' => (bool) $addOn->is_active,
            'created_at' => $addOn->created_at,
            'updated_at' => $addOn->updated_at,
        ]);

        return response()->json(['data' => $addOns]);
    }

    public function store(Request $request)
    {
        $this->ensureAdmin($request);

        $validated = $request->validate([
            'service_id' => 'nullable|integer|exists:services,id',
            'name' => 'required|string|max:255',
            'description' => 'nullable|string|max:1000',
            'fee' => 'required|numeric|min:0',
            'is_active' => 'boolean',
        ]);

        $addOn = AddOnService::create($validated)->load('service:id,name');

        return response()->json([
            'data' => [
                'id' => $addOn->id,
                'service_id' => $addOn->service_id,
                'service_name' => $addOn->service?->name,
                'name' => $addOn->name,
                'description' => $addOn->description,
                'fee' => (float) $addOn->fee,
                'is_active' => (bool) $addOn->is_active,
                'created_at' => $addOn->created_at,
                'updated_at' => $addOn->updated_at,
            ],
        ], 201);
    }

    public function update(Request $request, AddOnService $addOnService)
    {
        $this->ensureAdmin($request);

        $validated = $request->validate([
            'service_id' => 'sometimes|nullable|integer|exists:services,id',
            'name' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string|max:1000',
            'fee' => 'sometimes|required|numeric|min:0',
            'is_active' => 'boolean',
        ]);

        $addOnService->update($validated);
        $addOnService->load('service:id,name');

        return response()->json([
            'data' => [
                'id' => $addOnService->id,
                'service_id' => $addOnService->service_id,
                'service_name' => $addOnService->service?->name,
                'name' => $addOnService->name,
                'description' => $addOnService->description,
                'fee' => (float) $addOnService->fee,
                'is_active' => (bool) $addOnService->is_active,
                'created_at' => $addOnService->created_at,
                'updated_at' => $addOnService->updated_at,
            ],
        ]);
    }

    public function destroy(Request $request, AddOnService $addOnService)
    {
        $this->ensureAdmin($request);

        $addOnService->delete();

        return response()->json(['message' => 'Add-on service deleted successfully']);
    }

    private function ensureAdmin(Request $request): void
    {
        if ($request->user()?->role !== 'admin') {
            abort(403, 'Forbidden: Admin access required.');
        }
    }
}
