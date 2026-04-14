<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class CustomerProfileController extends Controller
{
    private function formatDisplayName(string $firstName, string $lastName, ?string $middleInitial = null): string
    {
        $normalizedFirstName = trim($firstName);
        $normalizedLastName = trim($lastName);
        $normalizedMiddleInitial = $middleInitial !== null ? strtoupper(trim($middleInitial)) : null;

        return !empty($normalizedMiddleInitial)
            ? "{$normalizedLastName}, {$normalizedFirstName} {$normalizedMiddleInitial}."
            : "{$normalizedLastName}, {$normalizedFirstName}";
    }

    /**
     * Get current user's profile
     */
    public function show(Request $request): JsonResponse
    {
        $user = $request->user();
        
        return response()->json([
            'success' => true,
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
                'profile_picture_url' => $user->profile_picture_url,
                'bio' => $user->bio,
                'address' => $user->address,
                'city' => $user->city,
                'zip_code' => $user->zip_code,
                'country' => $user->country,
                'date_of_birth' => $user->date_of_birth,
                'gender' => $user->gender,
                'preferred_language' => $user->preferred_language,
                'notifications_enabled' => $user->notifications_enabled,
                'loyalty_points' => $user->loyalty_points,
                'email_verified_at' => $user->email_verified_at,
                'profile_completed_at' => $user->profile_completed_at,
                'created_at' => $user->created_at,
            ],
        ]);
    }

    /**
     * Update customer profile
     */
    public function update(Request $request): JsonResponse
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'name' => ['sometimes', 'string', 'max:255', 'regex:/\S/'],
            'first_name' => ['sometimes', 'required_with:last_name,middle_initial', 'string', 'max:255', 'regex:/\S/'],
            'last_name' => ['sometimes', 'required_with:first_name,middle_initial', 'string', 'max:255', 'regex:/\S/'],
            'middle_initial' => ['sometimes', 'nullable', 'string', 'size:1', 'regex:/^[A-Za-z]$/'],
            'phone' => 'sometimes|string|max:20|regex:/^[0-9\s\-\+\(\)]+$/',
            'profile_picture_url' => 'sometimes|nullable|string|url',
            'bio' => 'sometimes|nullable|string|max:500',
            'address' => 'sometimes|nullable|string|max:255',
            'city' => 'sometimes|nullable|string|max:100',
            'zip_code' => 'sometimes|nullable|string|max:20',
            'country' => 'sometimes|nullable|string|max:100',
            'date_of_birth' => 'sometimes|nullable|date|before:today',
            'gender' => 'sometimes|nullable|in:male,female,other',
            'preferred_language' => 'sometimes|string|in:en,es,fr,de',
            'notifications_enabled' => 'sometimes|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $updateData = $validator->validated();

        if (
            array_key_exists('first_name', $updateData)
            || array_key_exists('last_name', $updateData)
            || array_key_exists('middle_initial', $updateData)
        ) {
            $updateData['name'] = $this->formatDisplayName(
                $updateData['first_name'] ?? '',
                $updateData['last_name'] ?? '',
                $updateData['middle_initial'] ?? null,
            );
        }

        unset($updateData['first_name'], $updateData['last_name'], $updateData['middle_initial']);

        // Check if profile completion requirements are met
        if ($this->isProfileComplete($user, $updateData)) {
            $updateData['profile_completed_at'] = now();
        }

        $user->update($updateData);

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
                'profile_picture_url' => $user->profile_picture_url,
                'bio' => $user->bio,
                'address' => $user->address,
                'city' => $user->city,
                'zip_code' => $user->zip_code,
                'country' => $user->country,
                'date_of_birth' => $user->date_of_birth,
                'gender' => $user->gender,
                'preferred_language' => $user->preferred_language,
                'notifications_enabled' => $user->notifications_enabled,
                'loyalty_points' => $user->loyalty_points,
                'profile_completed_at' => $user->profile_completed_at,
            ],
        ]);
    }

    /**
     * Change current user's password
     */
    public function changePassword(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'current_password' => 'required|string',
            'new_password' => 'required|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();

        if (!Hash::check($request->input('current_password'), $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Current password is incorrect',
            ], 422);
        }

        if (Hash::check($request->input('new_password'), $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'New password must be different from current password',
            ], 422);
        }

        $user->update([
            'password' => $request->input('new_password'),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Password changed successfully',
        ]);
    }

    /**
     * Get profile completion percentage
     */
    public function completionStatus(Request $request): JsonResponse
    {
        $user = $request->user();
        
        $profileFields = [
            'name' => !empty($user->name),
            'email' => !empty($user->email),
            'phone' => !empty($user->phone),
            'address' => !empty($user->address),
            'city' => !empty($user->city),
            'country' => !empty($user->country),
            'profile_picture_url' => !empty($user->profile_picture_url),
            'date_of_birth' => !empty($user->date_of_birth),
            'gender' => !empty($user->gender),
        ];

        $completedFields = array_sum($profileFields);
        $totalFields = count($profileFields);
        $percentage = round(($completedFields / $totalFields) * 100);

        return response()->json([
            'success' => true,
            'data' => [
                'completed_percentage' => $percentage,
                'total_fields' => $totalFields,
                'completed_fields' => $completedFields,
                'fields' => $profileFields,
                'is_profile_complete' => $user->profile_completed_at !== null,
            ],
        ]);
    }

    /**
     * Upload profile picture
     */
    public function uploadProfilePicture(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'profile_picture' => 'required|image|mimes:jpeg,png,jpg,gif|max:5120', // 5MB max
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid image file',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();

        if ($request->hasFile('profile_picture')) {
            $file = $request->file('profile_picture');
            $path = $file->store('profile-pictures', 'public');
            // Store relative path so Flutter can prepend the correct host/port
            $user->profile_picture_url = 'storage/' . $path;
            $user->save();

            return response()->json([
                'success' => true,
                'message' => 'Profile picture uploaded successfully',
                'data' => [
                    'profile_picture_url' => $user->profile_picture_url,
                ],
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'No file provided',
        ], 400);
    }

    /**
     * Delete profile picture
     */
    public function deleteProfilePicture(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user->profile_picture_url) {
            return response()->json([
                'success' => false,
                'message' => 'No profile picture to delete',
            ], 404);
        }

        // Delete file from storage if it exists
        try {
            $filePath = str_replace('storage/', '', $user->profile_picture_url);
            if (Storage::disk('public')->exists($filePath)) {
                Storage::disk('public')->delete($filePath);
            }
        } catch (\Exception $e) {
            \Log::warning('Failed to delete profile picture file: ' . $e->getMessage());
        }

        // Clear the URL from database
        $user->profile_picture_url = null;
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Profile picture deleted successfully',
        ]);
    }

    /**
     * Check if profile is complete
     */
    private function isProfileComplete(User $user, array $updateData): bool
    {
        $profileFields = [
            'name' => $updateData['name'] ?? $user->name,
            'email' => $updateData['email'] ?? $user->email,
            'phone' => $updateData['phone'] ?? $user->phone,
            'address' => $updateData['address'] ?? $user->address,
            'country' => $updateData['country'] ?? $user->country,
        ];

        return !in_array(null, $profileFields) && !in_array('', $profileFields);
    }

    /**
     * Get public profile (for other users to view)
     */
    public function publicProfile($userId): JsonResponse
    {
        $user = User::find($userId);

        if (!$user || $user->role !== 'customer') {
            return response()->json([
                'success' => false,
                'message' => 'User not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'profile_picture_url' => $user->profile_picture_url,
                'bio' => $user->bio,
                'loyalty_points' => $user->loyalty_points,
                'profile_completed_at' => $user->profile_completed_at,
            ],
        ]);
    }
}
