package net.avkorneenkov;

import java.sql.*;
import java.util.Properties;
import java.util.Timer;
import java.util.TimerTask;

public class SQLUtil {

    public static boolean TURN_OFF = false;

    private static Connection connection = null;

    private static String connectionString;
    private static Properties connectionProps;

    public synchronized static Connection getMySQLConnection( String username, String password,
                                          String host, String database, int port ) throws SQLException, ClassNotFoundException {
        if (connection == null && !TURN_OFF) {
            Class.forName("com.mysql.jdbc.Driver");
            connectionProps = new Properties();
            connectionProps.put("user", username);
            connectionProps.put("password", password);
            connectionProps.setProperty("useUnicode", "true");
            connectionProps.setProperty("characterEncoding", "UTF-8");
            connectionProps.setProperty("autoReconnect", "true");
            connectionString = "jdbc:mysql://" + host + ":" + port + "/" + database;
            connection = DriverManager.getConnection(connectionString, connectionProps);
        }

        return connection;
    }
    public static Connection getMySQLConnection( String username, String password,
                                                 String host, String database ) throws SQLException, ClassNotFoundException
    {
        return getMySQLConnection(username, password, host, database, 3306);
    }
    public static Connection getMySQLConnection( String username, String password,
                                          String host ) throws SQLException, ClassNotFoundException
    {
        return getMySQLConnection(username, password, host, "");
    }
    public static Connection getMySQLConnection() {
        try {
            return getMySQLConnection(null, null, null, null, 0);
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }

        return null;
    }
    public static void resetConnection() throws SQLException {
        //if (!connection.isClosed()) connection.close();
    }
    public static void addPing( final String sql, final long period ) {
        Timer timer = new Timer(true);
        timer.schedule(new TimerTask() {
            @Override
            public void run() {
                try (Statement statement = getMySQLConnection().createStatement()) {
                    statement.execute(sql);
                } catch (Throwable ignored) { }
            }
        }, 0, period);
    }
    public static int getLastInsertID( ) throws SQLException {
        try (Statement statement = getMySQLConnection().createStatement()) {
            try (ResultSet result = statement.executeQuery("SELECT LAST_INSERT_ID()")) {
                if (result.next()) {
                    return result.getInt("LAST_INSERT_ID()");
                }
            }
        }

        return 0;
    }

}
