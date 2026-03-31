<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Notifications\VerifyEmailCode;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    private function formatRegisteredName(array $validated): string
    {
        $firstName = isset($validated['first_name']) ? trim($validated['first_name']) : '';
        $lastName = isset($validated['last_name']) ? trim($validated['last_name']) : '';
        $middleInitial = isset($validated['middle_initial']) ? strtoupper(trim($validated['middle_initial'])) : '';
        $fallbackName = trim((string) ($validated['name'] ?? ''));

        if ($firstName !== '' && $lastName !== '') {
            return $middleInitial !== ''
                ? "{$lastName}, {$firstName} {$middleInitial}."
                : "{$lastName}, {$firstName}";
        }

        return $fallbackName;
    }

    public function register(Request $request)
    {
        $validated = $request->validate([
            'name'                  => ['required_without_all:first_name,last_name', 'string', 'max:255', 'regex:/\S/'],
            'first_name'            => ['required_without:name', 'string', 'max:255', 'regex:/\S/'],
            'last_name'             => ['required_without:name', 'string', 'max:255', 'regex:/\S/'],
            'middle_initial'        => ['nullable', 'string', 'size:1', 'regex:/^[A-Za-z]$/'],
            'email'                 => 'required|string|email|max:255|unique:users',
            'password'              => 'required|string|min:8|confirmed',
            'phone'                 => 'nullable|string|max:20',
        ]);

        $formattedName = $this->formatRegisteredName($validated);

        // Check if email was verified during registration process
        $isEmailVerified = Cache::get("email_verified_{$validated['email']}");

        if (!$isEmailVerified) {
            return response()->json([
                'message' => 'Please verify your email first.',
            ], 400);
        }

        // Get the verified code from cache
        $verifiedCode = Cache::get("verified_code_{$validated['email']}");

        // Create user with verified email
        $user = User::create([
            'name'              => $formattedName,
            'email'             => $validated['email'],
            'password'          => $validated['password'],
            'phone'             => $validated['phone'] ?? null,
            'email_verified_at' => now(), // Mark as verified immediately
            'verification_code' => $verifiedCode, // Save the verification code that was used
        ]);

        // Set remember token
        $user->setRememberToken(Str::random(60));
        $user->save();

        // Verify the user was created with email_verified_at
        $user->refresh();

        // Clear verification cache
        Cache::forget("verification_code_{$validated['email']}");
        Cache::forget("email_verified_{$validated['email']}");
        Cache::forget("verification_sent_{$validated['email']}");
        Cache::forget("verified_code_{$validated['email']}");

        return response()->json([
            'message' => 'Registration successful. You can now login.',
            'user'    => $user,
        ], 201);
    }

    public function login(Request $request)
    {
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        // User not found
        if (! $user) {
            return response()->json([
                'message' => 'Account not found. Please register first.',
                'user_not_found' => true,
            ], 404);
        }

        // Wrong password
        if (! Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Incorrect password. Please try again.',
            ], 401);
        }

        // Check if email is verified
        if (! $user->hasVerifiedEmail()) {
            return response()->json([
                'message' => 'Please verify your email first. Complete verification during registration.',
                'email_not_verified' => true,
            ], 403);
        }

        $token = $user->createToken('mobile')->plainTextToken;

        return response()->json([
            'user'  => $user,
            'token' => $token,
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logged out successfully.']);
    }

    public function me(Request $request)
    {
        return response()->json($request->user());
    }

    public function resendVerification(Request $request)
    {
        $request->validate(['email' => 'required|email']);

        $user = User::where('email', $request->email)->first();

        if (! $user) {
            return response()->json(['message' => 'User not found.'], 404);
        }

        if ($user->hasVerifiedEmail()) {
            return response()->json(['message' => 'Email already verified.'], 400);
        }

        // Generate a new 6-digit verification code
        $verificationCode = str_pad(rand(0, 999999), 6, '0', STR_PAD_LEFT);
        $user->verification_code = $verificationCode;
        $user->save();

        // Send email with new verification code
        $user->notify(new VerifyEmailCode($verificationCode));

        return response()->json(['message' => 'Verification code resent successfully.']);
    }

    public function verifyCode(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'code'  => 'required|string|size:6',
        ]);

        $user = User::where('email', $request->email)->first();

        if (! $user) {
            return response()->json(['message' => 'User not found.'], 404);
        }

        if ($user->hasVerifiedEmail()) {
            return response()->json(['message' => 'Email already verified.'], 400);
        }

        if ($user->verification_code !== $request->code) {
            return response()->json(['message' => 'Invalid verification code.'], 400);
        }

        // Mark email as verified
        $user->email_verified_at = now();
        $user->verification_code = null; // Clear the code after verification
        $user->save();

        // Generate a token for the user
        $token = $user->createToken('mobile')->plainTextToken;

        return response()->json([
            'message' => 'Email verified successfully!',
            'user'    => $user,
            'token'   => $token,
        ]);
    }

    // Send verification code before registration
    public function sendVerificationCode(Request $request)
    {
        $request->validate([
            'email' => 'required|email|max:255',
        ]);

        $email = $request->email;

        // Check if email already exists
        if (User::where('email', $email)->exists()) {
            return response()->json([
                'message' => 'This email is already registered. Please login instead.',
            ], 400);
        }

        // Generate a 6-digit verification code
        $code = str_pad(rand(0, 999999), 6, '0', STR_PAD_LEFT);

        // Store the code in cache for 10 minutes (as backup and for quick access)
        Cache::put("verification_code_{$email}", $code, now()->addMinutes(10));
        
        // Also store in cache that this code was sent (with timestamp)
        Cache::put("verification_sent_{$email}", [
            'code' => $code,
            'sent_at' => now()->toDateTimeString(),
        ], now()->addMinutes(10));

        // Send email with verification code
        Mail::raw(
            "Your LaundryHub verification code is: {$code}\n\nThis code will expire in 10 minutes.\n\nIf you did not request this code, please ignore this email.",
            function ($message) use ($email) {
                $message->to($email)
                    ->subject('LaundryHub - Email Verification Code');
            }
        );

        return response()->json([
            'message' => 'Verification code sent to your email.',
        ]);
    }

    // Check if verification code is valid
    public function checkVerificationCode(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'code'  => 'required|string|size:6',
        ]);

        $email = $request->email;
        $code = $request->code;

        // Get the stored code from cache
        $storedCode = Cache::get("verification_code_{$email}");

        if (!$storedCode) {
            return response()->json([
                'message' => 'Verification code expired or not found. Please request a new code.',
            ], 400);
        }

        if ($storedCode !== $code) {
            return response()->json([
                'message' => 'Invalid verification code.',
            ], 400);
        }

        // Mark email as verified in cache and store the verified code
        Cache::put("email_verified_{$email}", true, now()->addMinutes(30));
        Cache::put("verified_code_{$email}", $code, now()->addMinutes(30));

        return response()->json([
            'message' => 'Email verified successfully!',
            'verified' => true,
        ]);
    }

    // Send password reset code
    public function sendPasswordResetCode(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
        ]);

        $email = $request->email;

        // Check if user exists
        $user = User::where('email', $email)->first();

        if (!$user) {
            return response()->json([
                'message' => 'No account found with this email address.',
            ], 404);
        }

        // Generate a 6-digit reset code
        $code = str_pad(rand(0, 999999), 6, '0', STR_PAD_LEFT);

        // Store the code in cache for 10 minutes
        Cache::put("password_reset_code_{$email}", $code, now()->addMinutes(10));

        // Send email with reset code
        Mail::raw(
            "Your LaundryHub password reset code is: {$code}\n\nThis code will expire in 10 minutes.\n\nIf you did not request this code, please ignore this email.",
            function ($message) use ($email) {
                $message->to($email)
                    ->subject('LaundryHub - Password Reset Code');
            }
        );

        return response()->json([
            'message' => 'Password reset code sent to your email.',
        ]);
    }

    // Reset password with code
    public function resetPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'code' => 'required|string|size:6',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $email = $request->email;
        $code = $request->code;

        // Get the stored code from cache
        $storedCode = Cache::get("password_reset_code_{$email}");

        if (!$storedCode) {
            return response()->json([
                'message' => 'Reset code expired or not found. Please request a new code.',
            ], 400);
        }

        if ($storedCode !== $code) {
            return response()->json([
                'message' => 'Invalid reset code.',
            ], 400);
        }

        // Find user and update password
        $user = User::where('email', $email)->first();

        if (!$user) {
            return response()->json([
                'message' => 'User not found.',
            ], 404);
        }

        $user->password = $request->password;
        $user->save();

        // Clear the reset code from cache
        Cache::forget("password_reset_code_{$email}");

        return response()->json([
            'message' => 'Password reset successfully. You can now login with your new password.',
        ]);
    }
}

