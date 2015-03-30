package arescon;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

public class Notification {

    public static int nextID = 1;

    public int id;
    public int deviceID;
    public String daterange;
    public double limit;
    public List<String> alertTypes;

    public Notification( int deviceID, String daterange, double limit, Collection<String> alertTypes ) {
        this.deviceID = deviceID;
        this.daterange = daterange;
        this.limit = limit;

        this.alertTypes = new ArrayList<String>(alertTypes);
        this.id = nextID++;
    }

    public JSONObject toJSON( ) {

        JSONArray types = new JSONArray();
        for (String alertType : alertTypes) types.put(alertType);

        return new JSONObject().put("id", id).put("deviceId", deviceID).put("datarange", daterange).put("limit", limit)
                .put("alert_type", types);
    }

}
