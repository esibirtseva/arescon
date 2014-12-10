package net.avkorneenkov.undertow;

import io.undertow.security.api.AuthenticationMechanism;
import io.undertow.security.api.AuthenticationMode;
import io.undertow.security.handlers.AuthenticationCallHandler;
import io.undertow.security.handlers.AuthenticationConstraintHandler;
import io.undertow.security.handlers.AuthenticationMechanismsHandler;
import io.undertow.security.handlers.SecurityInitialHandler;
import io.undertow.security.idm.IdentityManager;
import io.undertow.security.impl.BasicAuthenticationMechanism;
import io.undertow.server.HttpHandler;
import io.undertow.server.HttpServerExchange;
import io.undertow.server.handlers.resource.FileResourceManager;
import io.undertow.server.handlers.resource.ResourceHandler;
import io.undertow.server.session.SessionAttachmentHandler;
import io.undertow.server.session.SessionCookieConfig;
import io.undertow.server.session.SessionManager;
import io.undertow.util.Headers;
import net.avkorneenkov.IOUtil;

import java.io.File;
import java.io.IOException;
import java.io.StringWriter;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

public class CommonHandlers {

    public static HttpHandler authHandler( final HttpHandler toWrap, final IdentityManager identityManager,
                                           final String loginPage, final String errorPage, final String name,
                                           SessionManager sessionManager )
    {
        HttpHandler handler = toWrap;
        handler = new AuthenticationCallHandler(handler);
        handler = new AuthenticationConstraintHandler(handler);
        final List<AuthenticationMechanism> mechanisms = new ArrayList<>(1);
        if (loginPage != null && errorPage != null) {
            mechanisms.add(new FormAuth(name, loginPage, errorPage, null));
        } else {
            mechanisms.add(new BasicAuthenticationMechanism(name));
        }
        handler = new AuthenticationMechanismsHandler(handler, mechanisms);
        handler = new SecurityInitialHandler(AuthenticationMode.PRO_ACTIVE, identityManager, handler);
        handler = new SessionAttachmentHandler(handler, sessionManager, new SessionCookieConfig().setCookieName("session"));
        return handler;
    }

    @FunctionalInterface
    public interface StringWriterHandler { void execute( StringWriter writer, HttpServerExchange exchange ); }

    public static HttpHandler templatedPage( final String page, final StringWriterHandler... insertions ) {
        final String splitter = "%dynamic_content%";
        final String[] parts = page.split(splitter);

        return new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                StringWriter response = new StringWriter();
                response.append(parts[0]);
                try { System.out.println(exchange.getRequestCookies().get("session").getValue()); }
                catch (Throwable ignored) { }

                for (int i = 1; i < parts.length; ++i) {
                    if (i <= insertions.length) {
                        insertions[i - 1].execute(response, exchange);
                    } else {
                        response.append(splitter);
                    }
                    response.append(parts[i]);
                }

                exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/html");
                exchange.getResponseSender().send(response.toString());
            }
        };
    }

    public static HttpHandler resourcedHandler(final HttpHandler toWrap, final File resources) {
        final FileResourceManager resourceManager = new FileResourceManager(resources, 10);
        final ResourceHandler resourceHandler = new ResourceHandler(resourceManager);
        return new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                if (exchange.getRequestPath().contains(".")) {
                    exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
                    resourceHandler.handleRequest(exchange);
                } else {
                    exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/html");
                    toWrap.handleRequest(exchange);
                }
            }
        };
    }

    public static HttpHandler staticHandler( final String page ) {
        return new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/html");
                exchange.getResponseSender().send(page);
            }
        };
    }

    public static HttpHandler staticHandler( final Path page ) throws IOException {
        return staticHandler(IOUtil.readFile(page));
    }

}
