package net.avkorneenkov.undertow;

import io.undertow.security.idm.Account;
import io.undertow.security.idm.Credential;
import io.undertow.security.idm.IdentityManager;
import io.undertow.security.idm.PasswordCredential;
import net.avkorneenkov.SQLUtil;
import net.avkorneenkov.util.Pair;

import java.security.Principal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;

public class DatabaseIdentityManager implements IdentityManager {

    private final Set<String> toLogout;

    private final Map<String, Pair<String, char[]>> users;

    public Map<String, Pair<String, char[]>> getUsers() {
        return users;
    }

    private String loginColumnName;
    private String passwordColumnName;
    private String roleColumnName;
    private String tableName;
    private String inactiveRoleName;

    public DatabaseIdentityManager( String tableName, String loginColumnName, String inactiveRoleName,
                                    String passwordColumnName, String roleColumnName ) {

        this.inactiveRoleName = inactiveRoleName;
        this.tableName = tableName;
        this.loginColumnName = loginColumnName;
        this.passwordColumnName = passwordColumnName;
        this.roleColumnName = roleColumnName;

        this.toLogout = new HashSet<>();
        this.users = new HashMap<>();
    }

    @Override
    public Account verify( Account account ) {
//        String id = account.getPrincipal().getName();
//        synchronized (toLogout) {
//            for (Iterator<String> it = toLogout.iterator(); it.hasNext(); ) {
//                if (it.next().equals(id)) {
//                    it.remove();
//                    users.remove(id);
//                    return null;
//                }
//            }
//        }
        return account;
    }

    public Account verify( String username, PasswordCredential password, String session ) {
        Account account = verify(username, password);
        if (account != null) {
            return verify(account);
        }

        return null;
    }

    @Override
    public Account verify( String id, Credential credential ) {
        Account account = getAccount(id);
        if (account != null && verifyCredential(account, credential)) {
            return account;
        }
        return null;
    }

    @Override
    public Account verify( Credential credential ) {
        return null; // we do not accept this type of auth
    }

    public void logout( final String id ) {
        users.put(id, null);
    }

    private boolean verifyCredential( Account account, Credential credential ) {
        if (credential instanceof PasswordCredential) {
            char[] password = ((PasswordCredential)credential).getPassword();
            Pair<String, char[]> expected = users.get(account.getPrincipal().getName());
            if (expected == null) {
                expected = getPassword(account.getPrincipal().getName());
                users.put(account.getPrincipal().getName(), expected);
            }
            if (expected.key.equals(inactiveRoleName)) return false;

            char[] expectedPassword = expected.value;

            return Arrays.equals(password, expectedPassword);
        }
        return false;
    }

    private Pair<String, char[]> getPassword( final String id ) {
        try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement(
                "SELECT " + passwordColumnName + ", " + roleColumnName + " FROM " + tableName +
                        " WHERE " + loginColumnName + " = ? LIMIT 1")) {
            statement.setString(1, id);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet != null && resultSet.next()) {
                    return new Pair<>(resultSet.getString(roleColumnName),
                            resultSet.getString(passwordColumnName).toCharArray());
                } else {
                    return null;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    private Account getAccount( final String id ) {
        final Pair<String, char[]> rolePassword;
        if (users.get(id) != null) {
            rolePassword = users.get(id);
        } else {
            rolePassword = getPassword(id);
            users.put(id, rolePassword);
        }

        if (rolePassword == null) return null;

        return new Account() {
            private final Principal principal = new Principal() {
                @Override
                public String getName() {
                    return id;
                }
            };
            private Set<String> roles;

            @Override
            public Principal getPrincipal() {
                return principal;
            }

            @Override
            public synchronized Set<String> getRoles() {
                if (roles == null) {
                    roles = new HashSet<>(1);
                    roles.add(users.get(id).key);
                }
                return roles;
            }
        };
    }

    public boolean userExists( final String id ) throws SQLException {
        try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement(
                "SELECT COUNT(*) FROM " + tableName + " WHERE " + loginColumnName + " = ?")) {
            statement.setString(1, id);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) return result.getInt("COUNT(*)") > 0;
            }
        }

        throw new SQLException("userExists failed");
    }
}
