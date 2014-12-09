package net.avkorneenkov.undertow;

import io.undertow.security.api.AuthenticationMechanism;
import io.undertow.security.api.SecurityContext;
import io.undertow.security.idm.Account;
import io.undertow.security.idm.IdentityManager;
import io.undertow.security.idm.PasswordCredential;
import io.undertow.server.HttpServerExchange;
import io.undertow.server.handlers.Cookie;
import io.undertow.server.handlers.CookieImpl;
import io.undertow.server.handlers.form.FormData;
import io.undertow.server.handlers.form.FormDataParser;
import io.undertow.server.handlers.form.FormParserFactory;
import io.undertow.util.Headers;
import io.undertow.util.Methods;
import io.undertow.util.StatusCodes;
import org.apache.commons.codec.digest.DigestUtils;

import java.io.IOException;

import static io.undertow.UndertowMessages.MESSAGES;

public class FormAuth implements AuthenticationMechanism {

    public static interface CredMapper {
        String mapLogin( String login );
        String mapPass( String pass );
    }

    private CredMapper credMapper;

    FormParserFactory formParserFactory;
    String location;
    String loginPage;
    String errorPage;

    public FormAuth( String location, String loginPage, String errorPage, CredMapper credMapper ) {
        this.formParserFactory = FormParserFactory.builder().build();
        this.credMapper = credMapper;
        this.location = location;
        this.loginPage = loginPage;
        this.errorPage = errorPage;
    }

    private boolean checkCookies(HttpServerExchange exchange, SecurityContext securityContext) {
        final DatabaseIdentityManager identityManager = (DatabaseIdentityManager)securityContext.getIdentityManager();
        final Cookie userCookie = exchange.getRequestCookies().get("user");
        final Cookie passwordCookie = exchange.getRequestCookies().get("token");
        final Cookie sessionCookie = exchange.getRequestCookies().get("session");
        if (userCookie != null && passwordCookie != null) {
            Account account = identityManager.verify(userCookie.getValue(),
                    new PasswordCredential(passwordCookie.getValue().toCharArray()),
                    sessionCookie == null ? null : sessionCookie.getValue());
            if (account != null) {
                securityContext.authenticationComplete(account, "FormAuth", false);
                return true;
            }
        }
        return false;
    }

    @Override
    public AuthenticationMechanismOutcome authenticate(HttpServerExchange exchange, SecurityContext securityContext) {

        if (checkCookies(exchange, securityContext)) return AuthenticationMechanismOutcome.AUTHENTICATED;
        if (!exchange.getRequestMethod().equals(Methods.POST)) return AuthenticationMechanismOutcome.NOT_ATTEMPTED;
        FormDataParser parser = formParserFactory.createParser(exchange);
        if (parser == null) return AuthenticationMechanismOutcome.NOT_AUTHENTICATED;

        try {
            final FormData data = parser.parseBlocking();
            final FormData.FormValue jUsername = data.getFirst("j_username");
            final FormData.FormValue jPassword = data.getFirst("j_password");
            if (jUsername == null || jPassword == null) {
                return AuthenticationMechanismOutcome.NOT_AUTHENTICATED;
            }
            final String userName = jUsername.getValue();
            final String password = DigestUtils.md5Hex(jPassword.getValue());
            final AuthenticationMechanismOutcome outcome;
            PasswordCredential credential = new PasswordCredential(password.toCharArray());
            IdentityManager idm = securityContext.getIdentityManager();
            Account account = idm.verify(userName, credential);
            if (account != null) {
                securityContext.authenticationComplete(account, "FormAuth", false);
                Cookie userCookie = new CookieImpl("user", userName);
                userCookie.setHttpOnly(true);
                exchange.getResponseCookies().put("user", userCookie);
                Cookie tokenCookie = new CookieImpl("token", password);
                tokenCookie.setHttpOnly(true);
                exchange.getResponseCookies().put("token", tokenCookie);
                outcome = AuthenticationMechanismOutcome.AUTHENTICATED;
            } else {
                securityContext.authenticationFailed(MESSAGES.authenticationFailed(userName), "FormAuth");
                exchange.getResponseCookies().put("error", new CookieImpl("error", "1"));
                outcome = AuthenticationMechanismOutcome.NOT_AUTHENTICATED;
            }
            return outcome;
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public ChallengeResult sendChallenge(HttpServerExchange exchange, SecurityContext securityContext) {
        Cookie error = exchange.getResponseCookies().get("error");
        if (error != null && error.getValue().equals("1")) {
            sendRedirect(exchange, errorPage);
            exchange.getResponseCookies().put("error", new CookieImpl("error", "0"));
        } else {
            sendRedirect(exchange, loginPage);
        }
        return new ChallengeResult(true, StatusCodes.TEMPORARY_REDIRECT);
    }

    static void sendRedirect(final HttpServerExchange exchange, final String location) {
        exchange.getResponseHeaders().put(Headers.LOCATION, location);
    }
}
