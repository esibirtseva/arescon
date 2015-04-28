package arescon;

import org.joda.time.DateTime;
import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class Company {

    static int count = 0;
    static ArrayList<Company> all = new ArrayList<>(1);

    public final List<HA> HAs;

    public final int id;

    public double spent = 0.0;
    public double paid = 0.0;

    public Company( final int id ) {
        this.id = id;
        HAs = new ArrayList<>(10);
        ++Company.count;
        all.add(this);
    }

    public Company( ) {
        this(Company.count + 1);
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

    public JSONObject getTotalJSON( long start, long end, int type ) {

        if (end > new DateTime().getMillis()) end = new DateTime().getMillis();

        double spentMoney = 0.0;
        double spentValue = 0.0;
        double paid = 0.0;
        JSONArray children = new JSONArray();

        for (HA ha : this.HAs) {
            JSONObject HAJSON = ha.getTotalJSON(start, end, type);
            children.put(HAJSON);
            spentMoney += HAJSON.getDouble("spentMoney");
            spentValue += HAJSON.getDouble("spentValue");
            paid += HAJSON.getDouble("paid");
        }

        return new JSONObject().put("id", id).put("start", start).put("end", end).put("spentMoney", spentMoney)
                .put("paid", paid).put("HAs", children).put("type", type).put("spentValue", spentValue);
    }

}
