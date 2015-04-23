package arescon;

import net.avkorneenkov.util.Pair;
import org.joda.time.DateTime;

import java.io.*;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class Data {

    public static Company company;

    static int maxLength = 0;
    static Random random = new Random();

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

    public static Pair<Double, Integer> totalDevice( int id, boolean money ) {
        double total = 0.0;
        double multiplier = money ? getMoneyMultiplier(TYPES[id - 1]) : 1.0;
        for (double value : VALUES[id - 1]) {
            total += value * multiplier;
        }
        return new Pair<>(total, VALUES[id - 1].length);
    }

    public static Pair<Double, Integer> totalType( int type, boolean money ) {
        // TODO: replace with actual code
        switch (type) {
            case 0: return totalDevice(1, money);
            case 1: return totalDevice(4, money);
            case 2: return totalDevice(3, money);
            case 3: return totalDevice(2, money);
            case 4: return new Pair<>(0.0, 0);
        }

        return null;
    }

    private static double _totalFlat = Double.NaN;

    public static synchronized double totalFlat( boolean money ) {
        if (Double.isNaN(_totalFlat)) {
            _totalFlat = 0.0;
            for (int i = 1; i < 5; ++i) _totalFlat += totalDevice(i, money).key;
        }

        return _totalFlat;
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

    public static void reboot( ) {
        for (int i = 0; i < DELETED.length; ++i) {
            DELETED[i] = false;
        }

        DEVIATION_RECORDS = new DeviationRecord[maxLength];
        for (int i = 0; i < DEVIATION_RECORDS.length; ++i) {
            long time = DEVIATION_START_TIME + (long)i * 1000 * 60 * 60;
            DEVIATION_RECORDS[i] = new DeviationRecord(random.nextDouble() * 2.5 - 1.0,
                    i + 1, time);
        }
    }

    static {
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

    static {

        Flat[] flats = new Flat[4];
        flats[0] = new Flat(1, 65);
        flats[0].addDevice(7);
        flats[0].addDevice(8);
        flats[0].addDevice(9);
        flats[1] = new Flat(2, 32);
        flats[1].addDevice(10);
        flats[1].addDevice(11);
        flats[1].addDevice(12);
        flats[2] = new Flat(3, 145);
        flats[2].addDevice(4);
        flats[2].addDevice(5);
        flats[2].addDevice(6);
        flats[3] = new Flat(4, 20);
        flats[3].addDevice(1);
        flats[3].addDevice(2);
        flats[3].addDevice(3);

        House[] houses = new House[4];
        houses[0] = new House("Минусинская улица, д. 37", 1);
        houses[0].addFlat(flats[3]);
        houses[1] = new House("Нежинская улица, д. 13", 2);
        houses[1].addFlat(flats[2]);
        houses[2] = new House("Башиловская улица, д. 15", 3);
        houses[2].addFlat(flats[0]);
        houses[3] = new House("Иловайская улица, д. 3", 4);
        houses[3].addFlat(flats[1]);

        HA[] HAs = new HA[2];
        HAs[0] = new HA(1, "ТСЖ2");
        HAs[0].addHouse(houses[0]);
        HAs[0].addHouse(houses[1]);
        HAs[1] = new HA(2, "ТСЖ1");
        HAs[1].addHouse(houses[2]);
        HAs[1].addHouse(houses[3]);

        company = new Company(1);
        for (HA ha : HAs) company.addHA(ha);

    }

}
