<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Service" %>
<%@ page import="model.ServiceHour" %>
<%@ page import="model.WaitTrend" %>
<%@ page import="java.util.List" %>
<%
    Service service = (Service) request.getAttribute("service");
    List<ServiceHour> hours = (List<ServiceHour>) request.getAttribute("hours");
    List<WaitTrend> trends = (List<WaitTrend>) request.getAttribute("trends");
    List<WaitTrend> dayTrends = (List<WaitTrend>) request.getAttribute("dayTrends");
    List<WaitTrend> hourTrends = (List<WaitTrend>) request.getAttribute("hourTrends");
    String userName = (String) session.getAttribute("name");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Staff Service Details - CampusQueue</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css">
</head>
<body>

<nav class="top-nav">
    <h1>CampusQueue</h1>
    <div class="nav-right">
        <span>Hi, <%= userName %></span>
        <a href="<%= request.getContextPath() %>/StaffDashboardServlet">Staff Dashboard</a>
        <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
    </div>
</nav>

<section class="hero">
    <h2>Staff Service Details</h2>
    <p>Review assigned service details, hours, wait trends, and operational information</p>
</section>

<div class="page">
    <% if (service == null) { %>
        <div class="panel">
            <h3>Service Not Found</h3>
            <p class="empty-note">The requested service could not be found.</p>
            <a class="secondary-link" href="<%= request.getContextPath() %>/StaffDashboardServlet">Back to Staff Dashboard</a>
        </div>
    <% } else { %>

    <div class="panel">
        <h3><%= service.getServiceName() %></h3>
        <div class="analytics-summary">
            <div class="metric-card">
                <span class="metric-label">Category</span>
                <span class="metric-value small"><%= service.getCategoryName() %></span>
            </div>
            <div class="metric-card">
                <span class="metric-label">Status</span>
                <span class="metric-value small"><%= service.getCurrentStatus() %></span>
            </div>
            <div class="metric-card">
                <span class="metric-label">Capacity</span>
                <span class="metric-value"><%= service.getCapacity() %></span>
            </div>
            <div class="metric-card">
                <span class="metric-label">Active Check-ins</span>
                <span class="metric-value"><%= service.getActiveCount() %></span>
            </div>
            <div class="metric-card">
                <span class="metric-label">Predicted Wait</span>
                <span class="metric-value small"><%= String.format("%.1f", service.getPredictedWait()) %> min</span>
            </div>
            <div class="metric-card">
                <span class="metric-label">Crowd Level</span>
                <span class="metric-value small"><%= service.getCrowdLevel() %></span>
            </div>
        </div>

        <p><strong>Location:</strong> <%= service.getLocation() %></p>
        <p><strong>Building:</strong> <%= service.getBuildingName() == null ? "-" : service.getBuildingName() %></p>
        <p><strong>Room:</strong> <%= service.getRoomNumber() == null ? "-" : service.getRoomNumber() %></p>
        <p><strong>Trend:</strong> <%= service.getTrendLabel() == null ? "No trend available" : service.getTrendLabel() %></p>

        <a class="secondary-link" href="<%= request.getContextPath() %>/StaffDashboardServlet">Back to Staff Dashboard</a>
    </div>

    <div class="panel">
        <h3>Service Hours</h3>
        <% if (hours != null && !hours.isEmpty()) { %>
            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>Day</th>
                            <th>Open Time</th>
                            <th>Close Time</th>
                            <th>Closed</th>
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
            </div>
        <% } else { %>
            <p class="empty-note">No service hours are available yet.</p>
        <% } %>
    </div>

    <div class="panel">
        <h3>Historical Wait Records</h3>
        <% if (trends != null && !trends.isEmpty()) { %>
            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>Record</th>
                            <th>Average Wait</th>
                            <th>Total Check-ins</th>
                            <th>Crowd Level</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (WaitTrend t : trends) { %>
                        <tr>
                            <td><%= t.getLabel() %></td>
                            <td><%= String.format("%.1f", t.getAvgWait()) %> min</td>
                            <td><%= t.getTotalCheckIns() %></td>
                            <td><%= t.getCrowdLevel() %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        <% } else { %>
            <p class="empty-note">No historical wait records are available yet.</p>
        <% } %>
    </div>

    <div class="panel">
        <h3>Average Wait by Day</h3>
        <% if (dayTrends != null && !dayTrends.isEmpty()) { %>
            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>Day</th>
                            <th>Average Wait</th>
                            <th>Total Check-ins</th>
                            <th>Crowd Level</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (WaitTrend t : dayTrends) { %>
                        <tr>
                            <td><%= t.getLabel() %></td>
                            <td><%= String.format("%.1f", t.getAvgWait()) %> min</td>
                            <td><%= t.getTotalCheckIns() %></td>
                            <td><%= t.getCrowdLevel() %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        <% } else { %>
            <p class="empty-note">No day-level analytics are available yet.</p>
        <% } %>
    </div>

    <div class="panel">
        <h3>Average Wait by Hour</h3>
        <% if (hourTrends != null && !hourTrends.isEmpty()) { %>
            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>Hour</th>
                            <th>Average Wait</th>
                            <th>Total Check-ins</th>
                            <th>Crowd Level</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (WaitTrend t : hourTrends) { %>
                        <tr>
                            <td><%= t.getLabel() %></td>
                            <td><%= String.format("%.1f", t.getAvgWait()) %> min</td>
                            <td><%= t.getTotalCheckIns() %></td>
                            <td><%= t.getCrowdLevel() %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        <% } else { %>
            <p class="empty-note">No hour-level analytics are available yet.</p>
        <% } %>
    </div>

    <% } %>
</div>

<footer class="site-footer">CampusQueue &mdash; SJSU CS157A Section 2, Team 10</footer>
</body>
</html>
