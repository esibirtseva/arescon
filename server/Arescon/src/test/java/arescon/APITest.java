package arescon;

public class APITest {

    public static void main( String[] args ) throws Throwable {

        API api = new API(null, null);

        System.out.println(api.getDeviceData(1, 1415352882825l, -1, 24 * 60));
    }

}
