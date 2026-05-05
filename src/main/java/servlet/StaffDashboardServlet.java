package servlet;

import dao.CheckInDao;
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

@WebServlet("/StaffDashboardServlet")
public class StaffDashboardServlet extends HttpServlet {
    private final ServiceDao serviceDao = new ServiceDao();
    private final CheckInDao checkInDao = new CheckInDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Object userIdObj = request.getSession().getAttribute("userId");

        if (userIdObj == null) {
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
            return;
        }

        int staffId = (Integer) userIdObj;

        try {
            List<Service> services = serviceDao.getAssignedServices(staffId);

            Map<String, List<WaitTrend>> dayAnalytics = new LinkedHashMap<>();
            Map<String, List<WaitTrend>> hourAnalytics = new LinkedHashMap<>();
            for (Service s : services) {
                dayAnalytics.put(s.getServiceName(), serviceDao.getAvgWaitByDay(s.getServiceName()));
                hourAnalytics.put(s.getServiceName(), serviceDao.getAvgWaitByHour(s.getServiceName()));
            }

            request.setAttribute("services", services);
            request.setAttribute("records", checkInDao.getAssignedServiceRecentActivity(staffId));
            request.setAttribute("validations", checkInDao.getRecentValidationsForStaff(staffId));
            request.setAttribute("dayAnalytics", dayAnalytics);
            request.setAttribute("hourAnalytics", hourAnalytics);
            request.getRequestDispatcher("/staff/dashboard.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Unable to load staff dashboard.", e);
        }
    }
}
