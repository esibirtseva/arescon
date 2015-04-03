package arescon;

import net.avkorneenkov.util.Pair;
import org.joda.time.DateTime;

import java.io.*;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class Data {

    public static DeviationRecord[] DEVIATION_RECORDS;
    public static long DEVIATION_START_TIME = 1409592882825L;
    public static long MONTH = 1000L * 60L * 60L * 24L * 30L;

    public static int getDevice( int type ) {
        switch (type) {
            case 0: return 1;
            case 1: return 4;
            case 2: return 3;
            case 3: return 2;
        }

        return -1;
    }

    public static Pair<Double, Integer> totalDevice( int id ) {
        double total = 0.0;
        for (double value : VALUES[id - 1]) {
            total += value;
        }
        return new Pair<>(total, VALUES[id - 1].length);
    }

    public static Pair<Double, Integer> totalType( int type ) {
        // TODO: replace with actual code
        switch (type) {
            case 0: return totalDevice(1);
            case 1: return totalDevice(4);
            case 2: return totalDevice(3);
            case 3: return totalDevice(2);
            case 4: return new Pair<>(0.0, 0);
        }

        return null;
    }

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
    public static final double[][] PERCENTAGE_VALUES = {
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
    public static final List<List<Payment>> PAYMENTS = new ArrayList<>(24);
    public static final List<List<Rate>> RATES = new ArrayList<>(4);

    public static double getMoneyMultiplier( final String type ) {
        switch (type) {
            case "0": return 0.02916;
            case "1": return 0.13579;
            case "2": return 5.18 / 1000.0;
            case "3": return 3.28;
            default: return 0;
        }
    }

    static {
        Random random = new Random();
        int maxLength = 0;
        double multiplier = 0;
        try (BufferedReader input = new BufferedReader(new InputStreamReader(new FileInputStream("data.txt"), Charset.forName("UTF-8")))) {
            for (int i = 0; i < VALUES.length; ++i) {
                switch (TYPES[i]) {
                    case "0":
                        multiplier = 1.9; // л холодной воды за 5 минут на 3 человек * 2
                        break;
                    case "1":
                        multiplier = 1.21875; // л горячей воды за 5 минут на 3 человек * 2
                        break;
                    case "2":
                        multiplier = 2.2916; // л газа за 5 минут на 2.2 человек * 2
                        break;
                    case "3":
                        multiplier = 0.05787; // кВтч электроэнергии за 5 минут на 3 человек * 2
                        break;
                }
                String[] line = input.readLine().split(", ");
                VALUES[i] = new double[line.length * 2];
                PERCENTAGE_VALUES[i] = new double[line.length * 2];
                if (line.length * 2 > maxLength) maxLength = line.length * 2;
                for (int j = 0; j < line.length * 2; ++j) {
                    //VALUES[i][j] = Double.parseDouble(line[j]);
                    VALUES[i][j] = random.nextDouble() * multiplier;
                    PERCENTAGE_VALUES[i][j] = random.nextDouble();
                }

                PAYMENTS.add(Payment.generate(START_TIMES[i], VALUES[i], getMoneyMultiplier(TYPES[i]), PERIOD * 60 * 1000));
            }
        } catch (IOException e) { e.printStackTrace(); }

        DEVIATION_RECORDS = new DeviationRecord[maxLength];
        for (int i = 0; i < DEVIATION_RECORDS.length; ++i) {
            long time = DEVIATION_START_TIME + (long)i * 1000 * 60 * 60;
            DEVIATION_RECORDS[i] = new DeviationRecord(random.nextDouble() * 2.5 - 1.0,
                    i + 1, time);
        }

        for (int i = 0; i < 4; ++i) {
            List<Rate> list = new ArrayList<>(3);
            list.add(new Rate(new DateTime(START_TIMES[0]).minusMonths(1).getMillis(),
                    new DateTime(START_TIMES[0]).plusMonths(3).getMillis(),
                    0.78 * getMoneyMultiplier(Integer.toString(i)) * (i == 3 ? 1 : 1000)));
            list.add(new Rate(new DateTime(START_TIMES[0]).plusMonths(3).getMillis(),
                    new DateTime(START_TIMES[0]).plusMonths(6).getMillis(),
                    0.88 * getMoneyMultiplier(Integer.toString(i)) * (i == 3 ? 1 : 1000)));
            list.add(new Rate(new DateTime(START_TIMES[0]).plusMonths(6).getMillis(), 0,
                    1.00 * getMoneyMultiplier(Integer.toString(i)) * (i == 3 ? 1 : 1000)));
            RATES.add(list);
        }
    }

}
