package arescon;

import org.joda.time.DateTime;

import java.util.ArrayList;
import java.util.List;

public class Counter {

    public int type;
    public String id;
    public long start;
    public long end;
    public long nextCheck;
    public int odnFlag;
    public int rateFlag;
    public int resolution;
    public int transform;
    public boolean periodic;

    public String name;

    public boolean deleted;

    public long period = Data.PERIOD * 1000 * 60;

    private long checkPeriod;
    private long nextTimestamp;

    public final List<CounterValue> values;
    public final List<Payment> payments;

    public Counter( String id, int type, long nextCheck, int odnFlag, int rateFlag, int resolution, int transform, boolean periodic ) {
        this.id = id;
        this.type = type;
        this.odnFlag = odnFlag;
        this.rateFlag = rateFlag;
        this.resolution = resolution;
        this.transform = transform;
        this.periodic = periodic;
        this.deleted = false;
        this.name = "Counter";

        this.nextTimestamp = this.start = new DateTime().getMillis();
        this.nextCheck = nextCheck;

        values = new ArrayList<>();
        payments = new ArrayList<>();
    }

    public Counter( String id, int type, long nextCheck, int odnFlag, int rateFlag, int resolution, int transform, boolean periodic, long start ) {
        this(id, type, nextCheck, odnFlag, rateFlag, resolution, transform, periodic);
        this.nextTimestamp = this.start = start;
    }

    public Counter( String id, int type, long nextCheck, int odnFlag, int rateFlag, int resolution, int transform, boolean periodic, long start, String name ) {
        this(id, type, nextCheck, odnFlag, rateFlag, resolution, transform, periodic, start);
        this.name = name;
    }

    public Counter( String id, int type, long nextCheck, int odnFlag, int rateFlag, int resolution, int transform, boolean periodic, String name ) {
        this(id, type, nextCheck, odnFlag, rateFlag, resolution, transform, periodic);
        this.name = name;
    }

    public void addValue( double value ) {
        this.values.add(new CounterValue(value, nextTimestamp));
        nextTimestamp += this.period;
    }

    public void addValue( double value, long timestamp ) {
        this.values.add(new CounterValue(value, timestamp));
        nextTimestamp = timestamp + period;
    }

    public double[] getValues( ) {
        double[] result = new double[this.values.size()];
        for (int i = 0; i < result.length; ++i) {
            result[i] = this.values.get(i).value;
        }

        return result;
    }

}
