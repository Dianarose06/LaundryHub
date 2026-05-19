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
            background: #F5F9FA;
            display: flex;
            min-height: 100vh;
            align-items: center;
            justify-content: center;
        }

        .card {
            width: 100%;
            max-width: 420px;
            background: #F5F9FA;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(15, 23, 42, 0.12);
            padding: 24px;
            border: 1px solid #A4D8E1;
        }

        h1 {
            margin: 0 0 10px;
            font-size: 24px;
            color: #2C3E50;
        }

        p {
            margin: 0 0 20px;
            color: #54B2B0;
            font-size: 14px;
        }

        .error {
            margin-bottom: 14px;
            padding: 10px 12px;
            border-radius: 8px;
            background: #A4D8E1;
            color: #2C3E50;
            font-size: 14px;
        }

        label {
            display: block;
            margin-bottom: 6px;
            color: #2C3E50;
            font-size: 14px;
            font-weight: 600;
        }

        input {
            width: 100%;
            box-sizing: border-box;
            border: 1px solid #A4D8E1;
            border-radius: 8px;
            padding: 10px 12px;
            margin-bottom: 14px;
            font-size: 14px;
            color: #2C3E50;
            background: #FFFFFF;
        }

        button {
            width: 100%;
            border: 0;
            border-radius: 8px;
            background: #54B2B0;
            color: white;
            font-size: 14px;
            font-weight: 700;
            padding: 11px;
            cursor: pointer;
        }

        button:hover {
            background: #2C3E50;
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
