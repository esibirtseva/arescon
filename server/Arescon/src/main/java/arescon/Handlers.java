package arescon;

import io.undertow.security.api.SecurityContext;
import io.undertow.security.idm.Account;
import io.undertow.server.HttpHandler;
import io.undertow.server.HttpServerExchange;
import io.undertow.util.Headers;
import io.undertow.util.StatusCodes;
import net.avkorneenkov.undertow.CommonHandlers;

import java.io.StringWriter;

public class Handlers {

    private Util util;

    public Handlers( Util util ) {
        this.util = util;
    }

    public HttpHandler odn( String file ) {
        final HttpHandler handler = CommonHandlers.templatedPage(file,
                new CommonHandlers.StringWriterHandler() {
                    @Override
                    public void execute(StringWriter writer, HttpServerExchange exchange) {
                        util.getUserInfo(writer, exchange);
                    }
                },
                new CommonHandlers.StringWriterHandler() {
                    @Override
                    public void execute(StringWriter writer, HttpServerExchange exchange) {
                        util.getDevices(0, writer, exchange);
                    }
                },
                new CommonHandlers.StringWriterHandler() {
                    @Override
                    public void execute(StringWriter writer, HttpServerExchange exchange) {
                        util.getDevices(1, writer, exchange);
                    }
                },
                new CommonHandlers.StringWriterHandler() {
                    @Override
                    public void execute(StringWriter writer, HttpServerExchange exchange) {
                        util.getDevices(2, writer, exchange);
                    }
                },
                new CommonHandlers.StringWriterHandler() {
                    @Override
                    public void execute(StringWriter writer, HttpServerExchange exchange) {
                        util.getDevices(3, writer, exchange);
                    }
                }
        );

        return handler;
    }

    public HttpHandler index( String file ) {
        final HttpHandler handler = CommonHandlers.templatedPage(file,
                new CommonHandlers.StringWriterHandler() {
                    @Override
                    public void execute(StringWriter writer, HttpServerExchange exchange) {
                        util.getNews(0, writer, exchange);
                    }
                },
                new CommonHandlers.StringWriterHandler() {
                    @Override
                    public void execute(StringWriter writer, HttpServerExchange exchange) {
                        util.getNews(2, writer, exchange);
                    }
                }
        );

        return handler;
    }

    public HttpHandler dreports( String file ) {
        final HttpHandler handler = CommonHandlers.templatedPage(file

        );

        return handler;
    }

    public HttpHandler dispatcher( String file ) {
        final HttpHandler handler = CommonHandlers.templatedPage(file,
                new CommonHandlers.StringWriterHandler() {
                    @Override
                    public void execute(StringWriter writer, HttpServerExchange exchange) {
                        util.getDispatcherInfo(writer, exchange);
                    }
                },
                new CommonHandlers.StringWriterHandler() {
                    @Override
                    public void execute(StringWriter writer, HttpServerExchange exchange) {
                        util.getDispatcherTree(writer, exchange);
                    }
                }
        );

        return handler;
    }

    public HttpHandler user( String file ) {
        final HttpHandler handler = CommonHandlers.templatedPage(file,
                new CommonHandlers.StringWriterHandler() {
                    @Override
                    public void execute(StringWriter writer, HttpServerExchange exchange) {
                        util.getUserInfo(writer, exchange);
                    }
                },
                new CommonHandlers.StringWriterHandler() {
                    @Override
                    public void execute(StringWriter writer, HttpServerExchange exchange) {
                        util.getDevices(0, writer, exchange);
                    }
                },
                new CommonHandlers.StringWriterHandler() {
                    @Override
                    public void execute(StringWriter writer, HttpServerExchange exchange) {
                        util.getDevices(1, writer, exchange);
                    }
                },
                new CommonHandlers.StringWriterHandler() {
                    @Override
                    public void execute(StringWriter writer, HttpServerExchange exchange) {
                        util.getDevices(2, writer, exchange);
                    }
                },
                new CommonHandlers.StringWriterHandler() {
                    @Override
                    public void execute(StringWriter writer, HttpServerExchange exchange) {
                        util.getDevices(3, writer, exchange);
                    }
                },
                new CommonHandlers.StringWriterHandler() {
                    @Override
                    public void execute(StringWriter writer, HttpServerExchange exchange) {
                        util.getDeviceInfo(writer, exchange);
                    }
                }
        );

        return handler;
    }

//    public HttpHandler dashboard( String file, final String error ) {
//        final HttpHandler handler = CommonHandlers.templatedPage(file,
//                new CommonHandlers.StringWriterHandler() {
//                    @Override
//                    public void execute(StringWriter writer, HttpServerExchange exchange) {
//                        //util.getMenuProfile(writer, exchange);
//                    }
//                },
//                new CommonHandlers.StringWriterHandler() {
//                    @Override
//                    public void execute(StringWriter writer, HttpServerExchange exchange) {
//                        util.getMenu(writer, exchange);
//                    }
//                },
//                new CommonHandlers.StringWriterHandler() {
//                    @Override
//                    public void execute(StringWriter writer, HttpServerExchange exchange) {
//                        util.getPageName("Спортсмены", writer);
//                    }
//                },
//                new CommonHandlers.StringWriterHandler() {
//                    @Override
//                    public void execute(StringWriter writer, HttpServerExchange exchange) {
//                        util.getInviteForm(writer, exchange, error);
//                    }
//                },
//                new CommonHandlers.StringWriterHandler() {
//                    @Override
//                    public void execute(StringWriter writer, HttpServerExchange exchange) {
//                        util.getSportsmen(writer, exchange);
//                    }
//                });
//
//        return new HttpHandler() {
//            @Override
//            public void handleRequest(HttpServerExchange exchange) throws Exception {
//                SecurityContext securityContext = exchange.getSecurityContext();
//                if (securityContext == null) return;
//                Account account = securityContext.getAuthenticatedAccount();
//                if (account == null) return;
//                String role = account.getRoles().iterator().next();
//                if (role.equals("adm") || role.equals("trn")) {
//                    handler.handleRequest(exchange);
//                } else if (role.equals("spt")) {
//                    redirect(exchange, "/measures");
//                } else {
//                    redirect(exchange, "/loginerror");
//                }
//            }
//        };
//    }

    private static void redirect( HttpServerExchange exchange, String path ) {
        exchange.getResponseHeaders().put(Headers.LOCATION, path);
        exchange.setResponseCode(StatusCodes.TEMPORARY_REDIRECT);
    }
}
