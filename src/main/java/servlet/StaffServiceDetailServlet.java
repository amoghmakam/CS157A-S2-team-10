package servlet;

import dao.ServiceDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Staff-only service detail controller.
 * This keeps staff users inside the staff workflow instead of sending them to the student detail page.
 */
@WebServlet("/StaffServiceDetailServlet")
public class StaffServiceDetailServlet extends HttpServlet {
    private final ServiceDao serviceDao = new ServiceDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String serviceName = request.getParameter("serviceName");

        if (serviceName == null || serviceName.trim().isEmpty()) {
            session.setAttribute("flashError", "Service name was missing.");
            response.sendRedirect(request.getContextPath() + "/StaffDashboardServlet");
            return;
        }

        try {
            int staffId = (int) session.getAttribute("userId");
            String role = (String) session.getAttribute("role");

            // Staff can only view details for assigned services.
            // Admins are allowed through because they may use staff-level views while testing.
            if (!"ADMIN".equals(role) && !serviceDao.isStaffAssignedToService(staffId, serviceName)) {
                session.setAttribute("flashError", "You are not assigned to that service.");
                response.sendRedirect(request.getContextPath() + "/StaffDashboardServlet");
                return;
            }

            request.setAttribute("service", serviceDao.getServiceByName(serviceName));
            request.setAttribute("hours", serviceDao.getServiceHours(serviceName));
            request.setAttribute("trends", serviceDao.getWaitTrends(serviceName));
            request.setAttribute("dayTrends", serviceDao.getAvgWaitByDay(serviceName));
            request.setAttribute("hourTrends", serviceDao.getAvgWaitByHour(serviceName));

            request.getRequestDispatcher("/staff/service-detail.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Unable to load staff service details.", e);
        }
    }
}
