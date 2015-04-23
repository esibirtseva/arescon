package arescon;

import org.joda.time.DateTime;
import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class HA {

    public final int id;
    public final String name;

    public final List<House> houses;

    public Company parent;

    public double spent = 0.0;
    public double paid = 0.0;

    public HA( final int id, final String name ) {
        this.id = id;
        this.name = name;
        houses = new ArrayList<>(10);
    }

    public void addHouse( House house ) {
        houses.add(house);
        house.parent = this;
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

        for (House house : this.houses) {
            JSONObject houseJSON = house.getTotalJSON(start, end);
            children.put(houseJSON);
            spent += houseJSON.getDouble("spentMoney");
            paid += houseJSON.getDouble("paid");
        }

        return new JSONObject().put("id", id).put("name", name).put("start", start).put("end", end)
                .put("spentMoney", spent).put("paid", paid).put("houses", children);

    }

}
