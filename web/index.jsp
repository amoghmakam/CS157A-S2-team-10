<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CampusQueue</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            color: #333;
        }

        nav {
            background-color: #003366;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        nav h1 { color: white; font-size: 24px; }

        .hero {
            background-color: #003366;
            color: white;
            text-align: center;
            padding: 50px 20px;
        }

        .hero h2 { font-size: 32px; margin-bottom: 10px; }
        .hero p { font-size: 16px; color: #cce0ff; }

        .services {
            display: flex;
            flex-wrap: nowrap;
            gap: 20px;
            justify-content: center;
            padding: 40px 40px 20px;
            overflow-x: auto;
        }

        .card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            width: 280px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .card h3 { margin-bottom: 5px; font-size: 18px; }

        .card .category {
            font-size: 12px;
            color: #777;
            margin-bottom: 12px;
        }

        .crowd-bar {
            height: 10px;
            border-radius: 5px;
            margin-bottom: 10px;
        }

        .low  { background-color: #28a745; }
        .medium { background-color: #ffc107; }
        .high { background-color: #dc3545; }

        .card .status { font-size: 13px; margin-bottom: 5px; }

        .card .wait-locked {
            font-size: 14px;
            color: #aaa;
            font-style: italic;
            margin-top: 5px;
        }

        .badge {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 12px;
            font-size: 12px;
            color: white;
            margin-bottom: 10px;
        }

        .badge.low { background-color: #28a745; }
        .badge.medium { background-color: #ffc107; color: #333; }
        .badge.high { background-color: #dc3545; }

        /* Login box */
        .login-box {
            background: white;
            border-radius: 10px;
            padding: 30px;
            width: 320px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin: 0 auto 40px;
        }

        .login-box h3 {
            color: #003366;
            margin-bottom: 16px;
            font-size: 20px;
            text-align: center;
        }

        .login-box p {
            font-size: 13px;
            color: #555;
            margin-bottom: 16px;
            text-align: center;
        }

        .login-box form {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .login-box input {
            padding: 9px 12px;
            border: 1px solid #ccc;
            border-radius: 5px;
            font-size: 14px;
        }

        .login-box input:focus {
            outline: none;
            border-color: #003366;
        }

        .btn-login {
            padding: 9px;
            background-color: #003366;
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 14px;
            cursor: pointer;
        }

        .btn-login:hover { background-color: #0055a5; }

        .btn-signup {
            display: block;
            text-align: center;
            padding: 9px;
            background-color: white;
            color: #003366;
            border: 2px solid #003366;
            border-radius: 5px;
            font-size: 14px;
            text-decoration: none;
        }

        .btn-signup:hover { background-color: #f0f4ff; }

        footer {
            text-align: center;
            padding: 20px;
            color: #777;
            font-size: 13px;
            margin-top: 40px;
        }
    </style>
</head>
<body>

<!-- Navbar -->
<nav>
    <h1>CampusQueue</h1>
</nav>

<!-- Hero -->
<div class="hero">
    <h2>Know Before You Go</h2>
    <p>Real-time wait times and crowd levels for campus services</p>
</div>

<!-- Service Cards -->
<div class="services">

        <div class="card">
            <h3>Student Union Cafeteria</h3>
            <div class="category">Dining</div>
            <div class="crowd-bar high"></div>
            <span class="badge high">High</span>
            <div class="status">Status: <strong>Open</strong></div>
            <div class="wait-locked">Login to view wait time</div>
        </div>

        <div class="card">
            <h3>SRAC Gym</h3>
            <div class="category">Gym</div>
            <div class="crowd-bar medium"></div>
            <span class="badge medium">Medium</span>
            <div class="status">Status: <strong>Open</strong></div>
            <div class="wait-locked">Login to view wait time</div>
        </div>

        <div class="card">
            <h3>Advising Center</h3>
            <div class="category">Advising</div>
            <div class="crowd-bar low"></div>
            <span class="badge low">Low</span>
            <div class="status">Status: <strong>Open</strong></div>
            <div class="wait-locked">Login to view wait time</div>
        </div>

        <div class="card">
            <h3>Parking Garage</h3>
            <div class="category">Parking</div>
            <div class="crowd-bar medium"></div>
            <span class="badge medium">Medium</span>
            <div class="status">Status: <strong>Open</strong></div>
            <div class="wait-locked">Login to view wait time</div>
        </div>

    </div>

<!-- Login/Signup Box -->
<div class="login-box">

    <!-- Login Form -->
    <div id="loginForm">
        <h3>Login</h3>
        <p>Log in to see real-time wait times.</p>
        <form action="LoginServlet" method="post">
            <input type="email" name="email" placeholder="Email" required>
            <input type="password" name="password" placeholder="Password" required>
            <button type="submit" class="btn-login">Login</button>
        </form>
        <p style="margin-top: 14px;">Don't have an account? <a href="#" onclick="toggleForm()" style="color: #003366;">Sign Up</a></p>
    </div>

    <!-- Sign Up Form -->
    <div id="signupForm" style="display: none;">
        <h3>Sign Up</h3>
        <p>Create an account to get started.</p>
        <form action="RegisterServlet" method="post">
            <input type="text" name="name" placeholder="Full Name" required>
            <input type="email" name="email" placeholder="Email" required>
            <input type="password" name="password" placeholder="Password" required>
            <input type="password" name="confirmPassword" placeholder="Confirm Password" required>
            <button type="submit" class="btn-login">Sign Up</button>
        </form>
        <p style="margin-top: 14px;">Already have an account? <a href="#" onclick="toggleForm()" style="color: #003366;">Login</a></p>
    </div>

</div>

<script>
    function toggleForm() {
        var login = document.getElementById('loginForm');
        var signup = document.getElementById('signupForm');
        if (login.style.display === 'none') {
            login.style.display = 'block';
            signup.style.display = 'none';
        } else {
            login.style.display = 'none';
            signup.style.display = 'block';
        }
    }
</script>

<footer>
    CampusQueue &mdash; SJSU CS157A Section 2, Team 10
</footer>

</body>
</html>
