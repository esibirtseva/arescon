package arescon;

import org.joda.time.DateTime;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class Device {

    public final double multiplier;

    public final int id;
    public final int type;
    public final long start;
    public final long period;
    public final List<Double> values;
    public final List<Payment> payments;

    public double spentValue;
    public double spentMoney;

    public Flat parent;

    public Device( final int id, final long period ) {
        this.id = id;
        this.period = period * 60000;
        this.type = Integer.parseInt(Data.TYPES[id - 1]);
        this.start = Data.START_TIMES[id - 1];
        this.values = new ArrayList<>(Data.VALUES[id - 1].length);
        this.multiplier = Data.getMoneyMultiplier(Data.TYPES[id - 1]);

        for (double value : Data.VALUES[id - 1]) this.values.add(value);
        this.payments = Payment.generate(this.start, Data.VALUES[id - 1], this.multiplier, this.period);

        this.spentValue = getTotalSpent(0L, 99999999999999L, false);
        this.spentMoney = this.spentValue * this.multiplier;
    }

    public Device( final int id ) {
        this(id, Data.PERIOD);
    }

    public synchronized void spend( double... values ) {
        double total = 0.0;
        for (double value : values) {
            total += value;
            this.values.add(value);
        }

        this.spentValue += total;
        double totalMoney = total * this.multiplier;
        this.spentMoney += totalMoney;
        parent.spend(totalMoney);
    }

    public double getTotalSpent( long start, long end, final boolean money ) {

        if (start < this.start) start = this.start;
        if (end > new DateTime().getMillis()) end = new DateTime().getMillis();

        start = (start - this.start) / this.period;
        end = (end - this.start) / this.period;

        double total = 0.0;
        double multiplier = money ? this.multiplier : 1.0;

        for (long i = start; i < end && i < this.values.size(); ++i) {
            total += this.values.get((int)i) * multiplier;
        }

        return total;
    }

    public double getTotalPaid( long start, long end ) {

        if (start < this.start) start = this.start;
        if (end > new DateTime().getMillis()) end = new DateTime().getMillis();

        double total = 0.0;

        for (Payment p : this.payments) {
            if (p.timestamp >= start && p.timestamp < end) total += p.paid;
        }

        return total;
    }

    public JSONObject getTotalJSON( long start, long end ) {
        if (start < this.start) start = this.start;
        if (end > new DateTime().getMillis()) end = new DateTime().getMillis();

        double spent = getTotalSpent(start, end, false);
        double paid = getTotalPaid(start, end);

        // TODO: date-based multipliers...
        return new JSONObject().put("id", id).put("type", type).put("start", start).put("end", end)
                .put("spentValue", spent).put("spentMoney", spent * this.multiplier).put("paid", paid);
    }

    public String toString( ) {
        return getTotalJSON(0L, 99999999999999L).toString();
    }
}
