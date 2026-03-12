<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Service;
use Illuminate\Http\Request;

class ServiceController extends Controller
{
    public function index()
    {
        $services = Service::where('is_active', true)->get();

        return response()->json(['data' => $services]);
    }

    public function adminIndex(Request $request)
    {
        $this->ensureAdmin($request);

        $services = Service::orderBy('id')->get();

        return response()->json(['data' => $services]);
    }

    public function show(Service $service)
    {
        return response()->json(['data' => $service]);
    }

    public function store(Request $request)
    {
        $this->ensureAdmin($request);

        $validated = $request->validate([
            'name'         => 'required|string|max:255',
            'description'  => 'nullable|string|max:1000',
            'price_per_kg' => 'required|numeric|min:0',
            'category'     => 'nullable|string|max:100',
            'image_url'    => 'nullable|url|max:500',
            'is_active'    => 'boolean',
        ]);

        $service = Service::create($validated);

        return response()->json(['data' => $service], 201);
    }

    public function update(Request $request, Service $service)
    {
        $this->ensureAdmin($request);

        $validated = $request->validate([
            'name'         => 'sometimes|required|string|max:255',
            'description'  => 'nullable|string|max:1000',
            'price_per_kg' => 'sometimes|required|numeric|min:0',
            'category'     => 'nullable|string|max:100',
            'image_url'    => 'nullable|url|max:500',
            'is_active'    => 'boolean',
        ]);

        $service->update($validated);

        return response()->json(['data' => $service]);
    }

    public function destroy(Request $request, Service $service)
    {
        $this->ensureAdmin($request);

        $service->delete();

        return response()->json(['message' => 'Service deleted successfully']);
    }

    private function ensureAdmin(Request $request): void
    {
        if ($request->user()?->role !== 'admin') {
            abort(403, 'Forbidden: Admin access required.');
        }
    }
}
