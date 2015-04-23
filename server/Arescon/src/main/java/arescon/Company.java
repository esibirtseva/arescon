package arescon;

import org.joda.time.DateTime;
import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class Company {

    public final List<HA> HAs;

    public final int id;

    public double spent = 0.0;
    public double paid = 0.0;

    public Company( final int id ) {
        this.id = id;
        HAs = new ArrayList<>(10);
    }

    public void addHA( HA ha ) {
        HAs.add(ha);
        ha.parent = this;
    }

    public synchronized void pay( final double value ) {
        this.paid += value;
    }

    public synchronized void spend( final double value ) {
        this.spent += value;
    }

    public JSONObject getTotalJSON( long start, long end ) {

        if (end > new DateTime().getMillis()) end = new DateTime().getMillis();

        double spent = 0.0;
        double paid = 0.0;
        JSONArray children = new JSONArray();

        for (HA ha : this.HAs) {
            JSONObject HAJSON = ha.getTotalJSON(start, end);
            children.put(HAJSON);
            spent += HAJSON.getDouble("spentMoney");
            paid += HAJSON.getDouble("paid");
        }

        return new JSONObject().put("id", id).put("start", start).put("end", end).put("spentMoney", spent)
                .put("paid", paid).put("HAs", children);
    }

}
