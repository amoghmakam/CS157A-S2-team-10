package servlet;

import dao.CheckInDao;
import dao.ServiceDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

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
            request.setAttribute("services", serviceDao.getAssignedServices(staffId));
            request.setAttribute("records", checkInDao.getAssignedServiceRecentActivity(staffId));
            request.setAttribute("validations", checkInDao.getRecentValidationsForStaff(staffId));
            request.getRequestDispatcher("/staff/dashboard.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Unable to load staff dashboard.", e);
        }
    }
}