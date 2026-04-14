package servlet;

import dao.AuditDao;
import dao.ServiceDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/ManageServiceServlet")
public class ManageServiceServlet extends HttpServlet {
    private final ServiceDao serviceDao = new ServiceDao();
    private final AuditDao auditDao = new AuditDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Object userIdObj = request.getSession().getAttribute("userId");

        String serviceName = request.getParameter("serviceName");
        String location = request.getParameter("location");
        String buildingName = request.getParameter("buildingName");
        String roomNumber = request.getParameter("roomNumber");
        String capacityValue = request.getParameter("capacity");
        String currentStatus = request.getParameter("currentStatus");
        String categoryName = request.getParameter("categoryName");

        if (userIdObj == null) {
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
            return;
        }

        if (serviceName == null || serviceName.trim().isEmpty() ||
                location == null || location.trim().isEmpty() ||
                capacityValue == null || capacityValue.trim().isEmpty() ||
                currentStatus == null || currentStatus.trim().isEmpty() ||
                categoryName == null || categoryName.trim().isEmpty()) {
            request.getSession().setAttribute("flashError", "Missing required service information.");
            response.sendRedirect(request.getContextPath() + "/AdminDashboardServlet");
            return;
        }

        int adminId = (Integer) userIdObj;

        try {
            int capacity = Integer.parseInt(capacityValue);

            serviceDao.addService(
                    serviceName,
                    location,
                    buildingName,
                    roomNumber,
                    capacity,
                    currentStatus,
                    categoryName
            );

            auditDao.log(adminId, "Add Service", "Added service " + serviceName);
            request.getSession().setAttribute("flashMessage", "Service added successfully.");
            response.sendRedirect(request.getContextPath() + "/AdminDashboardServlet");
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("flashError", "Capacity must be a valid number.");
            response.sendRedirect(request.getContextPath() + "/AdminDashboardServlet");
        } catch (Exception e) {
            throw new ServletException("Unable to add service.", e);
        }
    }
}