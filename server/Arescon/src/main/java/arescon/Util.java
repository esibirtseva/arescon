package arescon;

import freemarker.template.TemplateException;
import io.undertow.security.api.SecurityContext;
import io.undertow.security.idm.Account;
import io.undertow.server.HttpServerExchange;
import net.avkorneenkov.SQLUtil;
import net.avkorneenkov.TimeUtil;
import net.avkorneenkov.freemarker.TemplatesWorker;
import org.joda.time.DateTime;

import java.io.IOException;
import java.io.Writer;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Map;

public class Util {

    private TemplatesWorker templates;

    public Util(TemplatesWorker templates) throws SQLException {
        this.templates = templates;
    }

    void getReportName( boolean dispatcher, Writer response, HttpServerExchange exchange ) {

        int selectionType = 0;
        int id = 0;

        try {
            try {
                selectionType = Integer.parseInt(exchange.getQueryParameters().get("selectiontype").getFirst());
            } catch (Throwable ignored) { }
            try {
                id = Integer.parseInt(exchange.getQueryParameters().get("id").getFirst());
            } catch (Throwable ignored) { }
            String name = "";
            switch (selectionType) {
                case 0:
                    name = " (Управляющая компания)";
                    break;
                case 1:
                    if (id == 1) name = " (ТСЖ 2)";
                    else if (id == 2) name = " (ТСЖ 1)";
                    break;
                case 2:
                    if (id == 4) name = " (Иловайская улица, д. 3)";
                    else if (id == 3) name = " (Башиловская улица, д. 15)";
                    else if (id == 2) name = " (Нежинская улица, д. 13)";
                    else if (id == 1) name = " (Минусинская улица, д. 37)";
                    break;
                case 3:
                    if (id == 1) name = " (Башиловская улица, д. 15, кв. 65)";
                    else if (id == 2) name = " (Иловайская улица, д. 3, кв. 32)";
                    else if (id == 3) name = " (Нежинская улица, д. 13, кв. 145)";
                    else if (id == 4) name = " (Минусинская улица, д. 37, кв. 20)";
                    break;
                case 4:
                    if (dispatcher) {
                        if (id == 1) name = " (Минусинская улица, д. 37, кв. 20 - Газ)";
                        else if (id == 2) name = " (Минусинская улица, д. 37, кв. 20 - Вода)";
                        else if (id == 3) name = " (Минусинская улица, д. 37, кв. 20 - Электричество)";
                        else if (id == 4) name = " (Нежинская улица, д. 13, кв. 145 - Газ)";
                        else if (id == 5) name = " (Нежинская улица, д. 13, кв. 145 - Вода)";
                        else if (id == 6) name = " (Нежинская улица, д. 13, кв. 145 - Электричество)";
                        else if (id == 7) name = " (Башиловская улица, д. 15, кв. 65 - Газ)";
                        else if (id == 8) name = " (Башиловская улица, д. 15, кв. 65 - Вода)";
                        else if (id == 9) name = " (Башиловская улица, д. 15, кв. 65 - Электричество)";
                        else if (id == 10) name = " (Иловайская улица, д. 3, кв. 32 - Газ)";
                        else if (id == 11) name = " (Иловайская улица, д. 3, кв. 32 - Вода)";
                        else if (id == 12) name = " (Иловайская улица, д. 3, кв. 32 - Электричество)";
                    } else {
                        if (id  == 0) name = " (Холодная вода)";
                        else if (id  == 1) name = " (Горячая вода)";
                        else if (id  == 2) name = " (Газ)";
                        else if (id  == 3) name = " (Электричество)";
                        else if (id  == 4) name = " (Отопление)";
                    }
                    break;
                case 5:
                    if (!dispatcher) {
                        if (id == 1) name = " (Холодная вода - Счетчик Techem AP)";
                        else if (id == 2) name = " (Электричество - Счетчик однофазный СОЭ-52)";
                        else if (id == 3) name = " (Газ - Счетчик ГРАНД-25Т)";
                        else if (id == 4) name = " (Горячая вода - Счетчик СВ-15 Х \"МЕТЕР\")";
                    }
                    break;
            }
            response.write(name);
        } catch (Throwable ignored) { }
    }

    void getActiveDevice( String expected, String activeMarker, Writer response, HttpServerExchange exchange ) {
        if (exchange.getRelativePath().equals("/" + expected)) {
            try { response.append(" ").append(activeMarker); }
            catch (IOException ignored) {     }
        }
    }

    void getTypeLink( int type, Writer response, String link ) {
        try {
            switch (type) {
                case 0: if (!Data.DELETED[0]) response.append(link); break;
                case 1: if (!Data.DELETED[3]) response.append(link); break;
                case 2: if (!Data.DELETED[2]) response.append(link); break;
                case 3: if (!Data.DELETED[1]) response.append(link); break;
            }
        } catch (IOException ignored) { }
    }

    void getDispatcherTree( Writer response, HttpServerExchange exchange ) {
        Map<String, String> dataMap = new HashMap<>(3);
        Map<String, Integer> countMap = new HashMap<>();
        Map root = new HashMap<>();
        root.put("map", dataMap);
        root.put("count", countMap);

        try {
            // TODO: generate this shit
            templates.getTemplated(root, "user.dispatcher_tree.htm", response);
        } catch (IOException | TemplateException e) { e.printStackTrace(); }
    }

    void getDispatcherInfo( Writer response, HttpServerExchange exchange ) {
        Map<String, String> dataMap = new HashMap<>(3);
        Map<String, Map<String, String>> root = new HashMap<>();
        root.put("map", dataMap);

        try {
            dataMap.put("name", "Сергей Николаев");
            dataMap.put("avatar", "/images/av-doge.png");
            templates.getTemplated(root, "user.dispatcher_info.htm", response);
        } catch (IOException | TemplateException e) { e.printStackTrace(); }
    }

    void getUserInfo( Writer response, HttpServerExchange exchange ) {
        Map<String, String> dataMap = new HashMap<>(3);
        Map<String, Map<String, String>> root = new HashMap<>();
        root.put("map", dataMap);

        try {
            dataMap.put("fname", "Василий Петрович");
            dataMap.put("sname", "Некифоров");
            dataMap.put("avatar", "/images/av-doge.png");
            templates.getTemplated(root, "user.user_info.htm", response);
        } catch (IOException | TemplateException e) { e.printStackTrace(); }
    }

    void getDeviceInfo( Writer response, HttpServerExchange exchange ) {

        String relPath = exchange.getRelativePath();
        if (relPath.length() <= 1) relPath = "1";
        else relPath = relPath.substring(1);

        Map<String, String> dataMap = new HashMap<>(6);
        Map<String, Map<String, String>> root = new HashMap<>();
        root.put("map", dataMap);

        try {
            int id = Integer.parseInt(relPath);
            for (; id < 5; id++) {
                if (!Data.DELETED[id - 1]) {
                    relPath = Integer.toString(id);
                    break;
                }
            }
            if (id == 5) return;
        } catch (Throwable ignored) { }

        try {
            switch (relPath) {
                case "1": // water
                    dataMap.put("deviceID", "1");
                    dataMap.put("typeID", "");
                    dataMap.put("image", "background-image:url(/images/water.jpg)");
                    dataMap.put("name", "Счетчик Techem AP");
                    dataMap.put("description", "Водосчетчик Techem серий АР для горячей и холодной воды");
                    templates.getTemplated(root, "user.device_info.htm", response);
                    break;
                case "2": // fire
                    dataMap.put("deviceID", "2");
                    dataMap.put("typeID", "");
                    dataMap.put("image", "background-image:url(/images/electro.jpg)");
                    dataMap.put("name", "Счетчик однофазный СОЭ-52");
                    dataMap.put("description", "Электросчётчики СОЭ-52 предназначены для учёта потребления " +
                            "электроэнергии в двухпроводных цепях электрического тока в закрытых помещениях");
                    templates.getTemplated(root, "user.device_info.htm", response);
                    break;
                case "3": // earth
                    dataMap.put("deviceID", "3");
                    dataMap.put("typeID", "");
                    dataMap.put("image", "background-image:url(/images/gas.jpg)");
                    dataMap.put("name", "Счетчик ГРАНД-25Т");
                    dataMap.put("description", "Электронные бытовые счетчики газа ГРАНД-25Т предназначены для " +
                            "измерения объема газа, расходуемого газопотребляющим оборудованием с суммарным" +
                            " максимальным расходом до 25 м3/час");
                    templates.getTemplated(root, "user.device_info.htm", response);
                    break;
                case "4": // air
                    dataMap.put("deviceID", "4");
                    dataMap.put("typeID", "");
                    dataMap.put("image", "background-image:url(/images/water-2.jpeg)");
                    dataMap.put("name", "Счетчик СВ-15 Х \"МЕТЕР\"");
                    dataMap.put("description", "Счетчики воды крыльчатые СВ-15Х (одноструйные, сухоходные) " +
                            "предназначены для измерения объема горячей воды, протекающей по трубопроводу при" +
                            " температуре от 5°С до 90°С и рабочем давлении в водопроводной сети не более 1, 0 МПа");
                    templates.getTemplated(root, "user.device_info.htm", response);
                    break;
                case "water":
                    dataMap.put("deviceID", "");
                    dataMap.put("typeID", "01");
                    dataMap.put("image", "background-color:rgb(41,128,184)");
                    dataMap.put("name", "Вода");
                    dataMap.put("description", "Данные обо всех приборах данной услуги");
                    templates.getTemplated(root, "user.device_info.htm", response);
                    break;
                case "gas":
                    dataMap.put("deviceID", "");
                    dataMap.put("typeID", "2");
                    dataMap.put("image", "background-color:rgb(45,204,112)");
                    dataMap.put("name", "Газ");
                    dataMap.put("description", "Данные обо всех приборах данной услуги");
                    templates.getTemplated(root, "user.device_info.htm", response);
                    break;
                case "heat":
                    dataMap.put("deviceID", "");
                    dataMap.put("typeID", "4");
                    dataMap.put("image", "background-color:rgb(231,75,59)");
                    dataMap.put("name", "Отопление");
                    dataMap.put("description", "Данные обо всех приборах данной услуги");
                    templates.getTemplated(root, "user.device_info.htm", response);
                    break;
                case "electricity":
                    dataMap.put("deviceID", "");
                    dataMap.put("typeID", "3");
                    dataMap.put("image", "background-color:rgb(243,156,18)");
                    dataMap.put("name", "Электричество");
                    dataMap.put("description", "Данные обо всех приборах данной услуги");
                    templates.getTemplated(root, "user.device_info.htm", response);
                    break;
                case "coldwater":
                    dataMap.put("deviceID", "");
                    dataMap.put("typeID", "0");
                    dataMap.put("image", "background-color:rgb(41,128,184)");
                    dataMap.put("name", "Холодная вода");
                    dataMap.put("description", "Данные обо всех приборах данной услуги");
                    templates.getTemplated(root, "user.device_info.htm", response);
                    break;
                case "hotwater":
                    dataMap.put("deviceID", "");
                    dataMap.put("typeID", "1");
                    dataMap.put("image", "background-color:rgb(41,128,184)");
                    dataMap.put("name", "Горячая вода");
                    dataMap.put("description", "Данные обо всех приборах данной услуги");
                    templates.getTemplated(root, "user.device_info.htm", response);
                    break;
            }
        } catch (TemplateException | IOException e) {
            e.printStackTrace();
        }
    }

    void getDevices( int type, Writer response, HttpServerExchange exchange, boolean pickActives ) {

        String relPath = exchange.getRelativePath();
        if (relPath.length() <= 1) relPath = "1";
        else relPath = relPath.substring(1);

        Map<String, String> dataMap = new HashMap<>(6);
        Map<String, Map<String, String>> root = new HashMap<>();
        root.put("map", dataMap);

        try {
            int id = Integer.parseInt(relPath);
            for (; id < 5; id++) {
                if (!Data.DELETED[id - 1]) {
                    relPath = Integer.toString(id);
                    break;
                }
            }
            if (id == 5) return;
        } catch (Throwable ignored) { }

        try {
            switch (type) {
                case 0: // water
                    if (!Data.DELETED[0]) {
                        dataMap.put("active", relPath.equals("1") && pickActives ? " active" : "");
                        dataMap.put("deviceID", "1");
                        dataMap.put("name", "Счетчик Techem AP");
                        dataMap.put("type", "Холодная вода");
                        dataMap.put("status", "good");
                        dataMap.put("status_icon", "ok");
                        templates.getTemplated(root, "user.device.htm", response);
                    } else {
                        response.append("<h5 style=\"text-align: center;\">Нет подключенных приборов</h5>");
                    }
                    break;
                case 1:
                    if (!Data.DELETED[3]) {
                        dataMap.put("active", relPath.equals("4") && pickActives ? " active" : "");
                        dataMap.put("deviceID", "4");
                        dataMap.put("name", "Счетчик СВ-15 Х \"МЕТЕР\"");
                        dataMap.put("type", "Горячая вода");
                        dataMap.put("status", "good");
                        dataMap.put("status_icon", "ok");
                        templates.getTemplated(root, "user.device.htm", response);
                    } else {
                        response.append("<h5 style=\"text-align: center;\">Нет подключенных приборов</h5>");
                    }
                    break;
                case 2: // fire
                    if (!Data.DELETED[2]) {
                        dataMap.put("active", relPath.equals("3") && pickActives ? " active" : "");
                        dataMap.put("deviceID", "3");
                        dataMap.put("name", "Счетчик ГРАНД-25Т");
                        dataMap.put("type", "");
                        dataMap.put("status", "wait");
                        dataMap.put("status_icon", "warning-sign");
                        templates.getTemplated(root, "user.device.htm", response);
                    } else {
                        response.append("<h5 style=\"text-align: center;\">Нет подключенных приборов</h5>");
                    }
                    break;
                case 3: // earth
                    if (!Data.DELETED[1]) {
                        dataMap.put("active", relPath.equals("2") && pickActives ? " active" : "");
                        dataMap.put("deviceID", "2");
                        dataMap.put("name", "Счетчик однофазный СОЭ-52");
                        dataMap.put("type", "");
                        dataMap.put("status", "bad");
                        dataMap.put("status_icon", "remove");
                        templates.getTemplated(root, "user.device.htm", response);
                    } else {
                        response.append("<h5 style=\"text-align: center;\">Нет подключенных приборов</h5>");
                    }
                    break;
                case 4: // air
                    response.append("<h5 style=\"text-align: center;\">Нет подключенных приборов</h5>");
                    break;
            }
        } catch (TemplateException | IOException e) {
            e.printStackTrace();
        }
    }

    void getNews( int index, Writer response, HttpServerExchange exchange ) {
        int pageIndex = 0;
        String relPath = exchange.getRelativePath();
        if (relPath != null) {
            try {
                pageIndex = Integer.parseInt(relPath.substring(1));
            } catch (Throwable ignored) { }
        }

        try {
            Map<String, String> dataMap = new HashMap<>(4);
            Map<String, Map<String, String>> root = new HashMap<>();
            root.put("map", dataMap);
            dataMap.put("title", "Заголовок");
            dataMap.put("text", "Lorem ipsum dolor sit amet, consectetur adipisicing elit. Iste saepe doloremque et" +
                    " minima eligendi dolores molestias adipisci, sed ducimus. Alias ipsa quas distinctio? Laborios" +
                    "am dolorum nihil veniam quisquam dolorem animi!");
            dataMap.put("link", "#");
            templates.getTemplated(root, "index.news.htm", response);
            templates.getTemplated(root, "index.news.htm", response);
        } catch (TemplateException | IOException e) {
            e.printStackTrace();
        }
    }

    void getIndexArrows( Writer response, HttpServerExchange exchange ) {
        int pageIndex = 0;
        String relPath = exchange.getRelativePath();
        if (relPath != null) {
            try { pageIndex = Integer.parseInt(relPath.substring(1)); }
            catch (Throwable ignored) { }
        }

        try {
            int count = 8;
            Map<String, String> dataMap = new HashMap<>(4);
            Map<String, Map<String, String>> root = new HashMap<>();
            root.put("map", dataMap);
            if (pageIndex > 0) {
                dataMap.put("left_dis", "");
                dataMap.put("left", "/" + Math.max(pageIndex - 4, 0));
            } else {
                dataMap.put("left_dis", "class=\"arrow-disabled\"");
                dataMap.put("left", "#");
            }
            if (count > pageIndex + 4) {
                dataMap.put("right_dis", "");
                dataMap.put("right", "/" + (pageIndex + 4));
            } else {
                dataMap.put("right_dis", "class=\"arrow-disabled\"");
                dataMap.put("right", "#");
            }
            templates.getTemplated(root, "index.arrows.htmt", response);
        } catch (IOException | TemplateException e) {
            e.printStackTrace();
        }
    }

    String getInviteMail( String username, String password ) {
        return "Username: " + username + "\nPassword: " + password + "\n";
    }

    void getMenu( Writer response, HttpServerExchange exchange ) {
        SecurityContext securityContext = exchange.getSecurityContext();
        if (securityContext == null) return;
        Account account = securityContext.getAuthenticatedAccount();
        if (account == null) return;
        String role = account.getRoles().iterator().next();
        try {
            if (role.equals("adm")) {
                templates.getTemplated(null, "dashboard.trn.menu.htmt", response);
                templates.getTemplated(null, "dashboard.adm.menu.htmt", response);
            } else if (role.equals("trn")) {
                templates.getTemplated(null, "dashboard.trn.menu.htmt", response);
            }
        } catch (IOException | TemplateException e) {
            e.printStackTrace();
        }
    }

    void getPageName( String pagename, Writer response ) {
        HashMap<String, String> dataMap = new HashMap<>();
        Map<String, Map<String, String>> root = new HashMap<>();
        root.put("map", dataMap);
        dataMap.put("name", pagename);
        try {
            templates.getTemplated(root, "dashboard.pagename.htmt", response);
        } catch (IOException | TemplateException e) {
            e.printStackTrace();
        }
    }

    void getAddPlaceForm( Writer response, HttpServerExchange exchange, String error ) {
        Map<String, String> dataMap = new HashMap<>(4);
        Map<String, Map<String, String>> root = new HashMap<>();
        root.put("map", dataMap);
        dataMap.put("error", error);
        try { templates.getTemplated(root, "dashboard.addplace.form.htmt", response); }
        catch (IOException | TemplateException e) { e.printStackTrace(); }
    }

    void getInviteForm( Writer response, HttpServerExchange exchange, String error ) {
        Map<String, String> dataMap = new HashMap<>(4);
        Map<String, Map<String, String>> root = new HashMap<>();
        root.put("map", dataMap);
        dataMap.put("error", error);
        try { templates.getTemplated(root, "dashboard.invite.form.htmt", response); }
        catch (IOException | TemplateException e) { e.printStackTrace(); }
    }

    void getSportsmen( Writer response, HttpServerExchange exchange ) {
        Account account = exchange.getSecurityContext().getAuthenticatedAccount();
        String role = account.getRoles().iterator().next();
        if (role.equals("adm")) {
            try (Statement statement = SQLUtil.getMySQLConnection().createStatement()) {
                try (ResultSet result = statement.executeQuery(
                        "SELECT sportsman.id, users.id_discipline, users.id_parent, users.fio, sportsman.maxres, users.avatar FROM sportsman, users WHERE users.id = sportsman.id_user"))
                {
                    while (result.next()) {
                        // templating
                        Map<String, String> dataMap = new HashMap<>(4);
                        Map<String, Map<String, String>> root = new HashMap<>();
                        root.put("map", dataMap);
                        int parentID = result.getInt("id_parent");
                        int id = result.getInt("id");
                        dataMap.put("id", Integer.toString(id));
                        dataMap.put("name", result.getString("fio"));
                        dataMap.put("maxres", result.getString("maxres"));
                        dataMap.put("avatar", result.getString("avatar"));
                        String discipline = "";
                        //try { discipline = disciplines.get(result.getInt("id_discipline")); }
                        //catch (Throwable ignored) { }
                        dataMap.put("discipline", discipline);
                        String coach = "";
                        try (PreparedStatement statement2 = SQLUtil.getMySQLConnection().prepareStatement(
                                "SELECT fio FROM users WHERE id = ? LIMIT 1"))
                        {
                            statement2.setInt(1, parentID);
                            try (ResultSet result2 = statement2.executeQuery()) {
                                if (result2.next()) {
                                    coach = result2.getString("fio");
                                }
                            }
                        }
                        dataMap.put("coach", coach);
                        String lastPlace = "";
                        try (PreparedStatement statement2 = SQLUtil.getMySQLConnection().prepareStatement(
                                "SELECT id_place FROM measures WHERE id_sportsman = ? ORDER BY data DESC LIMIT 1"))
                        {
                            statement2.setInt(1, id);
                            try (ResultSet result2 = statement2.executeQuery()) {
                                if (result2.next()) {
                                    try (PreparedStatement statement3 = SQLUtil.getMySQLConnection().prepareStatement(
                                            "SELECT name FROM places WHERE id = ? LIMIT 1"))
                                    {
                                        statement3.setInt(1, result2.getInt("id_place"));
                                        try (ResultSet result3 = statement3.executeQuery()) {
                                            if (result3.next()) {
                                                lastPlace = result3.getString("name");
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        dataMap.put("lastPlace", lastPlace);
                        templates.getTemplated(root, "dashboard.sportsman.htmt", response);
                    }
                }
            } catch (SQLException | IOException | TemplateException e) { e.printStackTrace(); }
        } else if (role.equals("trn")) {
            try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement(
                    "SELECT id, id_discipline FROM users WHERE login = ? LIMIT 1"))
            {
                statement.setString(1, account.getPrincipal().getName());
                try (ResultSet result = statement.executeQuery()) {
                    if (result.next()) {
                        int parentID = result.getInt("id");
                        int disciplineID = result.getInt("id_discipline");
                        try (PreparedStatement statement2 = SQLUtil.getMySQLConnection().prepareStatement(
                                "SELECT sportsman.id, sportsman.fio, sportsman.maxres, users.avatar FROM users, sportsman WHERE " +
                                        "users.id_parent = ? AND users.id = sportsman.id_user")) {
                            statement2.setInt(1, parentID);
                            try (ResultSet result2 = statement2.executeQuery()) {
                                while (result2.next()) {
                                    Map<String, String> dataMap = new HashMap<>(4);
                                    Map<String, Map<String, String>> root = new HashMap<>();
                                    root.put("map", dataMap);
                                    int id = result2.getInt("id");
                                    dataMap.put("id", Integer.toString(id));
                                    dataMap.put("name", result2.getString("fio"));
                                    dataMap.put("maxres", result2.getString("maxres"));
                                    dataMap.put("avatar", result2.getString("avatar"));
                                    String discipline = "";
//                                    try { discipline = disciplines.get(disciplineID); }
//                                    catch (Throwable ignored) { }
                                    dataMap.put("discipline", discipline);
                                    String coach = "";
                                    try (PreparedStatement statement3 = SQLUtil.getMySQLConnection().prepareStatement(
                                            "SELECT fio FROM users WHERE id = ? LIMIT 1"))
                                    {
                                        statement3.setInt(1, parentID);
                                        try (ResultSet result3 = statement3.executeQuery()) {
                                            if (result3.next()) {
                                                coach = result3.getString("fio");
                                            }
                                        }
                                    }
                                    dataMap.put("coach", coach);
                                    String lastPlace = "";
                                    try (PreparedStatement statement3 = SQLUtil.getMySQLConnection().prepareStatement(
                                            "SELECT id_place FROM measures WHERE id_sportsman = ? ORDER BY data DESC LIMIT 1"))
                                    {
                                        statement3.setInt(1, id);
                                        try (ResultSet result3 = statement3.executeQuery()) {
                                            if (result3.next()) {
                                                try (PreparedStatement statement4 = SQLUtil.getMySQLConnection().prepareStatement(
                                                        "SELECT name FROM places WHERE id = ? LIMIT 1"))
                                                {
                                                    statement4.setInt(1, result3.getInt("id_place"));
                                                    try (ResultSet result4 = statement4.executeQuery()) {
                                                        if (result4.next()) {
                                                            lastPlace = result4.getString("name");
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    dataMap.put("lastPlace", lastPlace);
                                    templates.getTemplated(root, "dashboard.sportsman.htmt", response);
                                }
                            }
                        }
                    }
                }
            } catch (SQLException | IOException | TemplateException e) { e.printStackTrace(); }
        }
    }

    Map<String, Map<String, String>> getSportsmanInfo( final String login ) throws SQLException {
        try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement(
                "SELECT id, id_discipline, id_parent, fio, login, avatar FROM users WHERE login = ? LIMIT 1"))
        {
            statement.setString(1, login);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    return getSportsmanDataMap(result);
                }
            }
        }

        return null;
    }

    Map<String, Map<String, String>> getTrainerInfo( final String login ) throws SQLException {
        try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement(
                "SELECT id, id_discipline, fio, login, avatar FROM users WHERE login = ? LIMIT 1"))
        {
            statement.setString(1, login);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    return getTrainerDataMap(result);
                }
            }
        }

        return null;
    }

    void getProfile( Writer response, HttpServerExchange exchange, final String error ) {
        Account account = exchange.getSecurityContext().getAuthenticatedAccount();
        String role = account.getRoles().iterator().next();
        String login = account.getPrincipal().getName();

        try {
            if (role.equals("spt")) {
                Map<String, Map<String, String>> data = getSportsmanInfo(login);
                if (data == null) return;
                data.get("map").put("error", error);
                templates.getTemplated(data, "dashboard.profile.spt.htmt", response);
            } else {
                Map<String, Map<String, String>> data = getTrainerInfo(login);
                if (data == null) return;
                data.get("map").put("error", error);
                templates.getTemplated(data, "dashboard.profile.trn.htmt", response);
            }
        } catch (IOException | SQLException | TemplateException e) {
            e.printStackTrace();
        }
    }

    private String getSeriesType( int type ) {
        switch (type) {
            case 0: return "Обучение";
            case 1: return "Тренировка";
            case 2: return "Восстановление";
            case 3: return "Подготовка к соревнованию";
            case 4: return "Соревнование";
            case 5: return "Осознание результата";
            default: return "";
        }
    }

    private String getAccountType( String type ) {
        switch (type) {
            case "adm": return "Администратор";
            case "spt": return "Спортсмен";
            case "trn": return "Тренер";
            default: return "";
        }
    }

    private String getSANState( double san1, double san2 ) {
        String state = "";

        if (san1 < 20) state += "1";
        else if (san1 <= 22) state += "2";
        else state += "3";

        if (san2 < 8) state += "1";
        else if (san2 <= 10) state += "2";
        else state += "3";

        return state;
    }

    public String getRecommendationKey( double pulse, double tremor ) {
        String state = "";
        final double STATE_INTERVAL = 0.38 * 2;
        pulse /= 100.0;
        tremor /= 100.0;

        if (pulse < 1.0 - STATE_INTERVAL / 2.0) state += "1";
        else if (pulse <= 1.0 + STATE_INTERVAL / 2.0) state += "2";
        else state += "3";

        if (tremor < 1.0 - STATE_INTERVAL / 2.0) state += "1";
        else if (tremor <= 1.0 + STATE_INTERVAL / 2.0) state += "2";
        else state += "3";

        return state;
    }

    private String getStateColor( int rate ) {
        switch (rate) {
            case 1:
                return "red";
            case 2:
                return "yellow";
            case 3:
                return "green";
            default:
                return "grey";
        }
    }

    void getSeries( Writer response, HttpServerExchange exchange ) {

        final int MAX_SERIES = 6;

        int id = 0;
        String relPath = exchange.getRelativePath();
        if (relPath != null) {
            try { id = Integer.parseInt(relPath.substring(1)); }
            catch (Throwable ignored) { }
        }
        if (id == 0) {
            return;
        }

        try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement(
                "SELECT measures.id_place, sportsman.avgres, series.id FROM sportsman, measures, series WHERE " +
                "measures.id = ? AND measures.id_sportsman = sportsman.id AND series.type_index > 0 " +
                "AND measures.id = series.id_mes ORDER BY series.type_index LIMIT " + (MAX_SERIES - 1)))
        {
            statement.setInt(1, id);
            int measureID = id;
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    id = result.getInt("id");
                    float avgres = result.getFloat("avgres");
                    int placeID = result.getInt("id_place");
                    try (PreparedStatement statement2 = SQLUtil.getMySQLConnection().prepareStatement(
                            "SELECT type_index, unix_timestamp(date), motivation, anxiety, tremor, heartrate FROM series WHERE id = ? LIMIT 1")) {
                        statement2.setInt(1, id);
                        try (ResultSet result2 = statement2.executeQuery()) {
                            while (result2.next()) {
                                int series = result2.getInt("type_index");
                                if (series == 0) return;
                                Map<String, String> dataMap = new HashMap<>(4);
                                Map<String, Map<String, String>> root = new HashMap<>();
                                root.put("map", dataMap);
                                dataMap.put("type", getSeriesType(series));
                                float motivationAbs = result2.getFloat("motivation") / 1000.f;
                                float motivation = motivationAbs / (.21f);
                                dataMap.put("motivation", String.format("%.1f", Math.min(motivation, 9999.9f)));
                                dataMap.put("arrow3", motivation >= 100.f ? "up" : "down");
                                dataMap.put("arrow3Text", motivation >= 100.f ? "&#xE098;" : "&#xE099;");
                                float anxietyAbs = result2.getFloat("anxiety") / 1000.f;
                                float anxiety = anxietyAbs / (.09f);
                                dataMap.put("anxiety", String.format("%.1f", Math.min(anxiety, 9999.9f)));
                                dataMap.put("arrow4", anxiety >= 100.f ? "up" : "down");
                                dataMap.put("arrow4Text", anxiety >= 100.f ? "&#xE098;" : "&#xE099;");
                                float tremor = result2.getFloat("tremor") / 10.f;
                                dataMap.put("tremor", String.format("%.1f", Math.min(tremor, 9999.9f)));
                                dataMap.put("arrow2", tremor >= 100.f ? "up" : "down");
                                dataMap.put("arrow2Text", tremor >= 100.f ? "&#xE098;" : "&#xE099;");
                                float heartrate = result2.getFloat("heartrate") / 10.f;
                                dataMap.put("heartrate", String.format("%.1f", Math.min(heartrate, 9999.9f)));
                                dataMap.put("arrow1", heartrate >= 100.f ? "up" : "down");
                                dataMap.put("arrow1Text", heartrate >= 100.f ? "&#xE098;" : "&#xE099;");
                                DateTime dateTime = new DateTime(result2.getLong("unix_timestamp(date)") * 1000);
                                dataMap.put("date", dateTime.getDayOfMonth() + "." + dateTime.getMonthOfYear() +
                                        '.' + dateTime.getYear());
                                float shot = 0.f;
                                try (PreparedStatement statement3 = SQLUtil.getMySQLConnection().prepareStatement(
                                        "SELECT rate FROM shots WHERE id_mes = ? AND series = ? LIMIT 1")) {
                                    statement3.setInt(1, measureID);
                                    statement3.setInt(2, series);
                                    try (ResultSet result3 = statement3.executeQuery()) {
                                        if (result3.next()) {
                                            shot = result3.getFloat("rate");
                                        }
                                    }
                                }
                                dataMap.put("shot", String.format("%.1f", Math.min(shot, 9999.9f)));

                                dataMap.put("arrow5", shot >= avgres ? "up" : "down");
                                dataMap.put("arrow5Text", shot >= avgres ? "&#xE098;" : "&#xE099;");

                                String state = "";
                                String recommendation = "";
                                int stateRate = 0;
                                try (PreparedStatement statement3 = SQLUtil.getMySQLConnection().prepareStatement(
                                        "SELECT caption, recomend, rate FROM data_states WHERE series = ? AND index_san = ? AND index_pulse_tremor = ? LIMIT 1")) {
                                    statement3.setInt(1, series);
                                    statement3.setString(2, getSANState(motivationAbs, anxietyAbs));
                                    statement3.setString(3, getRecommendationKey(heartrate, tremor));
                                    try (ResultSet result3 = statement3.executeQuery()) {
                                        if (result3.next()) {
                                            state = result3.getString("caption");
                                            recommendation = result3.getString("recomend");
                                            stateRate = result3.getInt("rate");
                                        }
                                    }
                                }
                                dataMap.put("state", state);
                                dataMap.put("recommendation", recommendation);
                                dataMap.put("color", getStateColor(stateRate));

                                String place = "";
                                try (PreparedStatement statement3 = SQLUtil.getMySQLConnection().prepareStatement(
                                        "SELECT name FROM places WHERE id = ? LIMIT 1"))
                                {
                                    statement3.setInt(1, placeID);
                                    try (ResultSet result3 = statement3.executeQuery()) {
                                        if (result3.next()) {
                                            place = result3.getString("name");
                                        }
                                    }
                                }
                                dataMap.put("place", place);

                                templates.getTemplated(root, "dashboard.series.htmt", response);
                            }
                        }
                    }
                }
            }
        } catch (SQLException | IOException | TemplateException e) {
            e.printStackTrace();
        }
    }

    void getMeasures( Writer response, HttpServerExchange exchange ) {

        final int MAX_SERIES = 6;

        int id = 0;
        String relPath = exchange.getRelativePath();
        if (relPath != null) {
            try {
                id = Integer.parseInt(relPath.substring(1));
            } catch (Throwable ignored) { }
        }

        if (id <= 0) {
            String login = exchange.getSecurityContext().getAuthenticatedAccount().getPrincipal().getName();
            try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement(
                    "SELECT sportsman.id FROM users, sportsman WHERE sportsman.id_user = users.id AND users.login = ? LIMIT 1"))
            {
                statement.setString(1, login);
                try (ResultSet result = statement.executeQuery()) {
                    if (result.next()) {
                        id = result.getInt("id");
                    } else return;
                }
            } catch (SQLException e) {
                e.printStackTrace();
                return;
            }
        }

        try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement(
                "SELECT id, id_place, id_discipline, comment, unix_timestamp(data) FROM measures WHERE id_sportsman = ? ORDER BY data DESC"))
        {
            statement.setInt(1, id);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    id = result.getInt("id");
                    int placeID = result.getInt("id_place");
                    int disciplineID = result.getInt("id_discipline");
                    DateTime dateTime = new DateTime(result.getLong("unix_timestamp(data)") * 1000);
                    String date = dateTime.getDayOfMonth() + "." + dateTime.getMonthOfYear() + "." + dateTime.getYear();

                    String comment = result.getString("comment");
                    int[] seriesID = new int[MAX_SERIES];

                    try (PreparedStatement statement2 = SQLUtil.getMySQLConnection().prepareStatement(
                            "SELECT id, type_index FROM series WHERE id_mes = ? LIMIT " + MAX_SERIES))
                    {
                        statement2.setInt(1, id);
                        try (ResultSet result2 = statement2.executeQuery()) {
                            while (result2.next()) {
                                int index = result2.getInt("type_index");
                                if (index > 0 && index < MAX_SERIES) {
                                    seriesID[index] = result2.getInt("id");
                                }
                            }
                        }
                    }

                    String place = "";
                    try (PreparedStatement statement2 = SQLUtil.getMySQLConnection().prepareStatement(
                            "SELECT name FROM places WHERE id = ? LIMIT 1"))
                    {
                        statement2.setInt(1, placeID);
                        try (ResultSet result2 = statement2.executeQuery()) {
                            if (result2.next()) {
                                place = result2.getString("name");
                            }
                        }
                    }

                    String discipline = "";
//                    try { discipline = disciplines.get(disciplineID); }
//                    catch (Throwable ignored) { }

                    Map<String, String> dataMap = new HashMap<>(4);
                    Map<String, Map<String, String>> root = new HashMap<>();
                    root.put("map", dataMap);

                    dataMap.put("place", place);
                    dataMap.put("date", date);
                    dataMap.put("discipline", discipline == null ? "" : discipline);
                    dataMap.put("comment", comment == null || comment.isEmpty() ? "---" : comment);
                    for (int i = 0; i < MAX_SERIES; ++i) {
                        dataMap.put("series" + i, Integer.toString(seriesID[i]));
                    }
                    dataMap.put("id", Integer.toString(id));

                    templates.getTemplated(root, "dashboard.measure.htmt", response);
                }
            }
        } catch (SQLException | IOException | TemplateException e) { e.printStackTrace(); }
    }

    void getPlaces( Writer response, HttpServerExchange exchange ) {
        Account account = exchange.getSecurityContext().getAuthenticatedAccount();
        String role = account.getRoles().iterator().next();
        if (role.equals("adm")) {
            try (Statement statement = SQLUtil.getMySQLConnection().createStatement()) {
                try (ResultSet result = statement.executeQuery("SELECT id, name, address FROM places")) {
                    while (result.next()) {
                        int id = result.getInt("id");
                        String name = result.getString("name");
                        String address = result.getString("address");
                        int measures = 0;
                        try (PreparedStatement statement2 = SQLUtil.getMySQLConnection().prepareStatement(
                                "SELECT COUNT(series.id) FROM measures, series WHERE series.id_mes = measures.id AND measures.id_place = ?"))
                        {
                            statement2.setInt(1, id);
                            try (ResultSet result2 = statement2.executeQuery()) {
                                if (result2.next()) {
                                    measures = result2.getInt("COUNT(series.id)");
                                }
                            }
                        }
                        Map<String, String> dataMap = new HashMap<>(4);
                        Map<String, Map<String, String>> root = new HashMap<>();
                        root.put("map", dataMap);
                        dataMap.put("id", Integer.toString(id));
                        dataMap.put("name", name);
                        dataMap.put("address", address);
                        dataMap.put("measures", Integer.toString(measures));
                        templates.getTemplated(root, "dashboard.place.htmt", response);
                    }
                }
            } catch (SQLException | IOException | TemplateException e) { e.printStackTrace(); }
        }
    }

    String getBestSportsman( int id ) throws SQLException {
        try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement(
                "SELECT sportsman.fio FROM users, sportsman WHERE users.id = sportsman.id_user AND " +
                "users.id_parent = ? ORDER BY sportsman.avgres DESC LIMIT 1"))
        {
            statement.setInt(1, id);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    return result.getString("fio");
                }
            }
        }

        return "Неизвестно";
    }

    float getBestTrainerResult( int id ) throws SQLException {
        try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement(
                "SELECT sportsman.maxres FROM sportsman, users WHERE users.id_parent = ? AND " +
                "users.id = sportsman.id_user"))
        {
            statement.setInt(1, id);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    return result.getFloat("maxres");
                }
            }
        }

        return 0.f;
    }

    Map<String, Map<String, String>> getSportsmanDataMap( ResultSet result ) throws SQLException {
        Map<String, String> dataMap = new HashMap<>(4);
        Map<String, Map<String, String>> root = new HashMap<>();
        root.put("map", dataMap);

        int id = result.getInt("id");
        dataMap.put("id", Integer.toString(id));
        dataMap.put("avatar", result.getString("avatar"));
        String discipline = "";
//        try { discipline = disciplines.get(result.getInt("id_discipline")); }
//        catch (Throwable ignored) { }
        dataMap.put("discipline", discipline);
        String name = result.getString("fio");
        dataMap.put("name", name);
        String email = result.getString("login");
        dataMap.put("email", email);

        int parentID = result.getInt("id_parent");
        String coach = "";
        try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement(
                "SELECT fio FROM users WHERE id = ? LIMIT 1"))
        {
            statement.setInt(1, parentID);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    coach = resultSet.getString("fio");
                }
            }
        }
        dataMap.put("coach", coach);

        float maxres = 0.f;
        int insport = 0;
        String gender = "";
        try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement(
                "SELECT maxres, gender, insport FROM sportsman WHERE id_user = ? LIMIT 1"))
        {
            statement.setInt(1, id);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    insport = resultSet.getInt("insport");
                    gender = resultSet.getString("gender").equals("male") ? "мужской" : "женский";
                    maxres = resultSet.getFloat("maxres");
                }
            }
        }
        dataMap.put("maxres", String.format("%.2f", maxres));
        dataMap.put("gender", gender);
        dataMap.put("insport", Integer.toString(insport));

        String lastPlace = "";
        try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement(
                "SELECT places.name FROM places, measures, users, sportsman WHERE users.id_parent = ? AND " +
                        "users.id = sportsman.id_user AND measures.id_sportsman = sportsman.id AND " +
                        "places.id = measures.id_place ORDER BY data DESC LIMIT 1"))
        {
            statement.setInt(1, id);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    lastPlace = resultSet.getString("name");
                }
            }
        }
        dataMap.put("lastPlace", lastPlace);

        return root;
    }

    Map<String, Map<String, String>> getTrainerDataMap( ResultSet result ) throws SQLException {
        Map<String, String> dataMap = new HashMap<>(4);
        Map<String, Map<String, String>> root = new HashMap<>();
        root.put("map", dataMap);

        int id = result.getInt("id");
        dataMap.put("avatar", result.getString("avatar"));
        dataMap.put("id", Integer.toString(id));
        String discipline = "";
//        try { discipline = disciplines.get(result.getInt("id_discipline")); }
//        catch (Throwable ignored) { }
        dataMap.put("discipline", discipline);
        String name = result.getString("fio");
        dataMap.put("name", name);
        String email = result.getString("login");
        dataMap.put("email", email);
        dataMap.put("bestspt", getBestSportsman(id));
        dataMap.put("maxres", String.format("%.2f", getBestTrainerResult(id)));
        String lastPlace = "";
        try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement(
                "SELECT places.name FROM places, measures, users, sportsman WHERE users.id_parent = ? AND " +
                "users.id = sportsman.id_user AND measures.id_sportsman = sportsman.id AND " +
                "places.id = measures.id_place ORDER BY data DESC LIMIT 1"))
        {
            statement.setInt(1, id);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    lastPlace = resultSet.getString("name");
                }
            }
        }
        dataMap.put("lastPlace", lastPlace);

        return root;
    }

    void getUsers( Writer response, HttpServerExchange exchange ) {
        Account account = exchange.getSecurityContext().getAuthenticatedAccount();
        String role = account.getRoles().iterator().next();
        if (role.equals("adm")) {
            try (Statement statement = SQLUtil.getMySQLConnection().createStatement()) {
                try (ResultSet result = statement.executeQuery("SELECT id, id_discipline, fio, login, avatar FROM users WHERE type = \'ina\'")) {
                    while (result.next()) {
                        templates.getTemplated(getTrainerDataMap(result), "dashboard.user.ina.htmt", response);
                    }
                }
                try (ResultSet result = statement.executeQuery("SELECT id, id_discipline, fio, login, avatar FROM users WHERE type = \'trn\'")) {
                    while (result.next()) {
                        templates.getTemplated(getTrainerDataMap(result), "dashboard.user.trn.htmt", response);
                    }
                }
                try (ResultSet result = statement.executeQuery("SELECT id, id_discipline, id_parent, fio, login, avatar FROM users WHERE type = \'spt\'")) {
                    while (result.next()) {
                        templates.getTemplated(getSportsmanDataMap(result), "dashboard.user.spt.htmt", response);
                    }
                }
            } catch (SQLException | IOException | TemplateException e) { e.printStackTrace(); }
        }
    }
}
