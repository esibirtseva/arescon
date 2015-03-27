package arescon;

import org.joda.time.DateTime;
import org.json.JSONObject;

import java.util.LinkedList;
import java.util.List;
import java.util.Random;

public class Payment {

    public long timestamp;
    public double spent;
    public double paid;

    public Payment( long timestamp, double spent, double paid ) {
        this.timestamp = timestamp;
        this.spent = spent;
        this.paid = paid;
    }

    public JSONObject toJSON( ) {
        return new JSONObject().put("time", timestamp).put("spent", String.format("%.2f", spent))
                .put("paid", String.format("%.2f", paid));
    }

    public static JSONObject sum( Iterable<Payment> collection ) {
        double spent = 0.0;
        double paid = 0.0;
        for (Payment p : collection) {
            spent += p.spent;
            paid += p.paid;
        }
        return new JSONObject().put("spent", String.format("%.2f", spent))
                .put("paid", String.format("%.2f", paid));
    }

    public static List<Payment> generate( long start, double[] data, double multiplier, long period ) {
        Random rng = new Random();
        List<Payment> result = new LinkedList<>();
        double balance = 0.0;
        DateTime timestamp = new DateTime(start).plusMonths(1);
        int i = 0;
        for (; timestamp.getMillis() < new DateTime().getMillis(); timestamp = timestamp.plusMonths(1)) {
            double spent = 0.0;
            for (; i < data.length && start < timestamp.getMillis(); start += period, ++i) {
                spent += data[i] * multiplier;
            }
            result.add(new Payment(timestamp.getMillis(), spent, 0.0));
        }

        for (Payment p : result) {
            balance += p.spent;
            double decision = rng.nextDouble();
            if (decision <= 0.2) {
                p.paid = balance;
                balance = 0.0;
            } else if (decision <= 0.5) {
                p.paid = p.spent;
                balance -= p.spent;
            }
        }

        return result;
    }

}
