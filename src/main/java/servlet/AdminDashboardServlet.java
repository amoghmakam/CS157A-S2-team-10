package servlet;

import dao.AdminAnalyticsDao;
import dao.AdminDao;
import dao.ServiceDao;
import model.Service;
import model.WaitTrend;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/AdminDashboardServlet")
public class AdminDashboardServlet extends HttpServlet {
    private final ServiceDao serviceDao = new ServiceDao();
    private final AdminDao adminDao = new AdminDao();
    private final AdminAnalyticsDao adminAnalyticsDao = new AdminAnalyticsDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<Service> services = serviceDao.getAllServices(null);

            Map<String, List<WaitTrend>> dayAnalytics = new LinkedHashMap<>();
            Map<String, List<WaitTrend>> hourAnalytics = new LinkedHashMap<>();

            for (Service s : services) {
                dayAnalytics.put(s.getServiceName(), serviceDao.getAvgWaitByDay(s.getServiceName()));
                hourAnalytics.put(s.getServiceName(), serviceDao.getAvgWaitByHour(s.getServiceName()));
            }

            request.setAttribute("services", services);
            request.setAttribute("categories", serviceDao.getAllCategories());
            request.setAttribute("auditLogs", adminDao.getAuditLogs());
            request.setAttribute("dayAnalytics", dayAnalytics);
            request.setAttribute("hourAnalytics", hourAnalytics);

            request.setAttribute("analytics", adminAnalyticsDao.getAdminAnalytics());

            request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Unable to load admin dashboard.", e);
        }
    }
}