<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Service" %>
<%@ page import="model.CheckInRecord" %>
<%@ page import="model.ValidationEntry" %>
<%
    List<Service> services = (List<Service>) request.getAttribute("services");
    List<CheckInRecord> records = (List<CheckInRecord>) request.getAttribute("records");
    List<ValidationEntry> validations = (List<ValidationEntry>) request.getAttribute("validations");

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
    <title>Staff Dashboard - CampusQueue</title>
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

        input, select, button {
            padding: 10px 12px;
            border-radius: 6px;
            font-size: 14px;
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
        <a href="<%= request.getContextPath() %>/StaffDashboardServlet">Staff Dashboard</a>
        <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
    </div>
</nav>

<div class="hero">
    <h2>Staff Dashboard</h2>
    <p>Manage assigned services and review recent activity</p>
</div>

<% if (flashMessage != null) { %>
    <div class="flash success"><%= flashMessage %></div>
<% } %>

<% if (flashError != null) { %>
    <div class="flash error"><%= flashError %></div>
<% } %>

<div class="page">

    <div class="panel">
        <h3>Assigned Services</h3>

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

                    <a class="secondary-link"
                       href="<%= request.getContextPath() %>/ServiceDetailServlet?serviceName=<%= java.net.URLEncoder.encode(s.getServiceName(), "UTF-8") %>">
                        View Details
                    </a>

                    <form action="<%= request.getContextPath() %>/UpdateServiceServlet" method="post">
                        <input type="hidden" name="serviceName" value="<%= s.getServiceName() %>">
                        <input type="number" name="capacity" value="<%= s.getCapacity() %>" min="1" required>
                        <select name="status" required>
                            <option value="Open" <%= "Open".equalsIgnoreCase(s.getCurrentStatus()) ? "selected" : "" %>>Open</option>
                            <option value="Busy" <%= "Busy".equalsIgnoreCase(s.getCurrentStatus()) ? "selected" : "" %>>Busy</option>
                            <option value="Available" <%= "Available".equalsIgnoreCase(s.getCurrentStatus()) ? "selected" : "" %>>Available</option>
                            <option value="Closed" <%= "Closed".equalsIgnoreCase(s.getCurrentStatus()) ? "selected" : "" %>>Closed</option>
                        </select>
                        <button type="submit">Update Service</button>
                    </form>
                </div>
                <% } %>
            </div>
        <% } else { %>
            <p class="empty-note">No services are assigned to this staff member.</p>
        <% } %>
    </div>

    <div class="panel">
        <h3>Recent Check-In Activity</h3>

        <% if (records != null && !records.isEmpty()) { %>
            <table>
                <thead>
                    <tr>
                        <th>Check-In ID</th>
                        <th>Student ID</th>
                        <th>Service</th>
                        <th>Check In Time</th>
                        <th>Check Out Time</th>
                        <th>Duration</th>
                        <th>Validate</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (CheckInRecord r : records) { %>
                    <tr>
                        <td><%= r.getCheckInId() %></td>
                        <td><%= r.getStudentId() %></td>
                        <td><%= r.getServiceName() %></td>
                        <td><%= r.getCheckInTime() %></td>
                        <td><%= r.getCheckOutTime() == null ? "Active" : r.getCheckOutTime() %></td>
                        <td><%= r.getDuration() == null ? "-" : r.getDuration() + " min" %></td>
                        <td>
                            <form action="<%= request.getContextPath() %>/ValidationServlet" method="post">
                                <input type="hidden" name="checkInId" value="<%= r.getCheckInId() %>">
                                <select name="validationType" required>
                                    <option value="Validated">Validated</option>
                                    <option value="Flagged">Flagged</option>
                                </select>
                                <input type="text" name="validationReason" placeholder="Reason" required>
                                <button type="submit">Submit</button>
                            </form>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <p class="empty-note">No recent activity was found for assigned services.</p>
        <% } %>
    </div>

    <div class="panel">
        <h3>Your Validation History</h3>

        <% if (validations != null && !validations.isEmpty()) { %>
            <table>
                <thead>
                    <tr>
                        <th>Validation ID</th>
                        <th>Check-In ID</th>
                        <th>Type</th>
                        <th>Reason</th>
                        <th>Time</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (ValidationEntry v : validations) { %>
                    <tr>
                        <td><%= v.getValidationId() %></td>
                        <td><%= v.getCheckInId() %></td>
                        <td><%= v.getValidationType() %></td>
                        <td><%= v.getValidationReason() %></td>
                        <td><%= v.getValidationTime() %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <p class="empty-note">You have not submitted any validations yet.</p>
        <% } %>
    </div>

</div>

<footer>
    CampusQueue &mdash; SJSU CS157A Section 2, Team 10
</footer>

</body>
</html>