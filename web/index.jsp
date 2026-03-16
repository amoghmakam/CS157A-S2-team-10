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

        nav a {
            color: white;
            text-decoration: none;
            background-color: #0055a5;
            padding: 8px 16px;
            border-radius: 5px;
        }

        nav a:hover { background-color: #0077cc; }

        .hero {
            background-color: #003366;
            color: white;
            text-align: center;
            padding: 50px 20px;
        }

        .hero h2 { font-size: 32px; margin-bottom: 10px; }
        .hero p { font-size: 16px; color: #cce0ff; }

        .filters {
            display: flex;
            justify-content: center;
            gap: 10px;
            padding: 20px;
            flex-wrap: wrap;
        }

        .filters button {
            padding: 8px 18px;
            border: 2px solid #003366;
            background: white;
            border-radius: 20px;
            cursor: pointer;
            font-size: 14px;
        }

        .filters button:hover, .filters button.active {
            background-color: #003366;
            color: white;
        }

        .services {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            padding: 20px 40px;
            justify-content: center;
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
        .card .wait { font-size: 20px; font-weight: bold; color: #003366; }
        .card .wait span { font-size: 13px; font-weight: normal; color: #777;
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
    <a href="login.jsp">Login</a>
</nav>

<!-- Hero -->
<div class="hero">
    <h2>Know Before You Go</h2>
    <p>Real-time wait times and crowd levels for campus services</p>
</div>

<!-- Filters -->
<div class="filters">
    <button class="active">All</button>
    <button>Dining</button>
    <button>Gym</button>
    <button>Parking</button>
    <button>Advising</button>
</div>

<!-- Service Cards -->
<div class="services">

    <div class="card">
        <h3>Student Union Cafeteria</h3>
        <div class="category">Dining</div>
        <div class="crowd-bar high"></div>
        <span class="badge high">High</span>
        <div class="status">Status: <strong>Open</strong></div>
        <div class="wait">25 min <span>estimated wait</span></div>
    </div>

    <div class="card">
        <h3>SRAC Gym</h3>
        <div class="category">Gym</div>
        <div class="crowd-bar medium"></div>
        <span class="badge medium">Medium</span>
        <div class="status">Status: <strong>Open</strong></div>
        <div class="wait">10 min <span>estimated wait</span></div>
    </div>

    <div class="card">
        <h3>Advising Center</h3>
        <div class="category">Advising</div>
        <div class="crowd-bar low"></div>
        <span class="badge low">Low</span>
        <div class="status">Status: <strong>Open</strong></div>
        <div class="wait">5 min <span>estimated wait</span></div>
    </div>

    <div class="card">
        <h3>Parking Garage</h3>
        <div class="category">Parking</div>
        <div class="crowd-bar medium"></div>
        <span class="badge medium">Medium</span>
        <div class="status">Status: <strong>Open</strong></div>
        <div class="wait">12 min <span>estimated wait</span></div>
    </div>

</div>

<footer>
    CampusQueue &mdash; SJSU CS157A Section 2, Team 10
</footer>

</body>
</html>
