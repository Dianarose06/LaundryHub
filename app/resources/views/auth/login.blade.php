<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LaundryHub Admin Login</title>
    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f3f4f6;
            display: flex;
            min-height: 100vh;
            align-items: center;
            justify-content: center;
        }

        .card {
            width: 100%;
            max-width: 420px;
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(15, 23, 42, 0.12);
            padding: 24px;
        }

        h1 {
            margin: 0 0 10px;
            font-size: 24px;
            color: #0f172a;
        }

        p {
            margin: 0 0 20px;
            color: #475569;
            font-size: 14px;
        }

        .error {
            margin-bottom: 14px;
            padding: 10px 12px;
            border-radius: 8px;
            background: #fee2e2;
            color: #991b1b;
            font-size: 14px;
        }

        label {
            display: block;
            margin-bottom: 6px;
            color: #0f172a;
            font-size: 14px;
            font-weight: 600;
        }

        input {
            width: 100%;
            box-sizing: border-box;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            padding: 10px 12px;
            margin-bottom: 14px;
            font-size: 14px;
        }

        button {
            width: 100%;
            border: 0;
            border-radius: 8px;
            background: #2563eb;
            color: white;
            font-size: 14px;
            font-weight: 700;
            padding: 11px;
            cursor: pointer;
        }

        button:hover {
            background: #1d4ed8;
        }
    </style>
</head>
<body>
    <div class="card">
        <h1>Admin Sign In</h1>
        <p>Use your admin credentials to access the LaundryHub web admin panel.</p>

        @if ($errors->any())
            <div class="error">{{ $errors->first() }}</div>
        @endif

        <form method="POST" action="{{ route('login.attempt') }}">
            @csrf
            <label for="email">Email</label>
            <input id="email" name="email" type="email" value="{{ old('email') }}" required autofocus>

            <label for="password">Password</label>
            <input id="password" name="password" type="password" required>

            <button type="submit">Sign In</button>
        </form>
    </div>
</body>
</html>
