package arescon;

import org.joda.time.DateTime;
import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class Flat {

    public final int id;
    public final int number;

    public final List<Device> devices;
    public House parent;

    public double spent = 0.0;
    public double paid = 0.0;

    public Flat( final int id, final int number ) {
        this.number = number;
        this.id = id;
        devices = new ArrayList<>(10);
    }

    public void addDevice( final Device device ) {
        devices.add(device);
        device.parent = this;
        this.spent += device.spentMoney;
    }

    public void addDevice( final int id ) {
        addDevice(new Device(id));
    }

    public double getBalance( ) {
        return paid - spent;
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

        for (Device device : this.devices) {
            JSONObject deviceJSON = device.getTotalJSON(start, end);
            children.put(deviceJSON);
            spent += deviceJSON.getDouble("spentMoney");
            paid += deviceJSON.getDouble("paid");
        }

        return new JSONObject().put("id", id).put("number", number).put("start", start).put("end", end)
                .put("spentMoney", spent).put("paid", paid).put("services", children);
    }

}
