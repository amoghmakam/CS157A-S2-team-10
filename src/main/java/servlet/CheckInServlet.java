package servlet;

import dao.AuditDao;
import dao.CheckInDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/CheckInServlet")
public class CheckInServlet extends HttpServlet {
    private final CheckInDao checkInDao = new CheckInDao();
    private final AuditDao auditDao = new AuditDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Object userIdObj = request.getSession().getAttribute("userId");
        String serviceName = request.getParameter("serviceName");
        String crowdEstimateValue = request.getParameter("crowdEstimate");

        if (userIdObj == null) {
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
            return;
        }

        if (serviceName == null || serviceName.trim().isEmpty() ||
                crowdEstimateValue == null || crowdEstimateValue.trim().isEmpty()) {
            request.getSession().setAttribute("flashError", "Missing check-in information.");
            response.sendRedirect(request.getContextPath() + "/StudentDashboardServlet");
            return;
        }

        int studentId = (Integer) userIdObj;

        try {
            int crowdEstimate = Integer.parseInt(crowdEstimateValue);

            if (checkInDao.hasActiveCheckIn(studentId)) {
                request.getSession().setAttribute("flashError", "You already have an active check-in.");
                response.sendRedirect(request.getContextPath() + "/StudentDashboardServlet");
                return;
            }

            checkInDao.createCheckIn(studentId, serviceName, crowdEstimate);
            auditDao.log(studentId, "Check-In", "Student checked into " + serviceName);
            request.getSession().setAttribute("flashMessage", "Check-in successful.");
            response.sendRedirect(request.getContextPath() + "/StudentDashboardServlet");
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("flashError", "Crowd estimate must be a valid number.");
            response.sendRedirect(request.getContextPath() + "/StudentDashboardServlet");
        } catch (Exception e) {
            throw new ServletException("Unable to process check-in.", e);
        }
    }
}