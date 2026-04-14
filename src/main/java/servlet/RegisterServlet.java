package servlet;

import dao.UserDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    private final UserDao userDao = new UserDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String fullName = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (fullName == null || fullName.trim().isEmpty()) {
            request.getSession().setAttribute("flashError", "Full name is required.");
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.getSession().setAttribute("flashError", "Passwords do not match.");
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
            return;
        }

        String[] nameParts = fullName.trim().split("\\s+", 2);
        String firstName = nameParts[0];
        String lastName = nameParts.length > 1 ? nameParts[1] : "";

        try {
            if (userDao.emailExists(email)) {
                request.getSession().setAttribute("flashError", "An account with that email already exists.");
                response.sendRedirect(request.getContextPath() + "/HomeServlet");
                return;
            }

            userDao.registerStudent(firstName, lastName, email, password, "Undeclared", "Freshman");
            request.getSession().setAttribute("flashMessage", "Registration successful. Please log in.");
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
        } catch (Exception e) {
            throw new ServletException("Unable to register account.", e);
        }
    }
}