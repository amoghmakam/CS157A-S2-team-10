package servlet;

import dao.AdminDao;
import dao.ServiceDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/AdminDashboardServlet")
public class AdminDashboardServlet extends HttpServlet {
    private final ServiceDao serviceDao = new ServiceDao();
    private final AdminDao adminDao = new AdminDao();      //Create DAO object

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setAttribute("services", serviceDao.getAllServices(null));
            request.setAttribute("auditLogs", adminDao.getAuditLogs());     //Calls new method
            request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Unable to load admin dashboard.", e);
        }
    }
}