package arescon;

import org.json.JSONObject;

public class ImpulseCounter {

    private static int counter = 0;

    public String ip;
    public String name;
    public int ports;
    public int occupied;
    public int id;

    public ImpulseCounter( final String name, final String ip, final int ports ) {
        this.ip = ip;
        this.ports = ports;
        this.occupied = 0;
        this.id = ++counter;
        this.name = name;
    }

    public ImpulseCounter( final String ip, final int ports ) {
        this("", ip, ports);
    }

    public JSONObject toJSON( ) {
        return new JSONObject().put("ip", this.ip).put("ports", ports)
                .put("free", this.ports - this.occupied).put("id", this.id).put("name", this.name);
    }

}
