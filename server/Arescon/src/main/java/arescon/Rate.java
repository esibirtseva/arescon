package arescon;

import org.json.JSONObject;

import java.util.Random;

public class Rate {

    private static Random rng = new Random();

    public long start;
    public long end;
    public double rateDay;
    public double rateNight;
    public double ratePref;

    public Rate( long start, long end, double rate ) {
        this.start = start;
        this.end = end;
        this.rateDay = rate;
        this.rateNight = rate * (rng.nextDouble() * 0.5 + 0.5);
        this.ratePref = (this.rateDay + this.rateNight) * 0.3;
    }

    public JSONObject toJSON( ) {
        return new JSONObject().put("start", start).put("end", end)
                .put("rateDay", String.format("%.2f", rateDay))
                .put("rateNight", String.format("%.2f", rateNight))
                .put("ratePref", String.format("%.2f", ratePref));
    }

}
