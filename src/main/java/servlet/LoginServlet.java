package servlet;

import dao.UserDao;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private final UserDao userDao = new UserDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            User user = userDao.login(email, password);

            if (user == null) {
                request.getSession().setAttribute("flashError", "Invalid email/password or suspended account.");
                response.sendRedirect(request.getContextPath() + "/HomeServlet");
                return;
            }

            HttpSession session = request.getSession();

            // Sessions expire after 30 minutes of inactivity.
            session.setMaxInactiveInterval(30 * 60);

            session.setAttribute("userId", user.getUserId());
            session.setAttribute("name", user.getFirstName());
            session.setAttribute("role", user.getRole());

            switch (user.getRole()) {
                case "STUDENT":
                    response.sendRedirect(request.getContextPath() + "/StudentDashboardServlet");
                    break;
                case "STAFF":
                    response.sendRedirect(request.getContextPath() + "/StaffDashboardServlet");
                    break;
                case "ADMIN":
                    response.sendRedirect(request.getContextPath() + "/AdminDashboardServlet");
                    break;
                default:
                    session.setAttribute("flashError", "Your account role could not be determined.");
                    response.sendRedirect(request.getContextPath() + "/HomeServlet");
                    break;
            }
        } catch (Exception e) {
            throw new ServletException("Unable to process login.", e);
        }
    }
}
