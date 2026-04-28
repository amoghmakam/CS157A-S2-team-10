package servlet;

import dao.CheckInDao;
import dao.ServiceDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

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
            //For category filter
            //reads category from the URL when student clicks "filter"
            String category = request.getParameter("category");
            //Passes the category to DAO
            request.setAttribute("services", serviceDao.getAllServices(category));
            //Sends category back to JSP , prevents sending null
            request.setAttribute("selectedCategory", category != null ? category : "");

            request.setAttribute("history", checkInDao.getStudentHistory(studentId));
            request.setAttribute("hasActiveCheckIn", checkInDao.hasActiveCheckIn(studentId));
            request.getRequestDispatcher("/student/dashboard.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Unable to load student dashboard.", e);
        }
    }
}