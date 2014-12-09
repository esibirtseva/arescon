package net.avkorneenkov;

public class DebugUtil {

    // constructs a basic IllegalArgumentException from a method name, its contract and actual parameters
    public static IllegalArgumentException buildArgException( final String methodName,
                                                              final String contract,
                                                              final Object... params ) {
        StringBuilder stringBuilder = new StringBuilder("\n");
        stringBuilder.append(contract);
        stringBuilder.append('\n');
        stringBuilder.append(methodName);
        stringBuilder.append('(');
        if (params.length != 0) {
            stringBuilder.append('\n');
            for (final Object param : params) {
                stringBuilder.append(param.toString()).append(",\n");
            }
        }
        stringBuilder.append(");");

        return new IllegalArgumentException(stringBuilder.toString());
    }

}
