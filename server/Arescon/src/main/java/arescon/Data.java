package arescon;

import net.avkorneenkov.util.Pair;
import org.joda.time.DateTime;

import java.io.*;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class Data {

    public static Flat userFlat;
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

    public static String getTypeName( int type ) {
        switch (type) {
            case 0: return "Холодная вода";
            case 1: return "Горячая вода";
            case 2: return ""; // gas
            case 3: return ""; // electricity
            case 4: return "";
        }

        return "";
    }

    public static String getTypeImage( int type ) {
        switch (type) {
            case 0: return "/images/water.jpg";
            case 1: return "/images/water-2.jpeg";
            case 2: return "/images/gas.jpg";
            case 3: return "/images/electro.jpg";
            case 4: return "";
        }

        return "";
    }

    public static Pair<Double, Integer> totalDevice( int id, boolean money ) {
        double total = 0.0;
        Counter counter = COUNTER_DEVICES.get(id - 1);
        double multiplier = money ? getMoneyMultiplier(counter.type) : 1.0;
        for (CounterValue value : counter.values) {
            total += value.value * multiplier;
        }
        return new Pair<>(total, counter.values.size());
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

    public static final List<Counter> COUNTER_DEVICES = new ArrayList<>(10);
    public static final List<ImpulseCounter> IMPULSE_COUNTERS = new ArrayList<>(4);

    public static double getMoneyMultiplier( final String type ) {
        switch (type) {
            case "0": return 0.02916;
            case "1": return 0.13579;
            case "2": return 5.18 / 1000.0;
            case "3": return 3.28;
            default: return 0;
        }
    }

    public static double getMoneyMultiplier( final int type ) {
        return getMoneyMultiplier(Integer.toString(type));
    }

    public static void reboot( ) {
        for (Counter counter : COUNTER_DEVICES) {
            counter.deleted = false;
        }

        DEVIATION_RECORDS = new DeviationRecord[maxLength];
        for (int i = 0; i < DEVIATION_RECORDS.length; ++i) {
            long time = DEVIATION_START_TIME + (long)i * 1000 * 60 * 60;
            DEVIATION_RECORDS[i] = new DeviationRecord(random.nextDouble() * 2.5 - 1.0,
                    i + 1, time);
        }
    }

    static {

        // 1409592882825l
        // public static final String[] TYPES = { "0", "3", "2", "1", "1", "3", "2", "0", "3", "3", "1", "2", "0", "3", "2", "1", "1", "3", "2", "0", "3", "3", "1", "2" };

        IMPULSE_COUNTERS.add(new ImpulseCounter("Impulse Counter 1", "xxx.xxx.xxx.xxx", 2));
        IMPULSE_COUNTERS.get(0).occupied = 2;
        IMPULSE_COUNTERS.add(new ImpulseCounter("Impulse Counter 2", "xxx.xxx.xxx.yyy", 2));
        IMPULSE_COUNTERS.get(1).occupied = 2;
        IMPULSE_COUNTERS.add(new ImpulseCounter("Impulse Counter 3", "xxx.xxx.xxx.zzz", 2));
        IMPULSE_COUNTERS.add(new ImpulseCounter("Impulse Counter 4", "xxx.xxx.xxx.aaa", 2));


        long goodTime = new DateTime(1409518800000l).minusHours(new DateTime(1409518800000l).getHourOfDay()).getMillis();

        COUNTER_DEVICES.add(new Counter("1", 0, 0, 0, 1, 1, 1, true, goodTime, "Счетчик Techem AP"));
        COUNTER_DEVICES.add(new Counter("2", 3, 0, 0, 1, 1, 1, true, 1409592882825l, "Счетчик однофазный СОЭ-52"));
        COUNTER_DEVICES.add(new Counter("3", 2, 0, 0, 1, 1, 1, true, 1409592882825l, "Счетчик ГРАНД-25Т"));
        COUNTER_DEVICES.add(new Counter("4", 1, 0, 0, 1, 1, 1, true, 1409592882825l, "Счетчик СВ-15 Х \"МЕТЕР\""));
        COUNTER_DEVICES.add(new Counter("5", 1, 0, 0, 1, 1, 1, true, 1409592882825l, "Счетчик 5"));
        COUNTER_DEVICES.add(new Counter("6", 3, 0, 0, 1, 1, 1, true, 1409592882825l, "Счетчик 6"));
        COUNTER_DEVICES.add(new Counter("7", 2, 0, 0, 1, 1, 1, true, 1409592882825l, "Счетчик 7"));
        COUNTER_DEVICES.add(new Counter("8", 0, 0, 0, 1, 1, 1, true, 1409592882825l, "Счетчик 8"));
        COUNTER_DEVICES.add(new Counter("9", 3, 0, 0, 1, 1, 1, true, 1409592882825l, "Счетчик 9"));
        COUNTER_DEVICES.add(new Counter("10", 3, 0, 0, 1, 1, 1, true, 1409592882825l, "Счетчик 10"));
        COUNTER_DEVICES.add(new Counter("11", 1, 0, 0, 1, 1, 1, true, 1409592882825l, "Счетчик 11"));
        COUNTER_DEVICES.add(new Counter("12", 2, 0, 0, 1, 1, 1, true, 1409592882825l, "Счетчик 12"));
        COUNTER_DEVICES.add(new Counter("13", 0, 0, 0, 1, 1, 1, true, 1409592882825l, "Счетчик 13"));
        COUNTER_DEVICES.add(new Counter("14", 3, 0, 0, 1, 1, 1, true, 1409592882825l, "Счетчик 14"));
        COUNTER_DEVICES.add(new Counter("15", 2, 0, 0, 1, 1, 1, true, 1409592882825l, "Счетчик 15"));
        COUNTER_DEVICES.add(new Counter("16", 1, 0, 0, 1, 1, 1, true, 1409592882825l, "Счетчик 16"));
        COUNTER_DEVICES.add(new Counter("17", 1, 0, 0, 1, 1, 1, true, 1409592882825l, "Счетчик 17"));
        COUNTER_DEVICES.add(new Counter("18", 3, 0, 0, 1, 1, 1, true, 1409592882825l, "Счетчик 18"));
        COUNTER_DEVICES.add(new Counter("19", 2, 0, 0, 1, 1, 1, true, 1409592882825l, "Счетчик 19"));
        COUNTER_DEVICES.add(new Counter("20", 0, 0, 0, 1, 1, 1, true, 1409592882825l, "Счетчик 20"));
        COUNTER_DEVICES.add(new Counter("21", 3, 0, 0, 1, 1, 1, true, 1409592882825l, "Счетчик 21"));
        COUNTER_DEVICES.add(new Counter("22", 3, 0, 0, 1, 1, 1, true, 1409592882825l, "Счетчик 22"));
        COUNTER_DEVICES.add(new Counter("23", 1, 0, 0, 1, 1, 1, true, 1409592882825l, "Счетчик 23"));
        COUNTER_DEVICES.add(new Counter("24", 2, 0, 0, 1, 1, 1, true, 1409592882825l, "Счетчик 24"));

        List<Double> realData = new ArrayList<>(500);

        try (BufferedReader input = new BufferedReader(new InputStreamReader(new FileInputStream("realdata.txt"), Charset.forName("UTF-8")))) {

            while (input.ready()) {
                String line = input.readLine().trim();
                double val = Double.parseDouble(line) / 2.0;
                realData.add(val);
                realData.add(val);
            }

        } catch (IOException e) { e.printStackTrace(); }

        double multiplier = 0;
        try (BufferedReader input = new BufferedReader(new InputStreamReader(new FileInputStream("data.txt"), Charset.forName("UTF-8")))) {
            int i = 0;
            for (; i < COUNTER_DEVICES.size() / 2; ++i) {
                switch (COUNTER_DEVICES.get(i).type) {
                    case 0:
                        multiplier = 1.9; // л холодной воды за 5 минут на 3 человек * 2
                        break;
                    case 1:
                        multiplier = 1.21875; // л горячей воды за 5 минут на 3 человек * 2
                        break;
                    case 2:
                        multiplier = 2.2916; // л газа за 5 минут на 2.2 человек * 2
                        break;
                    case 3:
                        multiplier = 0.05787; // кВтч электроэнергии за 5 минут на 3 человек * 2
                        break;
                }
                String[] line = input.readLine().split(", ");
                PERCENTAGE_VALUES[i] = new double[line.length * 2];
                if (line.length * 2 > maxLength) maxLength = line.length * 2;
                for (int j = 0; j < line.length * 2; ++j) {
                    if (i == 0) {
                        COUNTER_DEVICES.get(0).addValue(realData.get(j % realData.size()));
                    } else {
                        COUNTER_DEVICES.get(i).addValue(random.nextDouble() * multiplier);
                    }
                    PERCENTAGE_VALUES[i][j] = random.nextDouble();
                }

                PAYMENTS.add(Payment.generate(COUNTER_DEVICES.get(i), getMoneyMultiplier(COUNTER_DEVICES.get(i).type)));
            }
            for (; i < COUNTER_DEVICES.size(); ++i) {
                PAYMENTS.add(new ArrayList<Payment>());
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
            list.add(new Rate(new DateTime(1409592882825l).minusMonths(1).getMillis(),
                    new DateTime(1409592882825l).plusMonths(3).getMillis(),
                    0.78 * getMoneyMultiplier(Integer.toString(i)) * (i == 3 ? 1 : 1000)));
            list.add(new Rate(new DateTime(1409592882825l).plusMonths(3).getMillis(),
                    new DateTime(1409592882825l).plusMonths(6).getMillis(),
                    0.88 * getMoneyMultiplier(Integer.toString(i)) * (i == 3 ? 1 : 1000)));
            list.add(new Rate(new DateTime(1409592882825l).plusMonths(6).getMillis(), 0,
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
        flats[2].addDevice(5);
        flats[2].addDevice(6);
        flats[3] = new Flat(4, 20);
        flats[3].addDevice(1);
        flats[3].addDevice(2);
        flats[3].addDevice(3);
        flats[3].addDevice(4);

        userFlat = flats[3];

        House[] houses = new House[4];
        houses[0] = new House("Минусинская улица, д. 37", 1, "55.71855041425817", "37.66815246582029");
        houses[0].addFlat(flats[3]);
        houses[1] = new House("Нежинская улица, д. 13", 2, "55.78283647321973", "37.55691589355467");
        houses[1].addFlat(flats[2]);
        houses[2] = new House("Башиловская улица, д. 15", 3, "55.706921098504964", "37.470398559570306");
        houses[2].addFlat(flats[0]);
        houses[3] = new House("Иловайская улица, д. 3", 4, "55.87404807445789", "37.690125122070306");
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
