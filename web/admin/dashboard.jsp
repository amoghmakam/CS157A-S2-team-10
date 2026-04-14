<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Service" %>
<%
    List<Service> services = (List<Service>) request.getAttribute("services");

    String flashMessage = (String) session.getAttribute("flashMessage");
    String flashError = (String) session.getAttribute("flashError");
    session.removeAttribute("flashMessage");
    session.removeAttribute("flashError");

    String userName = (String) session.getAttribute("name");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - CampusQueue</title>
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
            width: min(1150px, 94%);
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
            width: min(1150px, 94%);
            margin: 24px auto 40px;
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

        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 12px;
        }

        input, select, button {
            padding: 10px 12px;
            border-radius: 6px;
            font-size: 14px;
            width: 100%;
        }

        input, select {
            border: 1px solid #ccc;
        }

        input:focus, select:focus {
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
    <h2>Admin Dashboard</h2>
    <p>Manage services and staff assignments across the platform</p>
</div>

<% if (flashMessage != null) { %>
    <div class="flash success"><%= flashMessage %></div>
<% } %>

<% if (flashError != null) { %>
    <div class="flash error"><%= flashError %></div>
<% } %>

<div class="page">

    <div class="panel">
        <h3>All Services</h3>

        <% if (services != null && !services.isEmpty()) { %>
            <table>
                <thead>
                    <tr>
                        <th>Service</th>
                        <th>Category</th>
                        <th>Status</th>
                        <th>Capacity</th>
                        <th>Location</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Service s : services) { %>
                    <tr>
                        <td><%= s.getServiceName() %></td>
                        <td><%= s.getCategoryName() %></td>
                        <td><%= s.getCurrentStatus() %></td>
                        <td><%= s.getCapacity() %></td>
                        <td><%= s.getLocation() %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <p class="empty-note">No services are currently in the system.</p>
        <% } %>
    </div>

    <div class="panel">
        <h3>Add Service</h3>
        <form action="<%= request.getContextPath() %>/ManageServiceServlet" method="post">
            <div class="form-grid">
                <input type="text" name="serviceName" placeholder="Service Name" required>
                <input type="text" name="location" placeholder="Location" required>
                <input type="text" name="buildingName" placeholder="Building Name">
                <input type="text" name="roomNumber" placeholder="Room Number">
                <input type="number" name="capacity" placeholder="Capacity" required>
                <select name="currentStatus">
                    <option value="Open">Open</option>
                    <option value="Busy">Busy</option>
                    <option value="Available">Available</option>
                    <option value="Closed">Closed</option>
                </select>
                <select name="categoryName">
                    <option value="Dining">Dining</option>
                    <option value="Fitness">Fitness</option>
                    <option value="Advising">Advising</option>
                    <option value="Parking">Parking</option>
                </select>
            </div>
            <div style="margin-top: 14px;">
                <button type="submit">Add Service</button>
            </div>
        </form>
    </div>

    <div class="panel">
        <h3>Assign Staff to Service</h3>
        <form action="<%= request.getContextPath() %>/AssignStaffServlet" method="post">
            <div class="form-grid">
                <input type="number" name="staffId" placeholder="Staff ID" required>
                <input type="text" name="serviceName" placeholder="Service Name" required>
            </div>
            <div style="margin-top: 14px;">
                <button type="submit">Assign Staff</button>
            </div>
        </form>
    </div>

</div>

<footer>
    CampusQueue &mdash; SJSU CS157A Section 2, Team 10
</footer>

</body>
</html>