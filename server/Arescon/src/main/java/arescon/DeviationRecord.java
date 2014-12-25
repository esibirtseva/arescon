package arescon;

public class DeviationRecord {

    double value;
    String name;
    int id;
    long time;

    DeviationRecord( double value, int id, long time ) {
        this.value = value;
        this.name = "record";
        this.id = id;
        this.time = time;
    }

    @Override
    public String toString( ) {
        return "{\'id\':\'" + this.id + "\',\'time\':\'" + this.time + "\',\'name\':\'" + this.name +
                "\',\'value\':\'" + this.value + "\'}";
    }

}
