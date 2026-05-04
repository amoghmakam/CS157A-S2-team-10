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

        if (userIdObj == null) {
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "add";
        }

        int adminId = (Integer) userIdObj;
        String serviceName = request.getParameter("serviceName");

        try {
            if ("deactivate".equals(action)) {
                serviceDao.deactivateService(serviceName);
                auditDao.log(adminId, "Deactivate Service", "Deactivated service " + serviceName);
                request.getSession().setAttribute("flashMessage", "Service deactivated successfully.");
            } else if ("remove".equals(action)) {
                serviceDao.removeService(serviceName);
                auditDao.log(adminId, "Remove Service", "Removed service " + serviceName);
                request.getSession().setAttribute("flashMessage", "Service removed successfully.");
            } else {
                String location = request.getParameter("location");
                String buildingName = request.getParameter("buildingName");
                String roomNumber = request.getParameter("roomNumber");
                String capacityValue = request.getParameter("capacity");
                String currentStatus = request.getParameter("currentStatus");
                String categoryName = request.getParameter("categoryName");
                String oldServiceName = request.getParameter("oldServiceName");

                if (serviceName == null || serviceName.trim().isEmpty() ||
                        location == null || location.trim().isEmpty() ||
                        capacityValue == null || capacityValue.trim().isEmpty() ||
                        currentStatus == null || currentStatus.trim().isEmpty() ||
                        categoryName == null || categoryName.trim().isEmpty()) {
                    request.getSession().setAttribute("flashError", "Missing required service information.");
                    response.sendRedirect(request.getContextPath() + "/AdminDashboardServlet");
                    return;
                }

                int capacity = Integer.parseInt(capacityValue);

                if ("edit".equals(action)) {
                    serviceDao.updateServiceFull(oldServiceName, serviceName, location, buildingName, roomNumber,
                            capacity, currentStatus, categoryName);
                    auditDao.log(adminId, "Edit Service", "Edited service " + oldServiceName);
                    request.getSession().setAttribute("flashMessage", "Service edited successfully.");
                } else {
                    serviceDao.addService(serviceName, location, buildingName, roomNumber,
                            capacity, currentStatus, categoryName);
                    auditDao.log(adminId, "Add Service", "Added service " + serviceName);
                    request.getSession().setAttribute("flashMessage", "Service added successfully.");
                }
            }

            response.sendRedirect(request.getContextPath() + "/AdminDashboardServlet");
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("flashError", "Capacity must be a valid number.");
            response.sendRedirect(request.getContextPath() + "/AdminDashboardServlet");
        } catch (Exception e) {
            throw new ServletException("Unable to manage service.", e);
        }
    }
}
