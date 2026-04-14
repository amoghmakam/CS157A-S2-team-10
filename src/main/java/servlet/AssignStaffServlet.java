package servlet;

import dao.AdminDao;
import dao.AuditDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/AssignStaffServlet")
public class AssignStaffServlet extends HttpServlet {
    private final AdminDao adminDao = new AdminDao();
    private final AuditDao auditDao = new AuditDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Object userIdObj = request.getSession().getAttribute("userId");
        String staffIdValue = request.getParameter("staffId");
        String serviceName = request.getParameter("serviceName");

        if (userIdObj == null) {
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
            return;
        }

        if (staffIdValue == null || staffIdValue.trim().isEmpty() ||
                serviceName == null || serviceName.trim().isEmpty()) {
            request.getSession().setAttribute("flashError", "Staff ID and service name are required.");
            response.sendRedirect(request.getContextPath() + "/AdminDashboardServlet");
            return;
        }

        int adminId = (Integer) userIdObj;

        try {
            int staffId = Integer.parseInt(staffIdValue);
            adminDao.assignStaff(staffId, serviceName);
            auditDao.log(adminId, "Assign Staff", "Assigned staff " + staffId + " to " + serviceName);
            request.getSession().setAttribute("flashMessage", "Staff assigned successfully.");
            response.sendRedirect(request.getContextPath() + "/AdminDashboardServlet");
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("flashError", "Staff ID must be a valid number.");
            response.sendRedirect(request.getContextPath() + "/AdminDashboardServlet");
        } catch (Exception e) {
            throw new ServletException("Unable to assign staff.", e);
        }
    }
}