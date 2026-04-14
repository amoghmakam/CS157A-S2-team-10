package servlet;

import dao.ServiceDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/HomeServlet")
public class HomeServlet extends HttpServlet {
    private final ServiceDao serviceDao = new ServiceDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String category = request.getParameter("category");
            request.setAttribute("services", serviceDao.getAllServices(category));
            request.getRequestDispatcher("/index.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Unable to load home page.", e);
        }
    }
}