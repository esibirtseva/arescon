package arescon;

import java.io.*;
import java.nio.charset.Charset;

public class Data {

    public static final long PERIOD = 5;
    public static final long[] START_TIMES = { 1409592882825l, 1409592883717l, 1409592884343l, 1409592884494l, 1409592884612l, 1409592884735l, 1409592884846l, 1409592884962l, 1409592885040l, 1409592885130l, 1409592885209l, 1409592885290l };
    public static final String[] TYPES = { "0", "3", "2", "1", "1", "3", "2", "0", "3", "3", "1", "2" };
    public static final String[] MEASURES = { "", "", "", "", "", "", "", "", "", "", "", "" };
    public static final String[] NAMES = { "", "", "", "", "", "", "", "", "", "", "", "" };
    public static final double[][] VALUES = {
            { },
            { },
            { },
            { },
            { },
            { },
            { },
            { },
            { },
            { },
            { },
            { }
    };

    static {
        try (BufferedReader input = new BufferedReader(new InputStreamReader(new FileInputStream("data.txt"), Charset.forName("UTF-8")))) {
            for (int i = 0; i < VALUES.length; ++i) {
                String[] line = input.readLine().split(", ");
                VALUES[i] = new double[line.length];
                for (int j = 0; j < line.length; ++j) {
                    VALUES[i][j] = Double.parseDouble(line[j]);
                }
            }
        } catch (IOException e) { e.printStackTrace(); }
    }

}
