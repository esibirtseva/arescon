package arescon;

import org.joda.time.DateTime;
import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class House {

    public final int id;

    public final String address;
    public final String x, y;
    public final List<Flat> flats;

    public HA parent;

    public double spent = 0.0;
    public double paid = 0.0;

    public House( final String address, final int id, final String x, final String y ) {
        this.address = address;
        this.id = id;
        this.x = x;
        this.y = y;
        this.flats = new ArrayList<>(10);

    }

    public void addFlat( Flat flat ) {
        flats.add(flat);
        flat.parent = this;
    }

    public synchronized void pay( final double value ) {
        this.paid += value;
        parent.pay(value);
    }

    public synchronized void spend( final double value ) {
        this.spent += value;
        parent.spend(value);
    }

    public JSONObject getTotalJSON( long start, long end ) {

        if (end > new DateTime().getMillis()) end = new DateTime().getMillis();

        double spent = 0.0;
        double paid = 0.0;
        JSONArray children = new JSONArray();

        for (Flat flat : this.flats) {
            JSONObject flatJSON = flat.getTotalJSON(start, end);
            children.put(flatJSON);
            spent += flatJSON.getDouble("spentMoney");
            paid += flatJSON.getDouble("paid");
        }

        return new JSONObject().put("id", id).put("address", address).put("x", x).put("y", y).put("start", start)
                .put("end", end).put("spentMoney", spent).put("paid", paid).put("flats", children);

    }

}
