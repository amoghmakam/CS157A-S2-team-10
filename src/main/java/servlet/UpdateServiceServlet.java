package servlet;

import dao.AuditDao;
import dao.ServiceDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/UpdateServiceServlet")
public class UpdateServiceServlet extends HttpServlet {
    private final ServiceDao serviceDao = new ServiceDao();
    private final AuditDao auditDao = new AuditDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Object userIdObj = request.getSession().getAttribute("userId");
        String role = (String) request.getSession().getAttribute("role");
        String serviceName = request.getParameter("serviceName");
        String capacityValue = request.getParameter("capacity");
        String status = request.getParameter("status");
        String dayOfWeek = request.getParameter("dayOfWeek");
        String openTime = request.getParameter("openTime");
        String closeTime = request.getParameter("closeTime");
        boolean isClosed = request.getParameter("isClosed") != null;

        if (userIdObj == null) {
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
            return;
        }

        if (serviceName == null || serviceName.trim().isEmpty() ||
                capacityValue == null || capacityValue.trim().isEmpty() ||
                status == null || status.trim().isEmpty()) {
            request.getSession().setAttribute("flashError", "Missing service update information.");
            response.sendRedirect(request.getContextPath() + "/StaffDashboardServlet");
            return;
        }

        int userId = (Integer) userIdObj;

        try {
            if ("STAFF".equals(role) && !serviceDao.isStaffAssignedToService(userId, serviceName)) {
                request.getSession().setAttribute("flashError", "You can only update services assigned to you.");
                response.sendRedirect(request.getContextPath() + "/StaffDashboardServlet");
                return;
            }

            int capacity = Integer.parseInt(capacityValue);
            serviceDao.updateService(serviceName, capacity, status);

            // Hours are optional so old forms still work.
            if (dayOfWeek != null && !dayOfWeek.trim().isEmpty()) {
                serviceDao.updateServiceHours(serviceName, dayOfWeek, openTime, closeTime, isClosed);
            }

            auditDao.log(userId, "Update Service",
                    "Updated " + serviceName + " with status " + status + " and capacity " + capacity);
            request.getSession().setAttribute("flashMessage", "Service updated successfully.");
            response.sendRedirect(request.getContextPath() + ("ADMIN".equals(role) ? "/AdminDashboardServlet" : "/StaffDashboardServlet"));
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("flashError", "Capacity must be a valid number.");
            response.sendRedirect(request.getContextPath() + "/StaffDashboardServlet");
        } catch (Exception e) {
            throw new ServletException("Unable to update service.", e);
        }
    }
}
