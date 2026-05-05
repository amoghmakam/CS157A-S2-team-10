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
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css">
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
        <%
            List<WaitTrend> dayTrends = (List<WaitTrend>) request.getAttribute("dayTrends");
            List<WaitTrend> hourTrends = (List<WaitTrend>) request.getAttribute("hourTrends");

            java.util.Map<String, WaitTrend> dayMap = new java.util.HashMap<>();
            if (dayTrends != null) { for (WaitTrend t : dayTrends) dayMap.put(t.getLabel(), t); }
            java.util.Map<String, WaitTrend> hourMap = new java.util.HashMap<>();
            if (hourTrends != null) { for (WaitTrend t : hourTrends) hourMap.put(t.getLabel(), t); }

            java.util.Set<String> openDays = new java.util.HashSet<>();
            if (hours != null) {
                for (ServiceHour h : hours) {
                    if (!h.isClosed()) openDays.add(h.getDayOfWeek());
                }
            }
        %>
        <p style="font-size:13px; color:#555; margin-bottom:14px;">Average wait time by day and hour based on historical check-in data.</p>

        <strong style="display:block; color:#003366; margin-bottom:8px;">By Day of Week</strong>
        <div style="display:flex; gap:6px; margin-bottom:20px;">
            <% String[] allDays = {"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"};
               String[] shortDays = {"Sun","Mon","Tue","Wed","Thu","Fri","Sat"};
               for (int i = 0; i < allDays.length; i++) {
                   String d = allDays[i];
                   String ds = shortDays[i];
                   boolean isOpen = openDays.isEmpty() || openDays.contains(d);
                   String bg, tooltip;
                   if (!isOpen) {
                       bg = "#666"; tooltip = d + ": Closed";
                   } else if (dayMap.containsKey(d)) {
                       WaitTrend t = dayMap.get(d);
                       String cl = t.getCrowdLevel();
                       bg = "Low".equals(cl) ? "#28a745" : "Medium".equals(cl) ? "#ffc107" : "#dc3545";
                       tooltip = d + ": avg " + String.format("%.1f", t.getAvgWait()) + " min (" + cl + ")";
                   } else {
                       bg = "#e0e0e0"; tooltip = d + ": No data";
                   }
            %>
            <div title="<%= tooltip %>" style="flex:1; background:<%= bg %>; border-radius:6px; padding:10px 0; text-align:center; font-size:12px; color:<%= "#ffc107".equals(bg) ? "#333" : "white" %>; font-weight:bold; cursor:default;">
                <%= ds %>
            </div>
            <% } %>
        </div>

        <strong style="display:block; color:#003366; margin-bottom:8px;">By Hour of Day</strong>
        <div style="display:flex; gap:2px; margin-bottom:10px;">
            <% String[] allHours = {"12am","1am","2am","3am","4am","5am","6am","7am","8am","9am","10am","11am",
                                    "12pm","1pm","2pm","3pm","4pm","5pm","6pm","7pm","8pm","9pm","10pm","11pm"};
               for (String hl : allHours) {
                   String bg2, tooltip2, textColor2;
                   if (hourMap.containsKey(hl)) {
                       WaitTrend t = hourMap.get(hl);
                       String cl = t.getCrowdLevel();
                       bg2 = "Low".equals(cl) ? "#28a745" : "Medium".equals(cl) ? "#ffc107" : "#dc3545";
                       textColor2 = "Medium".equals(cl) ? "#333" : "white";
                       tooltip2 = hl + ": avg " + String.format("%.1f", t.getAvgWait()) + " min (" + cl + ")";
                   } else {
                       bg2 = "#e0e0e0"; textColor2 = "#888"; tooltip2 = hl + ": No data";
                   }
            %>
            <div title="<%= tooltip2 %>" style="flex:1; background:<%= bg2 %>; border-radius:3px; height:46px; cursor:default; display:flex; align-items:center; justify-content:center; overflow:hidden;">
                <span style="font-size:10px; color:<%= textColor2 %>; font-weight:bold; line-height:1;"><%= hl %></span>
            </div>
            <% } %>
        </div>
        <div style="display:flex; gap:6px; flex-wrap:wrap; font-size:11px; color:#555; margin-bottom:4px;">
            <span style="background:#e0e0e0; padding:2px 8px; border-radius:3px; color:#333;">No data</span>
            <span style="background:#28a745; color:white; padding:2px 8px; border-radius:3px;">Low</span>
            <span style="background:#ffc107; color:#333; padding:2px 8px; border-radius:3px;">Medium</span>
            <span style="background:#dc3545; color:white; padding:2px 8px; border-radius:3px;">High</span>
            <span style="background:#666; color:white; padding:2px 8px; border-radius:3px;">Closed</span>
        </div>

        <%
            String bestDay = null;
            double bestDayWait = Double.MAX_VALUE;
            if (dayTrends != null) {
                for (WaitTrend t : dayTrends) {
                    if (t.getAvgWait() < bestDayWait && openDays.contains(t.getLabel())) {
                        bestDayWait = t.getAvgWait();
                        bestDay = t.getLabel();
                    }
                }
            }
            String bestHour = null;
            double bestHourWait = Double.MAX_VALUE;
            if (hourTrends != null) {
                for (WaitTrend t : hourTrends) {
                    if (t.getAvgWait() < bestHourWait) {
                        bestHourWait = t.getAvgWait();
                        bestHour = t.getLabel();
                    }
                }
            }
        %>
        <% if (bestDay != null || bestHour != null) { %>
        <div style="margin-top:16px; padding:14px 18px; background:#e8f7ee; border:1px solid #b9e5c8; border-radius:8px; font-size:14px; color:#1d6b39;">
            <strong>Best time to visit:</strong>
            <% if (bestDay != null && bestHour != null) { %>
                <%= bestDay %> at <%= bestHour %> &mdash; avg wait <strong><%= String.format("%.1f", Math.min(bestDayWait, bestHourWait)) %> min</strong>
            <% } else if (bestDay != null) { %>
                <%= bestDay %> &mdash; avg wait <strong><%= String.format("%.1f", bestDayWait) %> min</strong>
            <% } else { %>
                <%= bestHour %> &mdash; avg wait <strong><%= String.format("%.1f", bestHourWait) %> min</strong>
            <% } %>
        </div>
        <% } %>
    </div>
</div>

<footer>
    CampusQueue &mdash; SJSU CS157A Section 2, Team 10
</footer>

</body>
</html>