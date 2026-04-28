<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Service" %>
<%@ page import="model.CheckInRecord" %>
<%
    List<Service> services = (List<Service>) request.getAttribute("services");
    List<CheckInRecord> history = (List<CheckInRecord>) request.getAttribute("history");
    Boolean hasActiveCheckIn = (Boolean) request.getAttribute("hasActiveCheckIn");

    String flashMessage = (String) session.getAttribute("flashMessage");
    String flashError = (String) session.getAttribute("flashError");
    session.removeAttribute("flashMessage");
    session.removeAttribute("flashError");

    String userName = (String) session.getAttribute("name");
    if (hasActiveCheckIn == null) {
        hasActiveCheckIn = false;
    }

    String activeServiceName = null;
    if (history != null) {
        for (CheckInRecord r : history) {
            if (r.getCheckOutTime() == null) {
                activeServiceName = r.getServiceName();
                break;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard - CampusQueue</title>
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
            padding: 40px 20px;
        }

        .hero h2 { font-size: 30px; margin-bottom: 10px; }
        .hero p { font-size: 15px; color: #cce0ff; }

        .flash {
            width: min(1100px, 94%);
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

        .page {
            width: min(1100px, 94%);
            margin: 24px auto 40px;
        }

        .summary-bar {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
            margin-bottom: 20px;
        }

        .summary-card {
            flex: 1;
            min-width: 220px;
            background: white;
            border-radius: 10px;
            padding: 18px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .summary-card h3 {
            color: #003366;
            font-size: 16px;
            margin-bottom: 8px;
        }

        .summary-card p {
            font-size: 14px;
            color: #555;
        }

        .panel {
            background: white;
            border-radius: 10px;
            padding: 22px;
            margin-bottom: 22px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .panel h3 {
            color: #003366;
            margin-bottom: 16px;
            font-size: 22px;
        }

        .services {
            display: flex;
            flex-wrap: wrap;
            gap: 18px;
        }

        .card {
            background: #fff;
            border-radius: 10px;
            padding: 18px;
            width: 300px;
            border: 1px solid #e8e8e8;
            box-shadow: 0 1px 4px rgba(0,0,0,0.06);
        }

        .card h4 {
            font-size: 18px;
            margin-bottom: 6px;
            color: #222;
        }

        .category {
            font-size: 12px;
            color: #777;
            margin-bottom: 10px;
        }

        .status, .location, .wait {
            font-size: 14px;
            margin-bottom: 8px;
        }

        .badge {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 12px;
            font-size: 12px;
            color: white;
            margin-bottom: 10px;
        }

        .low { background-color: #28a745; }
        .medium { background-color: #ffc107; color: #333; }
        .high { background-color: #dc3545; }

        .crowd-bar {
            height: 10px;
            border-radius: 5px;
            margin-bottom: 10px;
        }

        .card form {
            margin-top: 12px;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        input, button {
            padding: 10px 12px;
            border-radius: 6px;
            font-size: 14px;
        }

        input {
            border: 1px solid #ccc;
        }

        input:focus {
            outline: none;
            border-color: #003366;
        }

        button {
            background-color: #003366;
            color: white;
            border: none;
            cursor: pointer;
        }

        button:hover {
            background-color: #0055a5;
        }

        button:disabled {
            background-color: #9aa9bb;
            cursor: not-allowed;
        }

        .secondary-link {
            display: inline-block;
            margin-top: 10px;
            color: #003366;
            text-decoration: none;
            font-size: 14px;
            font-weight: bold;
        }

        .secondary-link:hover {
            text-decoration: underline;
        }

        .checkout-box {
            margin-top: 18px;
            padding-top: 18px;
            border-top: 1px solid #eee;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            overflow: hidden;
        }

        thead {
            background: #003366;
            color: white;
        }

        th, td {
            padding: 12px 10px;
            text-align: left;
            font-size: 14px;
        }

        tbody tr:nth-child(even) {
            background: #f8fbff;
        }

        tbody tr {
            border-bottom: 1px solid #e6eef7;
        }

        .empty-note {
            color: #777;
            font-size: 14px;
        }

        footer {
            text-align: center;
            padding: 20px;
            color: #777;
            font-size: 13px;
            margin-top: 30px;
        }
    </style>
</head>
<body>

<nav>
    <h1>CampusQueue</h1>
    <div class="nav-right">
        <span>Hi, <%= userName %></span>
        <a href="<%= request.getContextPath() %>/HomeServlet">Home</a>
        <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
    </div>
</nav>

<div class="hero">
    <h2>Student Dashboard</h2>
    <p>Check in, check out, and track live campus service activity</p>
</div>

<% if (flashMessage != null) { %>
    <div class="flash success"><%= flashMessage %></div>
<% } %>

<% if (flashError != null) { %>
    <div class="flash error"><%= flashError %></div>
<% } %>

<div class="page">

    <div class="summary-bar">
        <div class="summary-card">
            <h3>Account Status</h3>
            <% if (hasActiveCheckIn && activeServiceName != null) { %>
                <p>Currently checked in at: <strong><%= activeServiceName %></strong></p>
                <form action="<%= request.getContextPath() %>/CheckOutServlet" method="post" style="margin-top: 12px;">
                    <button type="submit">Check Out of Active Service</button>
                </form>
            <% } else { %>
                <p>You have no active check-in right now.</p>
            <% } %>
        </div>
        <div class="summary-card">
            <h3>Quick Tip</h3>
            <p>Use the service detail page to view hours, trends, and estimated wait times before visiting.</p>
        </div>
    </div>

    <div class="panel">
        <h3>Available Services</h3>

        <%
            String selectedCategory = (String) request.getAttribute("selectedCategory");
            if(selectedCategory == null) {
                selectedCategory = "";
            }
        %>
        <form method="get" action="<%= request.getContextPath()%>/StudentDashboardServlet"
              style="margin-bottom: 18px; display: flex; gap:10px; flex-wrap: wrap;">
            <select name="category"
                    style="padding: 8px 12px; border-radius: 6px; border: 1px solid #ccc; font-size: 14px;">
                <option value="">All Categories</option>
                <option value="Dining"  <%= "Dining".equals(selectedCategory)   ? "selected" : "" %>>Dining</option>
                <option value="Fitness"  <%= "Fitness".equals(selectedCategory)   ? "selected" : "" %>>Fitness</option>
                <option value="Advising"  <%= "Advising".equals(selectedCategory)   ? "selected" : "" %>>Advising</option>
                <option value="Parking"  <%= "Parking".equals(selectedCategory)   ? "selected" : "" %>>Parking</option>
            </select>
            <button type="submit">Filter</button>
            <% if (!selectedCategory.isEmpty()){ %>
                <a href="<%= request.getContextPath() %>/StudentDashboardServlet"
                   style="padding: 8px 12px; font-size: 14px; color: #003366;">Clear</a>
            <% } %>
        </form>


        <% if (services != null && !services.isEmpty()) { %>
            <div class="services">
                <% for (Service s : services) {
                    String crowdClass = "low";
                    if ("Medium".equalsIgnoreCase(s.getCrowdLevel())) {
                        crowdClass = "medium";
                    } else if ("High".equalsIgnoreCase(s.getCrowdLevel())) {
                        crowdClass = "high";
                    }
                %>
                <div class="card">
                    <h4><%= s.getServiceName() %></h4>
                    <div class="category"><%= s.getCategoryName() %></div>
                    <div class="crowd-bar <%= crowdClass %>"></div>
                    <span class="badge <%= crowdClass %>"><%= s.getCrowdLevel() %></span>
                    <div class="status">Status: <strong><%= s.getCurrentStatus() %></strong></div>
                    <div class="location">Location: <%= s.getLocation() %></div>
                    <div class="wait">Predicted Wait: <strong><%= String.format("%.1f", s.getPredictedWait()) %> min</strong></div>

                    <form action="<%= request.getContextPath() %>/CheckInServlet" method="post">
                        <input type="hidden" name="serviceName" value="<%= s.getServiceName() %>">
                        <input type="number" name="crowdEstimate" placeholder="Enter crowd estimate" min="1" max="1000" required>
                        <button type="submit" <%= hasActiveCheckIn ? "disabled" : "" %>>
                            Check In
                        </button>
                    </form>

                    <a class="secondary-link"
                       href="<%= request.getContextPath() %>/ServiceDetailServlet?serviceName=<%= java.net.URLEncoder.encode(s.getServiceName(), "UTF-8") %>">
                        View Details
                    </a>
                </div>
                <% } %>
            </div>
        <% } else { %>
            <p class="empty-note">No services are available right now.</p>
        <% } %>

    </div>

    <div class="panel">
        <h3>Your Check-In History</h3>

        <% if (history != null && !history.isEmpty()) { %>
            <table>
                <thead>
                    <tr>
                        <th>Check-In ID</th>
                        <th>Service</th>
                        <th>Check In Time</th>
                        <th>Check Out Time</th>
                        <th>Duration</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (CheckInRecord r : history) { %>
                    <tr>
                        <td><%= r.getCheckInId() %></td>
                        <td><%= r.getServiceName() %></td>
                        <td><%= r.getCheckInTime() %></td>
                        <td><%= r.getCheckOutTime() == null ? "Active" : r.getCheckOutTime() %></td>
                        <td><%= r.getDuration() == null ? "-" : r.getDuration() + " min" %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <p class="empty-note">You do not have any check-in history yet.</p>
        <% } %>
    </div>

</div>

<footer>
    CampusQueue &mdash; SJSU CS157A Section 2, Team 10
</footer>

</body>
</html>