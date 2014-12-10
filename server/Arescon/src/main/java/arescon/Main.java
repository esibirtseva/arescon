package arescon;

import io.undertow.Undertow;
import io.undertow.server.HttpHandler;
import io.undertow.server.HttpServerExchange;
import io.undertow.server.session.InMemorySessionManager;
import io.undertow.server.session.SessionManager;
import net.avkorneenkov.IOUtil;
import net.avkorneenkov.SQLUtil;
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
import java.security.SecureRandom;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;
import java.util.function.Consumer;

public class Main {

    private static String CONFIG_PATH = "config.txt";

    private static int PORT = 80;
    private static String HOSTNAME = "localhost";
    private static String RESOURCES_PATH = "data" + File.separator;
    private static String PAGES_PATH = "pages" + File.separator;
    private static String TEMPLATES_PATH = "templates" + File.separator;

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

    private static enum PAGES { index, user, dispatcher, login, registration, dreports, odn }

    private static void readConfig( String filename ) throws IOException {
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
        try { HOSTNAME = config.get("hostname"); }
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

        try { readConfig(CONFIG_PATH); }
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
        api = new API(identityManager, util);

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
                            paths.put("odn", handlers.odn(file));
                            break;
                    }
                }
            });
        } catch (IOException e) {
            e.printStackTrace();
            return;
        }

        paths.put("device", new HttpHandler() {
            @Override
            public void handleRequest(HttpServerExchange exchange) throws Exception {
                api.deviceData(exchange);
            }
        });

        Undertow server = Undertow.builder()
                .addHttpListener(PORT, HOSTNAME)
                    .setHandler(UndertowUtil.buildPathHandler(paths))
                .build();

        server.start();
    }
}
