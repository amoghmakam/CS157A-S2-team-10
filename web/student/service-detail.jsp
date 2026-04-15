<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Service" %>
<%@ page import="model.ServiceHour" %>
<%@ page import="model.WaitTrend" %>
<%
    Service service = (Service) request.getAttribute("service");
    List<ServiceHour> hours = (List<ServiceHour>) request.getAttribute("hours");
    List<WaitTrend> trends = (List<WaitTrend>) request.getAttribute("trends");
    String userName = (String) session.getAttribute("name");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Service Detail - CampusQueue</title>
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

        .detail-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 16px;
        }

        .detail-item {
            background: #f8fbff;
            border: 1px solid #e6eef7;
            border-radius: 8px;
            padding: 14px;
        }

        .detail-item strong {
            display: block;
            color: #003366;
            margin-bottom: 6px;
            font-size: 14px;
        }

        .badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            color: white;
        }

        .low { background-color: #28a745; }
        .medium { background-color: #ffc107; color: #333; }
        .high { background-color: #dc3545; }

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

        .back-link {
            display: inline-block;
            margin-bottom: 18px;
            color: #003366;
            text-decoration: none;
            font-weight: bold;
        }

        .back-link:hover {
            text-decoration: underline;
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
        <a href="<%= request.getContextPath() %>/StudentDashboardServlet">Student Dashboard</a>
        <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
    </div>
</nav>

<div class="hero">
    <h2>Service Details</h2>
    <p>Review location data, hours, and historical wait trends</p>
</div>

<div class="page">
    <a class="back-link" href="<%= request.getContextPath() %>/StudentDashboardServlet">&larr; Back to Student Dashboard</a>

    <% if (service != null) {
        String crowdClass = "low";
        if ("Medium".equalsIgnoreCase(service.getCrowdLevel())) {
            crowdClass = "medium";
        } else if ("High".equalsIgnoreCase(service.getCrowdLevel())) {
            crowdClass = "high";
        }
    %>
    <div class="panel">
        <h3><%= service.getServiceName() %></h3>
        <div class="detail-grid">
            <div class="detail-item">
                <strong>Category</strong>
                <span><%= service.getCategoryName() %></span>
            </div>
            <div class="detail-item">
                <strong>Status</strong>
                <span><%= service.getCurrentStatus() %></span>
            </div>
            <div class="detail-item">
                <strong>Location</strong>
                <span><%= service.getLocation() %></span>
            </div>
            <div class="detail-item">
                <strong>Building</strong>
                <span><%= service.getBuildingName() %></span>
            </div>
            <div class="detail-item">
                <strong>Room</strong>
                <span><%= service.getRoomNumber() %></span>
            </div>
            <div class="detail-item">
                <strong>Capacity</strong>
                <span><%= service.getCapacity() %></span>
            </div>
            <div class="detail-item">
                <strong>Live Crowd</strong>
                <span class="badge <%= crowdClass %>"><%= service.getCrowdLevel() %></span>
            </div>
            <div class="detail-item">
                <strong>Estimated Wait</strong>
                <span><%= String.format("%.1f", service.getPredictedWait()) %> min</span>
            </div>
        </div>
    </div>
    <% } else { %>
    <div class="panel">
        <h3>Service Details</h3>
        <p class="empty-note">No service was found. Make sure the page was opened with a valid serviceName parameter.</p>
    </div>
    <% } %>

    <div class="panel">
        <h3>Hours of Operation</h3>
        <% if (hours != null && !hours.isEmpty()) { %>
            <table>
                <thead>
                    <tr>
                        <th>Day</th>
                        <th>Open</th>
                        <th>Close</th>
                        <th>Closed?</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (ServiceHour h : hours) { %>
                    <tr>
                        <td><%= h.getDayOfWeek() %></td>
                        <td><%= h.getOpenTime() %></td>
                        <td><%= h.getCloseTime() %></td>
                        <td><%= h.isClosed() ? "Yes" : "No" %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <p class="empty-note">No hours are available for this service.</p>
        <% } %>
    </div>

    <div class="panel">
        <h3>Historical Trends</h3>
        <% if (trends != null && !trends.isEmpty()) { %>
            <table>
                <thead>
                    <tr>
                        <th>Time Slot</th>
                        <th>Average Wait</th>
                        <th>Total Check-Ins</th>
                        <th>Crowd Level</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (WaitTrend t : trends) { %>
                    <tr>
                        <td><%= t.getLabel() %></td>
                        <td><%= t.getAvgWait() %> min</td>
                        <td><%= t.getTotalCheckIns() %></td>
                        <td><%= t.getCrowdLevel() %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <p class="empty-note">No historical trend records are available yet.</p>
        <% } %>
    </div>
</div>

<footer>
    CampusQueue &mdash; SJSU CS157A Section 2, Team 10
</footer>

</body>
</html>