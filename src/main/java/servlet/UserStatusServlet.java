package servlet;

import dao.AuditDao;
import dao.UserDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Admin-only servlet for simple user moderation.
 * Admins can mark an account ACTIVE or SUSPENDED.
 */
@WebServlet("/UserStatusServlet")
public class UserStatusServlet extends HttpServlet {
    private final UserDao userDao = new UserDao();
    private final AuditDao auditDao = new AuditDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Object adminIdObj = request.getSession().getAttribute("userId");
        String role = (String) request.getSession().getAttribute("role");
        String userIdValue = request.getParameter("userId");
        String accountStatus = request.getParameter("accountStatus");

        if (adminIdObj == null || !"ADMIN".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
            return;
        }

        if (userIdValue == null || userIdValue.trim().isEmpty() ||
                accountStatus == null || accountStatus.trim().isEmpty()) {
            request.getSession().setAttribute("flashError", "User ID and account status are required.");
            response.sendRedirect(request.getContextPath() + "/AdminDashboardServlet");
            return;
        }

        try {
            int adminId = (Integer) adminIdObj;
            int userId = Integer.parseInt(userIdValue);

            if (!"ACTIVE".equals(accountStatus) && !"SUSPENDED".equals(accountStatus)) {
                request.getSession().setAttribute("flashError", "Account status must be ACTIVE or SUSPENDED.");
                response.sendRedirect(request.getContextPath() + "/AdminDashboardServlet");
                return;
            }

            userDao.updateAccountStatus(userId, accountStatus);
            auditDao.log(adminId, "Update Account Status", "Changed user " + userId + " to " + accountStatus);
            request.getSession().setAttribute("flashMessage", "User account status updated.");
            response.sendRedirect(request.getContextPath() + "/AdminDashboardServlet");
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("flashError", "User ID must be a number.");
            response.sendRedirect(request.getContextPath() + "/AdminDashboardServlet");
        } catch (Exception e) {
            throw new ServletException("Unable to update user status.", e);
        }
    }
}
