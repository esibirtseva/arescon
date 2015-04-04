package arescon;

import io.undertow.Undertow;
import io.undertow.server.HttpHandler;
import io.undertow.server.HttpServerExchange;
import io.undertow.server.session.InMemorySessionManager;
import io.undertow.server.session.SessionManager;
import io.undertow.util.Headers;
import io.undertow.util.StatusCodes;
import net.avkorneenkov.IOUtil;
import net.avkorneenkov.NetUtil;
import net.avkorneenkov.freemarker.TemplatesWorker;
import net.avkorneenkov.undertow.CommonHandlers;
import net.avkorneenkov.undertow.DatabaseIdentityManager;
import net.avkorneenkov.undertow.UndertowUtil;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Consumer;

public class Main {

    private static String CONFIG_PATH = "config.txt";

    private static int PORT = 80;
    private static String HOSTNAME = "localhost";
    private static String RESOURCES_PATH = "data" + File.separator;
    private static String PAGES_PATH = "pages" + File.separator;
    private static String TEMPLATES_PATH = "templates" + File.separator;
    private static int TREND_DEGREES = 2;

    private static int DB_PORT = 3306;
    private static String DB_HOSTNAME = "127.0.0.1";
    private static String DB_USERNAME = "root";
    private static String DB_PASSWORD = "1234";
    private static String DB_DATABASE = "strelok";

    private static final long PING_PERIOD = 300000;

    private static SessionManager sessionManager = new InMemorySessionManager("smgr");

    private static API api;
    private static Util util;
    private static Handlers handlers;
    private static DatabaseIdentityManager identityManager;

    static Undertow server = null;

    private static enum PAGES { index, user, dispatcher, login, registration, dreports, odn, ureports, uprofile, uodn, notifications, user_rates, user_payments }

    private static void readConfig( String filename, boolean local ) throws IOException {
        Map<String, String> config = new HashMap<>(10);
        try (BufferedReader reader = new BufferedReader(new FileReader(filename))) {
            for (String line; (line = reader.readLine()) != null; ) {
                try {
                    String[] parts = line.split(":");
                    config.put(parts[0].trim(), parts[1].trim());
                } catch (Throwable ignored) { }
            }
        }
        try { PORT = Integer.parseInt(config.get("port")); }
        catch (Throwable ignored) { }
        try { if (!local) HOSTNAME = config.get("hostname"); }
        catch (Throwable ignored) { }
        try { RESOURCES_PATH = config.get("resources"); }
        catch (Throwable ignored) { }
        try { PAGES_PATH = config.get("pages"); }
        catch (Throwable ignored) { }
        try { TEMPLATES_PATH = config.get("templates"); }
        catch (Throwable ignored) { }
        try { DB_PORT = Integer.parseInt(config.get("db_port")); }
        catch (Throwable ignored) { }
        try { DB_HOSTNAME = config.get("db_hostname"); }
        catch (Throwable ignored) { }
        try { DB_USERNAME = config.get("db_username"); }
        catch (Throwable ignored) { }
        try { DB_PASSWORD = config.get("db_password"); }
        catch (Throwable ignored) { }
        try { DB_DATABASE = config.get("db_database"); }
        catch (Throwable ignored) { }
    }

    public static void main( String[] args ) {
        launch(!(args.length > 0 && args[0].equalsIgnoreCase("remote")));
    }

    private static void launch( final boolean local ) {
        try { readConfig(CONFIG_PATH, local); }
        catch (IOException e) { e.printStackTrace(); }

//        try {
//            SQLUtil.getMySQLConnection(DB_USERNAME, DB_PASSWORD, DB_HOSTNAME, DB_DATABASE, DB_PORT);
//            SQLUtil.addPing("USE " + DB_DATABASE, PING_PERIOD);
//        } catch (SQLException | ClassNotFoundException e) {
//            e.printStackTrace();
//            return;
//        }

        final File resources = new File(RESOURCES_PATH);

        try {
            util = new Util(new TemplatesWorker(new File(TEMPLATES_PATH)));
            handlers = new Handlers(util);
        } catch (IOException | SQLException e) {
            e.printStackTrace();
            return;
        }

        identityManager = new DatabaseIdentityManager("users", "login", "ina", "md5_pass", "type");
        api = new API(identityManager, util, TREND_DEGREES);

        final Map<String, HttpHandler> paths = new HashMap<>();

        try {
            Files.walk(Paths.get(new File(PAGES_PATH).getAbsolutePath()), 1).forEach(new Consumer<Path>() {
                @Override
                public void accept(Path path) {
                    String filename = path.getFileName().toString();
                    if (!filename.contains(".")) return;
                    filename = filename.substring(0, filename.indexOf('.'));
                    String file;
                    try { file = IOUtil.readFile(path); }
                    catch (IOException e) { return; }
                    PAGES page;
                    try { page = Enum.valueOf(PAGES.class, filename); }
                    catch (IllegalArgumentException e) {
                        paths.put(filename, CommonHandlers.staticHandler(file));
                        return;
                    }
                    switch (page) {
                        case index:
                            paths.put("index", CommonHandlers.resourcedHandler(handlers.index(file), resources));
                            break;
                        case login:
                            paths.put("login", CommonHandlers.staticHandler(file.replace("%static_content%", "")));
                            paths.put("loginerror", CommonHandlers.staticHandler(file.replace("%static_content%", "Неверное имя пользователя или пароль")));
                            break;
                        case user:
                            paths.put("user", handlers.user(file));
                            break;
                        case dispatcher:
                            paths.put("dispatcher", handlers.dispatcher(file));
                            break;
                        case registration:
                            paths.put("registration", CommonHandlers.staticHandler(file.replace("%static_content%", "")));
                            paths.put("registrationerror", CommonHandlers.staticHandler(file.replace("%static_content%", "Введенный адрес e-mail уже занят")));
                            break;
                        case dreports:
                            paths.put("dreports", handlers.dreports(file));
                            break;
                        case odn:
                            paths.put("user/odn", handlers.odn(file));
                            break;
                        case ureports:
                            paths.put("ureports", handlers.ureports(file));
                            break;
                        case uprofile:
                            paths.put("uprofile", handlers.uprofile(file));
                            break;
                        case uodn:
                            paths.put("uodn", handlers.uodn(file));
                            break;
                        case notifications:
                            paths.put("notifications", handlers.notifications(file));
                            break;
                        case user_rates:
                            paths.put("rates", handlers.rates(file));
                            break;
                        case user_payments:
                            paths.put("payments", handlers.payments(file));
                            break;
                    }
                }
            });
        } catch (IOException e) {
            e.printStackTrace();
            return;
        }

        paths.put("notifications/create", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.notificationsCreate(exchange);
            }
        });
        paths.put("notifications/read", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.notificationsRead(exchange);
            }
        });
        paths.put("notifications/update", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.notificationsUpdate(exchange);
            }
        });
        paths.put("notifications/delete", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.notificationsDelete(exchange);
            }
        });

        paths.put("device/rates", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.deviceRates(exchange);
            }
        });
        paths.put("device/payments", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.devicePayments(exchange);
            }
        });
        paths.put("type/rates", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.typeRates(exchange);
            }
        });
        paths.put("type/payments", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.typePayments(exchange);
            }
        });

        paths.put("type/deviation", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.typeDeviation(exchange);
            }
        });
        paths.put("service/deviation", new HttpHandler() {
            @Override
            public void handleRequest( HttpServerExchange exchange ) throws Exception {
                exchange.getResponseSender().send("not implemented");
            }
        });
        paths.put("device/deviation", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.deviceDeviation(exchange);
            }
        });
        paths.put("setDeviationName", new HttpHandler() {
            @Override
            public void handleRequest( HttpServerExchange exchange ) throws Exception {
                api.deviationRecordName(exchange);
            }
        });

        paths.put("type/percentage", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.typePercentage(exchange, false);
            }
        });
        paths.put("service/percentage", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.servicePercentage(exchange, false);
            }
        });
        paths.put("device/percentage", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.devicePercentage(exchange, false);
            }
        });
        paths.put("flat/percentage", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.housePercentage(exchange, false);
            }
        });
        paths.put("house/percentage", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.housePercentage(exchange, false);
            }
        });
        paths.put("tszh/percentage", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.housePercentage(exchange, false);
            }
        });
        paths.put("uk/percentage", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.housePercentage(exchange, false);
            }
        });

        paths.put("type/percentage/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.typePercentage(exchange, true);
            }
        });
        paths.put("service/percentage/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.servicePercentage(exchange, true);
            }
        });
        paths.put("device/percentage/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.devicePercentage(exchange, true);
            }
        });
        paths.put("flat/percentage/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.housePercentage(exchange, true);
            }
        });
        paths.put("house/percentage/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.housePercentage(exchange, true);
            }
        });
        paths.put("tszh/percentage/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.housePercentage(exchange, true);
            }
        });
        paths.put("uk/percentage/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.housePercentage(exchange, true);
            }
        });

        paths.put("type/profile/money", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.typeProfile(exchange, 20, "/type/profile/money", false);
            }
        });
        paths.put("service/profile/money", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.serviceProfile(exchange, 20, "/service/profile/money", false);
            }
        });
        paths.put("device/profile/money", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.deviceProfile(exchange, 20, "/device/profile/money", false);
            }
        });
        paths.put("flat/profile/money", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseProfile(exchange, 20, "/flat/profile/money", false);
            }
        });
        paths.put("house/profile/money", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseProfile(exchange, 60, "/house/profile/money", false);
            }
        });
        paths.put("tszh/profile/money", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseProfile(exchange, 120, "/tszh/profile/money", false);
            }
        });
        paths.put("uk/profile/money", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseProfile(exchange, 240, "/uk/profile/money", false);
            }
        });

        paths.put("type/profile/money/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.typeProfile(exchange, 20, "/type/profile/money/trend", true);
            }
        });
        paths.put("service/profile/money/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.serviceProfile(exchange, 20, "/service/profile/money/trend", true);
            }
        });
        paths.put("device/profile/money/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.deviceProfile(exchange, 20, "/device/profile/money/trend", true);
            }
        });
        paths.put("flat/profile/money/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseProfile(exchange, 20, "/flat/profile/money/trend", true);
            }
        });
        paths.put("house/profile/money/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseProfile(exchange, 60, "/house/profile/money/trend", true);
            }
        });
        paths.put("tszh/profile/money/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseProfile(exchange, 120, "/tszh/profile/money/trend", true);
            }
        });
        paths.put("uk/profile/money/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseProfile(exchange, 240, "/uk/profile/money/trend", true);
            }
        });

        paths.put("type/profile/values/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.typeProfile(exchange, 1, "/type/profile/values/trend", true);
            }
        });
        paths.put("service/profile/values/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.serviceProfile(exchange, 1, "/service/profile/values/trend", true);
            }
        });
        paths.put("device/profile/values/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.deviceProfile(exchange, 1, "/device/profile/values/trend", true);
            }
        });
        paths.put("flat/profile/values/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseProfile(exchange, 1, "/flat/profile/values/trend", true);
            }
        });
        paths.put("house/profile/values/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseProfile(exchange, 3, "/house/profile/values/trend", true);
            }
        });
        paths.put("tszh/profile/values/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseProfile(exchange, 6, "/tszh/profile/values/trend", true);
            }
        });
        paths.put("uk/profile/values/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseProfile(exchange, 12, "/uk/profile/values/trend", true);
            }
        });

        paths.put("type/profile/values", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.typeProfile(exchange, 1, "/type/profile/values", false);
            }
        });
        paths.put("service/profile/values", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.serviceProfile(exchange, 1, "/service/profile/values", false);
            }
        });
        paths.put("device/profile/values", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.deviceProfile(exchange, 1, "/device/profile/values", false);
            }
        });
        paths.put("flat/profile/values", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseProfile(exchange, 1, "/flat/profile/values", false);
            }
        });
        paths.put("house/profile/values", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseProfile(exchange, 3, "/house/profile/values", false);
            }
        });
        paths.put("tszh/profile/values", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseProfile(exchange, 6, "/tszh/profile/values", false);
            }
        });
        paths.put("uk/profile/values", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseProfile(exchange, 12, "/uk/profile/values", false);
            }
        });

        paths.put("device/money", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.deviceData(exchange, 20, false);
            }
        });
        paths.put("type/money", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.typeData(exchange, 20, false);
            }
        });
        paths.put("service/money", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.serviceData(exchange, 20, false);
            }
        });
        paths.put("flat/money", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseData(exchange, 20, false);
            }
        });
        paths.put("house/money", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseData(exchange, 60, false);
            }
        });
        paths.put("tszh/money", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseData(exchange, 120, false);
            }
        });
        paths.put("uk/money", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseData(exchange, 240, false);
            }
        });

        paths.put("device/money/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.deviceData(exchange, 20, true);
            }
        });
        paths.put("type/money/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.typeData(exchange, 20, true);
            }
        });
        paths.put("service/money/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.serviceData(exchange, 20, true);
            }
        });
        paths.put("flat/money/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseData(exchange, 20, true);
            }
        });
        paths.put("house/money/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseData(exchange, 60, true);
            }
        });
        paths.put("tszh/money/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseData(exchange, 120, true);
            }
        });
        paths.put("uk/money/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseData(exchange, 240, true);
            }
        });

        paths.put("device/values", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.deviceData(exchange, 1, false);
            }
        });
        paths.put("type/values", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.typeData(exchange, 1, false);
            }
        });
        paths.put("service/values", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.serviceData(exchange, 1, false);
            }
        });
        paths.put("flat/values", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseData(exchange, 1, false);
            }
        });
        paths.put("house/values", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseData(exchange, 3, false);
            }
        });
        paths.put("tszh/values", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseData(exchange, 6, false);
            }
        });
        paths.put("uk/values", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseData(exchange, 12, false);
            }
        });

        paths.put("device/values/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.deviceData(exchange, 1, true);
            }
        });
        paths.put("type/values/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.typeData(exchange, 1, true);
            }
        });
        paths.put("service/values/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.serviceData(exchange, 1, true);
            }
        });
        paths.put("flat/values/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseData(exchange, 1, true);
            }
        });
        paths.put("house/values/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseData(exchange, 3, true);
            }
        });
        paths.put("tszh/values/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseData(exchange, 6, true);
            }
        });
        paths.put("uk/values/trend", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.houseData(exchange, 12, true);
            }
        });

        paths.put("lastrequests", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.lastRequests(exchange);
            }
        });

        paths.put("deleteDevice", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.deleteDevice(exchange);
            }
        });
        paths.put("reboot", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                Data.reboot();
                launch(local);
                exchange.getResponseHeaders().put(Headers.LOCATION, "/");
                exchange.setResponseCode(StatusCodes.TEMPORARY_REDIRECT);
            }
        });

        paths.put("project11", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange httpServerExchange) throws Exception {
                NetUtil.mail("tombakprivate@gmail.com", "savdoshin@edu.hse.ru", "lalala", "1231");
            }
        });

        if (server != null) {
            server.stop();
            server = null;
        }

        server = Undertow.builder()
                .addHttpListener(PORT, HOSTNAME)
                .setHandler(UndertowUtil.buildPathHandler(paths))
                .build();

        server.start();
    }
}
