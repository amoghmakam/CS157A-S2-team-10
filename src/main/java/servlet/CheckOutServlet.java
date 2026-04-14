package servlet;

import dao.AuditDao;
import dao.CheckInDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/CheckOutServlet")
public class CheckOutServlet extends HttpServlet {
    private final CheckInDao checkInDao = new CheckInDao();
    private final AuditDao auditDao = new AuditDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Object userIdObj = request.getSession().getAttribute("userId");

        if (userIdObj == null) {
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
            return;
        }

        int studentId = (Integer) userIdObj;

        try {
            if (!checkInDao.hasActiveCheckIn(studentId)) {
                request.getSession().setAttribute("flashError", "You do not have an active check-in to close.");
                response.sendRedirect(request.getContextPath() + "/StudentDashboardServlet");
                return;
            }

            checkInDao.checkOut(studentId);
            auditDao.log(studentId, "Check-Out", "Student checked out of active service");
            request.getSession().setAttribute("flashMessage", "Check-out successful.");
            response.sendRedirect(request.getContextPath() + "/StudentDashboardServlet");
        } catch (Exception e) {
            throw new ServletException("Unable to process check-out.", e);
        }
    }
}