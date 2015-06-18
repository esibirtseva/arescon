package arescon;

import org.json.JSONObject;

public class ImpulseCounter {

    private static int counter = 0;

    public String ip;
    public String name;
    public int port;
    public boolean occupied;
    public int id;

    public ImpulseCounter( final String name, final String ip, final int port ) {
        this.ip = ip;
        this.port = port;
        this.occupied = false;
        this.id = ++counter;
        this.name = name;
    }

    public ImpulseCounter( final String ip, final int port ) {
        this("", ip, port);
    }

    public JSONObject toJSON( ) {
        return new JSONObject().put("ip", this.ip).put("port", port)
                .put("id", this.id).put("name", this.name + " port " + this.port);
    }

}
