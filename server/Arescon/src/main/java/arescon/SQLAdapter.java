package arescon;

import net.avkorneenkov.SQLUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SQLAdapter {

    public static void insert( Company object ) throws SQLException {
        Connection connection = SQLUtil.getMySQLConnection();
        if (connection != null && object != null) {
            try (PreparedStatement statement = connection.prepareStatement(
                    "INSERT INTO dispatcher_companies (name) VALUES (?)"))
            {
                statement.setString(1, object.name);
                statement.execute();
            }
        }
    }
    public static void insert( HA object ) throws SQLException {
        Connection connection = SQLUtil.getMySQLConnection();
        if (connection != null && object != null) {
            try (PreparedStatement statement = connection.prepareStatement(
                    "INSERT INTO dispatcher_associations (company_id, name) VALUES (?, ?)"))
            {
                statement.setInt(1, object.parent_id != 0 ? object.parent_id : object.parent.id);
                statement.setString(2, object.name);
                statement.execute();
            }
        }
    }
    public static void insert( House object ) throws SQLException {
        Connection connection = SQLUtil.getMySQLConnection();
        if (connection != null && object != null) {
            try (PreparedStatement statement = connection.prepareStatement(
                    "INSERT INTO dispatcher_houses (association_id, address, x, y) VALUES (?, ?, ?, ?)"))
            {
                statement.setInt(1, object.parent_id != 0 ? object.parent_id : object.parent.id);
                statement.setString(2, object.address);
                statement.setString(3, object.x);
                statement.setString(4, object.y);
                statement.execute();
            }
        }
    }
    public static void insert( Flat object ) throws SQLException {
        Connection connection = SQLUtil.getMySQLConnection();
        if (connection != null && object != null) {
            try (PreparedStatement statement = connection.prepareStatement(
                    "INSERT INTO dispatcher_flats (house_id, number) VALUES (?, ?)"))
            {
                statement.setInt(1, object.parent_id != 0 ? object.parent_id : object.parent.id);
                statement.setInt(2, object.number);
                statement.execute();
            }
        }
    }
    public static void insert( Device object ) throws SQLException {
        Connection connection = SQLUtil.getMySQLConnection();
        if (connection != null && object != null) {
            try (PreparedStatement statement = connection.prepareStatement(
                    "INSERT INTO dispatcher_services (type, flat_id, start, period, name, ext_id) " +
                            "VALUES (?, ?, ?, ?, ?, ?)"))
            {
                statement.setInt(1, object.type);
                statement.setInt(2, object.parent_id != 0 ? object.parent_id : object.parent.id);
                statement.setLong(3, object.start);
                statement.setLong(4, object.period);
                statement.setString(5, object.name);
                statement.setString(6, "");
                statement.execute();
            }
        }
    }

    public static Company tree( final int id ) throws SQLException {
        Connection connection = SQLUtil.getMySQLConnection();
        if (connection != null) {
            Company company = selectCompany(id);
            if (company != null) {
                for (HA ha : selectHA(company)) {
                    for (House house : selectHouse(ha)) {
                        for (Flat flat : selectFlat(house)) {
                            for (Device device : selectDevice(flat)) {
                                flat.addDevice(device);
                            }
                            house.addFlat(flat);
                        }
                        ha.addHouse(house);
                    }
                    company.addHA(ha);
                }

                return company;
            }
        }

        return null;
    }

//    public static void update( Company object ) {
//
//    }
//    public static void update( HA object ) {
//
//    }
//    public static void update( House object ) {
//
//    }
//    public static void update( Flat object ) {
//
//    }
//    public static void update( Device object ) {
//
//    }

    public static Company selectCompany( final int id ) throws SQLException {
        Connection connection = SQLUtil.getMySQLConnection();
        if (connection != null) {
            try (PreparedStatement statement = connection.prepareStatement(
                    "SELECT * FROM dispatcher_companies WHERE id = ? LIMIT 1"))
            {
                statement.setInt(1, id);
                try (ResultSet resultSet = statement.executeQuery()) {
                    if (resultSet.next()) {
                        Company object = new Company();
                        object.id = id;
                        return object;
                    }
                }
            }
        }

        return null;
    }
    public static HA selectHA( final int id ) throws SQLException {
        Connection connection = SQLUtil.getMySQLConnection();
        if (connection != null) {
            try (PreparedStatement statement = connection.prepareStatement(
                    "SELECT * FROM dispatcher_associations WHERE id = ? LIMIT 1"))
            {
                statement.setInt(1, id);
                try (ResultSet resultSet = statement.executeQuery()) {
                    if (resultSet.next()) {
                        HA object = new HA(resultSet.getInt("company_id"), resultSet.getString("name"));
                        object.id = id;
                        return object;
                    }
                }
            }
        }

        return null;
    }
    public static List<HA> selectHA( final Company parent ) throws SQLException {
        List<HA> collection = new ArrayList<>(10);
        Connection connection = SQLUtil.getMySQLConnection();
        if (connection != null) {
            try (PreparedStatement statement = connection.prepareStatement(
                    "SELECT * FROM dispatcher_associations WHERE company_id = ?"))
            {
                statement.setInt(1, parent.id);
                try (ResultSet resultSet = statement.executeQuery()) {
                    while (resultSet.next()) {
                        HA object = new HA(parent.id, resultSet.getString("name"));
                        object.id = resultSet.getInt("id");
                        collection.add(object);
                    }
                }
            }
        }

        return collection;
    }
    public static House selectHouse( final int id ) throws SQLException {
        Connection connection = SQLUtil.getMySQLConnection();
        if (connection != null) {
            try (PreparedStatement statement = connection.prepareStatement(
                    "SELECT * FROM dispatcher_houses WHERE id = ? LIMIT 1"))
            {
                statement.setInt(1, id);
                try (ResultSet resultSet = statement.executeQuery()) {
                    if (resultSet.next()) {
                        House object = new House(resultSet.getInt("association_id"), resultSet.getString("address"), resultSet.getString("x"), resultSet.getString("y"));
                        object.id = id;
                        return object;
                    }
                }
            }
        }

        return null;
    }
    public static List<House> selectHouse( final HA parent ) throws SQLException {
        List<House> collection = new ArrayList<>(10);
        Connection connection = SQLUtil.getMySQLConnection();
        if (connection != null) {
            try (PreparedStatement statement = connection.prepareStatement(
                    "SELECT * FROM dispatcher_houses WHERE association_id = ?"))
            {
                statement.setInt(1, parent.id);
                try (ResultSet resultSet = statement.executeQuery()) {
                    while (resultSet.next()) {
                        House object = new House(parent.id, resultSet.getString("address"), resultSet.getString("x"), resultSet.getString("y"));
                        object.id = resultSet.getInt("id");
                        collection.add(object);
                    }
                }
            }
        }

        return collection;
    }
    public static Flat selectFlat( final int id ) throws SQLException {
        Connection connection = SQLUtil.getMySQLConnection();
        if (connection != null) {
            try (PreparedStatement statement = connection.prepareStatement(
                    "SELECT * FROM dispatcher_flat WHERE id = ? LIMIT 1"))
            {
                statement.setInt(1, id);
                try (ResultSet resultSet = statement.executeQuery()) {
                    if (resultSet.next()) {
                        Flat object = new Flat(resultSet.getInt("house_id"), resultSet.getInt("number"));
                        object.id = id;
                        return object;
                    }
                }
            }
        }

        return null;
    }
    public static List<Flat> selectFlat( final House parent ) throws SQLException {
        List<Flat> collection = new ArrayList<>(10);
        Connection connection = SQLUtil.getMySQLConnection();
        if (connection != null) {
            try (PreparedStatement statement = connection.prepareStatement(
                    "SELECT * FROM dispatcher_flats WHERE house_id = ?"))
            {
                statement.setInt(1, parent.id);
                try (ResultSet resultSet = statement.executeQuery()) {
                    while (resultSet.next()) {
                        Flat object = new Flat(parent.id, resultSet.getInt("number"));
                        object.id = resultSet.getInt("id");
                        collection.add(object);
                    }
                }
            }
        }

        return collection;
    }
    public static Device selectDevice( final int id ) throws SQLException {
        Connection connection = SQLUtil.getMySQLConnection();
        if (connection != null) {
            try (PreparedStatement statement = connection.prepareStatement(
                    "SELECT * FROM dispatcher_services WHERE id = ? LIMIT 1"))
            {
                statement.setInt(1, id);
                try (ResultSet resultSet = statement.executeQuery()) {
                    if (resultSet.next()) {
                        Device object = new Device(resultSet.getInt("type"), resultSet.getString("name"));
                        object.id = id;
                        object.parent_id = resultSet.getInt("flat_id");
                        object.start = resultSet.getLong("start");
                        object.period = resultSet.getInt("period");
                        return object;
                    }
                }
            }
        }

        return null;
    }
    public static List<Device> selectDevice( final Flat parent ) throws SQLException {
        List<Device> collection = new ArrayList<>(10);
        Connection connection = SQLUtil.getMySQLConnection();
        if (connection != null) {
            try (PreparedStatement statement = connection.prepareStatement(
                    "SELECT * FROM dispatcher_services WHERE flat_id = ?"))
            {
                statement.setInt(1, parent.id);
                try (ResultSet resultSet = statement.executeQuery()) {
                    while (resultSet.next()) {
                        Device object = new Device(resultSet.getInt("type"), resultSet.getString("name"));
                        object.id = resultSet.getInt("id");
                        object.parent_id = parent.id;
                        object.start = resultSet.getLong("start");
                        object.period = resultSet.getInt("period");
                        collection.add(object);
                    }
                }
            }
        }

        return collection;
    }

//    public static void delete( Company object ) {
//
//    }
//    public static void delete( HA object ) {
//
//    }
//    public static void delete( House object ) {
//
//    }
//    public static void delete( Flat object ) {
//
//    }
//    public static void delete( Device object ) {
//
//    }

}
