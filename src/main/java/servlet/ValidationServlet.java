package servlet;

import dao.AuditDao;
import dao.CheckInDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/ValidationServlet")
public class ValidationServlet extends HttpServlet {
    private final CheckInDao checkInDao = new CheckInDao();
    private final AuditDao auditDao = new AuditDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Object userIdObj = request.getSession().getAttribute("userId");
        String checkInIdValue = request.getParameter("checkInId");
        String validationType = request.getParameter("validationType");
        String validationReason = request.getParameter("validationReason");

        if (userIdObj == null) {
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
            return;
        }

        if (checkInIdValue == null || checkInIdValue.trim().isEmpty() ||
                validationType == null || validationType.trim().isEmpty() ||
                validationReason == null || validationReason.trim().isEmpty()) {
            request.getSession().setAttribute("flashError", "All validation fields are required.");
            response.sendRedirect(request.getContextPath() + "/StaffDashboardServlet");
            return;
        }

        int staffId = (Integer) userIdObj;

        try {
            int checkInId = Integer.parseInt(checkInIdValue);
            checkInDao.validateCheckIn(checkInId, staffId, validationType, validationReason);
            auditDao.log(staffId, "Validate Check-In",
                    validationType + " review submitted for check-in #" + checkInId);
            request.getSession().setAttribute("flashMessage", "Validation submitted successfully.");
            response.sendRedirect(request.getContextPath() + "/StaffDashboardServlet");
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("flashError", "Check-in ID must be a valid number.");
            response.sendRedirect(request.getContextPath() + "/StaffDashboardServlet");
        } catch (Exception e) {
            throw new ServletException("Unable to submit validation.", e);
        }
    }
}