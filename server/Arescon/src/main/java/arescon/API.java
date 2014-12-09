package arescon;

import io.undertow.security.api.SecurityContext;
import io.undertow.security.idm.Account;
import io.undertow.security.idm.PasswordCredential;
import io.undertow.server.HttpServerExchange;
import io.undertow.server.handlers.Cookie;
import io.undertow.server.handlers.CookieImpl;
import io.undertow.server.handlers.form.FormData;
import io.undertow.util.Headers;
import io.undertow.util.Methods;
import io.undertow.util.StatusCodes;
import net.avkorneenkov.NetUtil;
import net.avkorneenkov.SQLUtil;
import net.avkorneenkov.undertow.DatabaseIdentityManager;
import net.avkorneenkov.undertow.UndertowUtil;
import org.apache.commons.codec.digest.DigestUtils;

import java.io.IOException;
import java.security.SecureRandom;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Random;

public class API {

    private DatabaseIdentityManager identityManager;
    private Random random;
    private Util util;

    public API( DatabaseIdentityManager identityManager, Util util ) {
        this.identityManager = identityManager;
        this.util = util;
        this.random = new SecureRandom();
    }

    public void profileUpdate( HttpServerExchange exchange ) throws IOException, SQLException {

        if (!exchange.getRequestMethod().equals(Methods.POST)) {
            redirect(exchange, "/profile");
            return;
        }
        SecurityContext securityContext = exchange.getSecurityContext();
        if (securityContext == null) {
            redirect(exchange, "/profile");
            return;
        }
        Account account = securityContext.getAuthenticatedAccount();
        if (account == null) {
            redirect(exchange, "/profile");
            return;
        }
        String login = account.getPrincipal().getName();
        FormData postData = UndertowUtil.parsePostData(exchange);
        if (postData == null) {
            redirect(exchange, "/profile");
            return;
        }

        FormData.FormValue password = postData.getFirst("j_password");
        FormData.FormValue repeat = postData.getFirst("j_repeat");
        FormData.FormValue current = postData.getFirst("j_current");

        if (password == null || repeat == null || current == null ||
                password.getValue().isEmpty() || repeat.getValue().isEmpty() ||
                current.getValue().isEmpty())
        {
            redirect(exchange, "/profileerror/0");
            return;
        }

        if (!password.getValue().equals(repeat.getValue())) {
            redirect(exchange, "/profileerror/2");
            return;
        }

        PasswordCredential passwordCredential = new PasswordCredential(DigestUtils.md5Hex(current.getValue()).toCharArray());
        if (identityManager.verify(login, passwordCredential) == null) {
            redirect(exchange, "/profileerror/1");
            return;
        }

        try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement(
                "UPDATE users SET md5_pass = ? WHERE login = ? LIMIT 1"))
        {
            statement.setString(1, DigestUtils.md5Hex(password.getValue()));
            statement.setString(2, login);
            statement.execute();
        }

        identityManager.logout(login);
        redirect(exchange, "/sportsmen");
    }

    public void addPlace( HttpServerExchange exchange ) throws IOException, SQLException {

        final String ADD_ERROR = "/places";

        String role;

        try {
            role = exchange.getSecurityContext().getAuthenticatedAccount().getRoles().iterator().next();
        } catch (Throwable e) {
            redirect(exchange, ADD_ERROR);
            return;
        }

        if (!role.equals("adm") || !exchange.getRequestMethod().equals(Methods.POST)) {
            redirect(exchange, ADD_ERROR);
            return;
        }

        FormData postData = UndertowUtil.parsePostData(exchange);
        if (postData == null) {
            redirect(exchange, ADD_ERROR);
            return;
        }

        FormData.FormValue address = postData.getFirst("j_address");
        FormData.FormValue name = postData.getFirst("j_name");

        if (address == null || name == null) {
            redirect(exchange, ADD_ERROR);
            return;
        }

        try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement(
                "INSERT INTO places (name, address) VALUES (?, ?)"))
        {
            statement.setString(1, name.getValue());
            statement.setString(2, address.getValue());
            statement.execute();
        }

        redirect(exchange, "/places");
    }

    public void inviteSportsman( HttpServerExchange exchange ) throws IOException, SQLException {

        final String INVITE_ERROR = "/sportsmen";
        final String MAIL_FROM = "noreply@analytica.ru";
        final String MAIL_SUBJECT = "Создана учетная запись";

        String role;

        try {
            role = exchange.getSecurityContext().getAuthenticatedAccount().getRoles().iterator().next();
        } catch (Throwable e) {
            redirect(exchange, INVITE_ERROR);
            return;
        }

        if (!role.equals("adm") && !role.equals("trn")) {
            redirect(exchange, INVITE_ERROR);
            return;
        }

        if (!exchange.getRequestMethod().equals(Methods.POST)) {
            redirect(exchange, "/sportsmenfill");
            return;
        }
        FormData postData = UndertowUtil.parsePostData(exchange);
        if (postData == null) {
            redirect(exchange, "/sportsmenfill");
            return;
        }
        FormData.FormValue email = postData.getFirst("j_email");
        FormData.FormValue name = postData.getFirst("j_name");
        FormData.FormValue insport = postData.getFirst("j_insport");
        FormData.FormValue gender = postData.getFirst("j_gender");
        FormData.FormValue category = postData.getFirst("j_category");

        if (email == null || name == null || insport == null || gender == null || category == null ||
                email.getValue().isEmpty() || name.getValue().isEmpty() ||
                insport.getValue().isEmpty() || gender.getValue().isEmpty() || category.getValue().isEmpty())
        {
            redirect(exchange, "/sportsmenfill");
            return;
        }
        String parentName;
        int parentID = 0;
        int disciplineID = 1;
        try {
            parentName = exchange.getSecurityContext().getAuthenticatedAccount().getPrincipal().getName();
        } catch ( NullPointerException e ) {
            redirect(exchange, INVITE_ERROR);
            return;
        }
        try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement("SELECT id, id_discipline FROM users WHERE login = ? LIMIT 1")) {
            statement.setString(1, parentName);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    parentID = result.getInt("id");
                    disciplineID = result.getInt("id_discipline");
                }
            }
        }
        if (parentID == 0) {
            redirect(exchange, INVITE_ERROR);
            return;
        }
        String password = DigestUtils.md5Hex(Long.toString(random.nextLong())).substring(0, 10);
        String login = email.getValue();
        if (!identityManager.userExists(login)) {
            try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement(
                    "INSERT INTO users (login, md5_pass, fio, type, id_parent, id_discipline) VALUES (?, ?, ?, ?, ?, ?)"))
            {
                statement.setString(1, login);
                statement.setString(2, password);
                statement.setString(3, name.getValue());
                statement.setString(4, "spt");
                statement.setInt(5, parentID);
                statement.setInt(6, disciplineID);
                statement.execute();
                int userID = SQLUtil.getLastInsertID();
                try (PreparedStatement statement2 = SQLUtil.getMySQLConnection().prepareStatement(
                        "INSERT INTO sportsman (id_user, id_discipline, fio, gender, insport, id_sportsman_categories) VALUES (?, ?, ?, ?, ?, ?)"))
                {
                    statement2.setInt(1, userID);
                    statement2.setInt(2, disciplineID);
                    statement2.setString(3, name.getValue());
                    statement2.setString(4, gender.getValue());
                    statement2.setString(5, insport.getValue());
                    statement2.setString(6, category.getValue());
                    statement2.execute();
                }
            }

            NetUtil.mail(login, MAIL_FROM, MAIL_SUBJECT, util.getInviteMail(login, password));

            redirect(exchange, "/sportsmen");
        } else {
            redirect(exchange, "/sportsmenerror");
        }
    }

    public void approve( HttpServerExchange exchange ) {
        SecurityContext securityContext = exchange.getSecurityContext();
        if (securityContext == null) return;
        Account account = securityContext.getAuthenticatedAccount();
        if (account == null) return;
        String role = account.getRoles().iterator().next();
        if (role.equals("adm")) {
            int id = 0;
            String relPath = exchange.getRelativePath();
            if (relPath != null) {
                try { id = Integer.parseInt(relPath.substring(1)); }
                catch (Throwable ignored) { }
            }
            if (id != 0) {
                try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement(
                        "UPDATE users SET type = \'trn\' WHERE id = ? LIMIT 1"))
                {
                    statement.setInt(1, id);
                    statement.execute();
                    redirect(exchange, "/users");
                } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }

    public void logout( HttpServerExchange exchange ) {
        final Cookie userCookie = exchange.getRequestCookies().get("user");
        if (userCookie == null) return;
        identityManager.logout(userCookie.getValue());
        exchange.getResponseCookies().put("user", new CookieImpl("user", ""));
        exchange.getResponseCookies().put("token", new CookieImpl("token", ""));
        redirect(exchange, "/sportsmen");
    }

    public void register( HttpServerExchange exchange ) throws IOException, SQLException {
        if (!exchange.getRequestMethod().equals(Methods.POST)) {
            redirect(exchange, "/signupfill");
            return;
        }
        FormData postData = UndertowUtil.parsePostData(exchange);
        if (postData == null) {
            redirect(exchange, "/signupfill");
            return;
        }
        FormData.FormValue password = postData.getFirst("j_password");
        FormData.FormValue email = postData.getFirst("j_email");
        FormData.FormValue fname = postData.getFirst("j_fname");
        FormData.FormValue sname = postData.getFirst("j_sname");
        FormData.FormValue discipline = postData.getFirst("j_discipline");
        if (password == null || email == null || fname == null || sname == null || discipline == null ||
                password.getValue().isEmpty() || email.getValue().isEmpty() ||
                fname.getValue().isEmpty() || sname.getValue().isEmpty() || discipline.getValue().isEmpty())
        {
            redirect(exchange, "/signupfill");
            return;
        }
        try {
            String login = email.getValue();
            if (!identityManager.userExists(login)) {
                String name = sname.getValue() + " " + fname.getValue();
                String pass = password.getValue();
                int disciplineID = 1;
                try {
                    disciplineID = Integer.parseInt(discipline.getValue());
                } catch (Throwable ignored) { }

                try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement(
                        "INSERT INTO users (login, md5_pass, fio, id_discipline) VALUES (?, ?, ?, ?)"))
                {
                    statement.setString(1, login);
                    System.out.println(DigestUtils.md5Hex(pass));
                    statement.setString(2, pass);
                    statement.setString(3, name);
                    statement.setInt(4, disciplineID);
                    statement.execute();
                }

                redirect(exchange, "/sportsmen");
            } else {
                redirect(exchange, "/signuperror");
            }
        } catch (SQLException e) { e.printStackTrace(); }
    }

    public void deletePlace( HttpServerExchange exchange ) throws IOException, SQLException {

        final String DELETE_ERROR = "/"; // TODO: add error page
        String role;
        try {
            role = exchange.getSecurityContext().getAuthenticatedAccount().getRoles().iterator().next();
        } catch (Throwable e) {
            redirect(exchange, DELETE_ERROR);
            return;
        }
        if (!role.equals("adm")) {
            redirect(exchange, DELETE_ERROR);
            return;
        }

        int id = 0;
        String relPath = exchange.getRelativePath();
        if (relPath != null) {
            try { id = Integer.parseInt(relPath.substring(1)); }
            catch (NumberFormatException ignored) { }
        }

        if (id > 0) {
            try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement("DELETE FROM places WHERE id = ?")) {
                statement.setInt(1, id);
                statement.execute();
            }
        }

        redirect(exchange, "/places");
    }

    public void deleteUser( HttpServerExchange exchange ) throws IOException, SQLException {

        final String DELETE_ERROR = "/";

        String role;
        try {
            role = exchange.getSecurityContext().getAuthenticatedAccount().getRoles().iterator().next();
        } catch (Throwable e) {
            redirect(exchange, DELETE_ERROR);
            return;
        }
        if (!role.equals("adm")) {
            redirect(exchange, DELETE_ERROR);
            return;
        }

        int id = 0;
        String relPath = exchange.getRelativePath();
        if (relPath != null) {
            try { id = Integer.parseInt(relPath.substring(1)); }
            catch (Throwable ignored) { }
        }

        if (id > 0) {
            try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement("DELETE FROM users WHERE id = ?")) {
                statement.setInt(1, id);
                statement.execute();
                try (PreparedStatement statement2 = SQLUtil.getMySQLConnection().prepareStatement("DELETE FROM sportsman WHERE id_user = ?")) {
                    statement2.setInt(1, id);
                    statement2.execute();
                }
            }
        }

        redirect(exchange, "/users");
    }

    private static void redirect( HttpServerExchange exchange, String path ) {
        exchange.getResponseHeaders().put(Headers.LOCATION, path);
        exchange.setResponseCode(StatusCodes.TEMPORARY_REDIRECT);
    }

}
