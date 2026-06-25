package servlet;

import dao.CheckInDao;
import dao.ServiceDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Service;

import java.io.IOException;
import java.util.Comparator;
import java.util.List;

@WebServlet("/StudentDashboardServlet")
public class StudentDashboardServlet extends HttpServlet {

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

        int studentId = (Integer) userIdObj;

        try {
            String category = request.getParameter("category");
            String sort = request.getParameter("sort");

            List<Service> services = serviceDao.getAllServices(category);

            if ("shortestWait".equals(sort)) {
                services.sort(Comparator.comparingDouble(Service::getPredictedWait));
            }

            request.setAttribute("services", services);
            request.setAttribute("selectedCategory", category != null ? category : "");
            request.setAttribute("selectedSort", sort != null ? sort : "");
            request.setAttribute("history", checkInDao.getStudentHistory(studentId));
            request.setAttribute("hasActiveCheckIn", checkInDao.hasActiveCheckIn(studentId));

            request.getRequestDispatcher("/student/dashboard.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Unable to load student dashboard.", e);
        }
    }
}