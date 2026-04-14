package servlet;

import dao.ServiceDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/ServiceDetailServlet")
public class ServiceDetailServlet extends HttpServlet {
    private final ServiceDao serviceDao = new ServiceDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String serviceName = request.getParameter("serviceName");

        if (serviceName == null || serviceName.trim().isEmpty()) {
            request.getSession().setAttribute("flashError", "Service name was missing.");
            response.sendRedirect(request.getContextPath() + "/StudentDashboardServlet");
            return;
        }

        try {
            request.setAttribute("service", serviceDao.getServiceByName(serviceName));
            request.setAttribute("hours", serviceDao.getServiceHours(serviceName));
            request.setAttribute("trends", serviceDao.getWaitTrends(serviceName));
            request.getRequestDispatcher("/student/service-detail.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Unable to load service details.", e);
        }
    }
}