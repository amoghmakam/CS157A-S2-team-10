<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Service" %>
<%
    List<Service> services = (List<Service>) request.getAttribute("services");
    String flashMessage = (String) session.getAttribute("flashMessage");
    String flashError = (String) session.getAttribute("flashError");
    session.removeAttribute("flashMessage");
    session.removeAttribute("flashError");

    Object userId = session.getAttribute("userId");
    String userName = (String) session.getAttribute("name");
    String role = (String) session.getAttribute("role");
%>
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

        nav h1 {
            color: white;
            font-size: 24px;
        }

        nav .nav-right {
            display: flex;
            align-items: center;
            gap: 14px;
            color: white;
        }

        nav .nav-right a {
            color: white;
            text-decoration: none;
            font-size: 14px;
        }

        nav .nav-right a:hover {
            text-decoration: underline;
        }

        .hero {
            background-color: #003366;
            color: white;
            text-align: center;
            padding: 50px 20px;
        }

        .hero h2 { font-size: 32px; margin-bottom: 10px; }
        .hero p { font-size: 16px; color: #cce0ff; }

        .flash {
            width: min(900px, 92%);
            margin: 20px auto 0;
            padding: 12px 16px;
            border-radius: 8px;
            font-size: 14px;
        }

        .flash.success {
            background: #e8f7ee;
            color: #1d6b39;
            border: 1px solid #b9e5c8;
        }

        .flash.error {
            background: #fdecec;
            color: #8a1f1f;
            border: 1px solid #f1c4c4;
        }

        .filters {
            display: flex;
            justify-content: center;
            padding: 24px 20px 0;
        }

        .filters form {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            justify-content: center;
        }

        .filters select,
        .filters button {
            padding: 10px 12px;
            border-radius: 6px;
            border: 1px solid #ccc;
            font-size: 14px;
        }

        .filters button {
            background-color: #003366;
            color: white;
            border: none;
            cursor: pointer;
        }

        .filters button:hover {
            background-color: #0055a5;
        }

        .services {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            justify-content: center;
            padding: 30px 40px 20px;
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

        .card .status {
            font-size: 13px;
            margin-bottom: 5px;
        }

        .card .location {
            font-size: 13px;
            margin-bottom: 8px;
            color: #555;
        }

        .card .wait-locked,
        .card .wait-time {
            font-size: 14px;
            margin-top: 5px;
        }

        .card .wait-locked {
            color: #aaa;
            font-style: italic;
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

        .dashboard-link {
            display: inline-block;
            margin-top: 10px;
            color: #003366;
            text-decoration: none;
            font-size: 14px;
            font-weight: bold;
        }

        .dashboard-link:hover {
            text-decoration: underline;
        }

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

<nav>
    <h1>CampusQueue</h1>
    <div class="nav-right">
        <% if (userId != null) { %>
            <span>Hi, <%= userName %></span>

            <% if ("STUDENT".equals(role)) { %>
                <a href="<%= request.getContextPath() %>/StudentDashboardServlet">Student Dashboard</a>
            <% } else if ("STAFF".equals(role)) { %>
                <a href="<%= request.getContextPath() %>/StaffDashboardServlet">Staff Dashboard</a>
            <% } else if ("ADMIN".equals(role)) { %>
                <a href="<%= request.getContextPath() %>/AdminDashboardServlet">Admin Dashboard</a>
            <% } %>

            <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
        <% } %>
    </div>
</nav>

<div class="hero">
    <h2>Know Before You Go</h2>
    <p>Real-time wait times and crowd levels for campus services</p>
</div>

<% if (flashMessage != null) { %>
    <div class="flash success"><%= flashMessage %></div>
<% } %>

<% if (flashError != null) { %>
    <div class="flash error"><%= flashError %></div>
<% } %>

<div class="filters">
    <form action="<%= request.getContextPath() %>/HomeServlet" method="get">
        <select name="category">
            <option value="">All Categories</option>
            <option value="Dining">Dining</option>
            <option value="Fitness">Fitness</option>
            <option value="Advising">Advising</option>
            <option value="Parking">Parking</option>
        </select>
        <button type="submit">Filter</button>
    </form>
</div>

<div class="services">
    <% if (services != null && !services.isEmpty()) {
        for (Service s : services) {
            String crowdClass = "low";
            if ("Medium".equalsIgnoreCase(s.getCrowdLevel())) {
                crowdClass = "medium";
            } else if ("High".equalsIgnoreCase(s.getCrowdLevel())) {
                crowdClass = "high";
            }
    %>
        <div class="card">
            <h3><%= s.getServiceName() %></h3>
            <div class="category"><%= s.getCategoryName() %></div>
            <div class="crowd-bar <%= crowdClass %>"></div>
            <span class="badge <%= crowdClass %>"><%= s.getCrowdLevel() %></span>
            <div class="status">Status: <strong><%= s.getCurrentStatus() %></strong></div>
            <div class="location">Location: <%= s.getLocation() %></div>

            <% if (userId == null) { %>
                <div class="wait-locked">Login to view wait time</div>
            <% } else { %>
                <div class="wait-time">Predicted wait: <strong><%= String.format("%.1f", s.getPredictedWait()) %> min</strong></div>
            <% } %>

            <% if (userId != null && "STUDENT".equals(role)) { %>
                <a class="dashboard-link"
                   href="<%= request.getContextPath() %>/ServiceDetailServlet?serviceName=<%= java.net.URLEncoder.encode(s.getServiceName(), "UTF-8") %>">
                    View details
                </a>
            <% } %>
        </div>
    <%  }
       } else { %>
        <div class="card">
            <h3>No services found</h3>
            <div class="category">Try a different category filter.</div>
        </div>
    <% } %>
</div>

<% if (userId == null) { %>
<div class="login-box">

    <div id="loginForm">
        <h3>Login</h3>
        <p>Log in to see real-time wait times.</p>
        <form action="<%= request.getContextPath() %>/LoginServlet" method="post">
            <input type="email" name="email" placeholder="Email" required>
            <input type="password" name="password" placeholder="Password" required>
            <button type="submit" class="btn-login">Login</button>
        </form>
        <p style="margin-top: 14px;">
            Don't have an account?
            <a href="#" onclick="toggleForm(); return false;" style="color: #003366;">Sign Up</a>
        </p>
    </div>

    <div id="signupForm" style="display: none;">
        <h3>Sign Up</h3>
        <p>Create an account to get started.</p>
        <form action="<%= request.getContextPath() %>/RegisterServlet" method="post">
            <input type="text" name="name" placeholder="Full Name" required>
            <input type="email" name="email" placeholder="Email" required>
            <input type="password" name="password" placeholder="Password" required>
            <input type="password" name="confirmPassword" placeholder="Confirm Password" required>
            <button type="submit" class="btn-login">Sign Up</button>
        </form>
        <p style="margin-top: 14px;">
            Already have an account?
            <a href="#" onclick="toggleForm(); return false;" style="color: #003366;">Login</a>
        </p>
    </div>

</div>
<% } %>

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