package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Central login/role check for protected pages.
 * This keeps students, staff, and admins from opening pages that do not belong to their role.
 */
@WebFilter(urlPatterns = {
        "/StudentDashboardServlet",
        "/ServiceDetailServlet",
        "/CheckInServlet",
        "/CheckOutServlet",
        "/StaffDashboardServlet",
        "/UpdateServiceServlet",
        "/ValidationServlet",
        "/AdminDashboardServlet",
        "/ManageServiceServlet",
        "/AssignStaffServlet",
        "/UserStatusServlet"
})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/HomeServlet");
            return;
        }

        String uri = req.getRequestURI();
        String role = (String) session.getAttribute("role");

        if ((uri.contains("StaffDashboardServlet") || uri.contains("UpdateServiceServlet") || uri.contains("ValidationServlet"))
                && !("STAFF".equals(role) || "ADMIN".equals(role))) {
            resp.sendRedirect(req.getContextPath() + "/HomeServlet");
            return;
        }

        if ((uri.contains("AdminDashboardServlet") || uri.contains("ManageServiceServlet") ||
                uri.contains("AssignStaffServlet") || uri.contains("UserStatusServlet"))
                && !"ADMIN".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/HomeServlet");
            return;
        }

        chain.doFilter(request, response);
    }
}
