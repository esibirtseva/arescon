package arescon;

import java.io.*;
import java.nio.charset.Charset;
import java.util.Random;

public class Data {

    public static DeviationRecord[] DEVIATION_RECORDS;
    public static long DEVIATION_START_TIME = 1409592882825l;

    public static final long PERIOD = 5;
    public static final boolean[] DELETED = { false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false };
    public static final long[] START_TIMES = { 1409592882825l, 1409592883717l, 1409592884343l, 1409592884494l, 1409592884612l, 1409592884735l, 1409592884846l, 1409592884962l, 1409592885040l, 1409592885130l, 1409592885209l, 1409592885290l, 1409592882825l, 1409592883717l, 1409592884343l, 1409592884494l, 1409592884612l, 1409592884735l, 1409592884846l, 1409592884962l, 1409592885040l, 1409592885130l, 1409592885209l, 1409592885290l };
    public static final String[] TYPES = { "0", "3", "2", "1", "1", "3", "2", "0", "3", "3", "1", "2", "0", "3", "2", "1", "1", "3", "2", "0", "3", "3", "1", "2" };
    public static final String[] MEASURES = { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" };
    public static final String[] NAMES = { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" };
    public static final double[][] VALUES = {
            { },{ },
            { },{ },
            { },{ },
            { },{ },
            { },{ },
            { },{ },
            { },{ },
            { },{ },
            { },{ },
            { },{ },
            { },{ },
            { },{ }
    };

    static {
        Random random = new Random();
        int maxLength = 0;
        try (BufferedReader input = new BufferedReader(new InputStreamReader(new FileInputStream("data.txt"), Charset.forName("UTF-8")))) {
            for (int i = 0; i < VALUES.length; ++i) {
                String[] line = input.readLine().split(", ");
                VALUES[i] = new double[line.length];
                if (line.length > maxLength) maxLength = line.length;
                for (int j = 0; j < line.length; ++j) {
                    VALUES[i][j] = Double.parseDouble(line[j]);
                }
            }
        } catch (IOException e) { e.printStackTrace(); }

        DEVIATION_RECORDS = new DeviationRecord[maxLength];
        for (int i = 0; i < DEVIATION_RECORDS.length; ++i) {
            DEVIATION_RECORDS[i] = new DeviationRecord(random.nextDouble() * 2.5 - 1.0,
                    i + 1, DEVIATION_START_TIME + i * 1000 * 60 * 60);
        }
    }

}
