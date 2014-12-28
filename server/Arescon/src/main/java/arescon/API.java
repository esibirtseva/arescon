package arescon;

import io.undertow.security.api.SecurityContext;
import io.undertow.security.idm.Account;
import io.undertow.security.idm.PasswordCredential;
import io.undertow.server.HttpServerExchange;
import io.undertow.server.handlers.Cookie;
import io.undertow.server.handlers.CookieImpl;
import io.undertow.server.handlers.form.FormData;
import io.undertow.util.Headers;
import io.undertow.util.Methods;
import io.undertow.util.StatusCodes;
import jdk.nashorn.internal.parser.JSONParser;
import net.avkorneenkov.NetUtil;
import net.avkorneenkov.SQLUtil;
import net.avkorneenkov.undertow.DatabaseIdentityManager;
import net.avkorneenkov.undertow.UndertowUtil;
import org.apache.commons.codec.digest.DigestUtils;
import org.joda.time.DateTime;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.security.SecureRandom;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;

public class API {

    private DatabaseIdentityManager identityManager;
    private Random random;
    private Util util;

    public API( DatabaseIdentityManager identityManager, Util util ) {
        this.identityManager = identityManager;
        this.util = util;
        this.random = new SecureRandom();
    }

    double[] getProfile( double[] data, int period, int count ) {
        double[] profile = new double[count];
        int len = count * period;
        int iterations = data.length / len;
        for (int j = 0; j + period <= len; j += period) {
            double value = 0.0;
            for (int k = 0; k < iterations; ++k) {
                for (int i = 0; i < period; ++i) {
                    value += data[k * len + j + i];
                }
            }
            profile[j / period] = value / iterations;
        }
        return profile;
    }

    void getProfile( double[] data, int period, int count, double[] profile ) {
        int len = count * period;
        int iterations = data.length / len;
        for (int j = 0; j + period <= len; j += period) {
            double value = 0.0;
            for (int k = 0; k < iterations; ++k) {
                for (int i = 0; i < period; ++i) {
                    value += data[k * len + j + i];
                }
            }
            profile[j / period] += value / iterations;
        }
    }

    private String getDeviceProfile( int id, long startTime, long endTime, int period, int count, int expected, double multiplier ) {
        if (startTime < Data.START_TIMES[id - 1]) startTime = Data.START_TIMES[id - 1];

        period /= (int) Data.PERIOD;
        if (period < 1) period = 1;
        double[] values = Data.VALUES[id - 1];

        StringBuilder response = new StringBuilder("{\"start\":");
        response.append("\"").append(startTime).append("\",\"id\":\"").append(id).append("\",\"period\":\"");
        response.append(period * Data.PERIOD).append("\",\"name\":\"").append(Data.NAMES[id - 1]).append("\",\"type\":\"");
        response.append(Data.TYPES[id - 1]).append("\",\"values\":");

        startTime = (startTime - Data.START_TIMES[id - 1]) / 60000 / Data.PERIOD;
        endTime = (endTime - Data.START_TIMES[id - 1]) / 60000 / Data.PERIOD;

        JSONArray list = new JSONArray();

        double[] profile = getProfile(
                Arrays.copyOfRange(values, (int) startTime, (int) Math.min(endTime, values.length)),
                period, count);

        for (int i = 0; i < expected; ++i) {
            if (Double.isFinite(profile[i % profile.length])) list.put(profile[i % profile.length] * multiplier);
        }

        return response.append(list.toString()).append("}").toString();
    }

    private String getTypeProfile( int id, long startTime, long endTime, int period, int count, int expected, double multiplier ) {
        period /= (int)Data.PERIOD;
        if (period < 1) period = 1;
        List<double[]> values = new ArrayList<>();
        List<Long> dataStartTimes = new ArrayList<>();
        long dataStartTime = Long.MAX_VALUE;
        int topLength = 0;
        for (int i = 0; i < 4; ++i) {
            if (Data.TYPES[i].equals(Integer.toString(id))) {
                if (Data.START_TIMES[i] < dataStartTime) dataStartTime = Data.START_TIMES[i];
                if (Data.VALUES[i].length > topLength) topLength = Data.VALUES[i].length;
                dataStartTimes.add(Data.START_TIMES[i] / 60000 / Data.PERIOD);
                values.add(Data.VALUES[i]);
            }
        }

        if (startTime < dataStartTime) startTime = dataStartTime;

        StringBuilder response = new StringBuilder("{\"start\":");
        response.append("\"").append(startTime).append("\",\"period\":\"");
        response.append(period * Data.PERIOD).append("\",\"type\":\"");
        response.append(id).append("\",\"values\":");

        startTime = (startTime) / 60000 / Data.PERIOD;
        endTime = (endTime) / 60000 / Data.PERIOD;

        JSONArray list = new JSONArray();

        double[] profile = new double[count];
        Arrays.fill(profile, 0.0);

        for (int i = 0; i < values.size(); ++i) {
            getProfile(Arrays.copyOfRange(
                            values.get(i),
                            (int)Math.max(0, startTime - dataStartTimes.get(i)),
                            (int)Math.min(values.get(i).length, endTime - dataStartTimes.get(i))),
                    period, count, profile);
        }

        if (values.size() > 0) {
            for (int i = 0; i < expected; ++i) {
                if (Double.isFinite(profile[i % profile.length])) list.put(profile[i % profile.length] * multiplier / values.size());
            }
        }

        return response.append(list.toString()).append("}").toString();
    }

    private String getHouseProfile( Set<Integer> types, long startTime, long endTime, int period, int count, int expected, double multiplier ) {
        period /= (int)Data.PERIOD;
        if (period < 1) period = 1;
        List<double[]> values = new ArrayList<>();
        List<Long> dataStartTimes = new ArrayList<>();
        List<Integer> dataTypes = new ArrayList<>();
        long dataStartTime = Long.MAX_VALUE;
        int topLength = 0;
        for (int i = 0; i < 4; ++i) {
            if (Data.START_TIMES[i] < dataStartTime) dataStartTime = Data.START_TIMES[i];
            if (Data.VALUES[i].length > topLength) topLength = Data.VALUES[i].length;
            dataStartTimes.add(Data.START_TIMES[i] / 60000 / Data.PERIOD);
            values.add(Data.VALUES[i]);
            dataTypes.add(Integer.parseInt(Data.TYPES[i]));
        }

        if (startTime < dataStartTime) startTime = dataStartTime;

        StringBuilder response = new StringBuilder("{\"start\":");
        response.append("\"").append(startTime).append("\",\"period\":\"");
        response.append(period * Data.PERIOD).append("\",\"types\":");
        JSONArray list = new JSONArray();
        for (int type : types) {
            list.put(type);
        }
        response.append(list.toString()).append(",\"values\":");

        startTime = (startTime) / 60000 / Data.PERIOD;
        endTime = (endTime) / 60000 / Data.PERIOD;

        JSONArray arrays = new JSONArray();
        for (int type : types) {
            list = new JSONArray();
            double[] profile = new double[count];
            int typeCount = 0;
            Arrays.fill(profile, 0.0);

            for (int i = 0; i < values.size(); ++i) {
                if (dataTypes.get(i) != type) continue;
                getProfile(Arrays.copyOfRange(
                                values.get(i),
                                (int)Math.max(0, startTime - dataStartTimes.get(i)),
                                (int)Math.min(values.get(i).length, endTime - dataStartTimes.get(i))),
                        period, count, profile);
                ++typeCount;
            }

            if (typeCount > 0) {
                for (int i = 0; i < expected; ++i) {
                    if (Double.isFinite(profile[i % profile.length])) list.put(profile[i % profile.length] * multiplier / typeCount);
                }
            }

            arrays.put(list);
        }

        return response.append(arrays.toString()).append("}").toString();
    }

    private String getDeviceData( int id, long startTime, long endTime, int period, double multiplier ) {
        if (startTime < Data.START_TIMES[id - 1]) startTime = Data.START_TIMES[id - 1];

        period /= (int)Data.PERIOD;
        if (period < 1) period = 1;
        double[] values = Data.VALUES[id - 1];

        StringBuilder response = new StringBuilder("{\"start\":");
        response.append("\"").append(startTime).append("\",\"id\":\"").append(id).append("\",\"period\":\"");
        response.append(period * Data.PERIOD).append("\",\"name\":\"").append(Data.NAMES[id - 1]).append("\",\"type\":\"");
        response.append(Data.TYPES[id - 1]).append("\",\"values\":");

        startTime = (startTime - Data.START_TIMES[id - 1]) / 60000 / Data.PERIOD;
        endTime = (endTime - Data.START_TIMES[id - 1]) / 60000 / Data.PERIOD;

        JSONArray list = new JSONArray();
        for (long j = startTime; j + period <= endTime && j + period <= values.length; j += period) {
            double value = 0.0;
            for (int i = 0; i < period; ++i) {
                value += values[(int)j + i];
            }
            list.put(value * multiplier);
        }

        return response.append(list.toString()).append("}").toString();
    }

    private String getTypeData( int id, long startTime, long endTime, int period, double multiplier ) {
        period /= (int)Data.PERIOD;
        if (period < 1) period = 1;
        List<double[]> values = new ArrayList<>();
        List<Long> dataStartTimes = new ArrayList<>();
        long dataStartTime = Long.MAX_VALUE;
        int topLength = 0;
        for (int i = 0; i < 4; ++i) {
            if (Data.TYPES[i].equals(Integer.toString(id))) {
                if (Data.START_TIMES[i] < dataStartTime) dataStartTime = Data.START_TIMES[i];
                if (Data.VALUES[i].length > topLength) topLength = Data.VALUES[i].length;
                dataStartTimes.add(Data.START_TIMES[i] / 60000 / Data.PERIOD);
                values.add(Data.VALUES[i]);
            }
        }

        if (startTime < dataStartTime) startTime = dataStartTime;

        StringBuilder response = new StringBuilder("{\"start\":");
        response.append("\"").append(startTime).append("\",\"period\":\"");
        response.append(period * Data.PERIOD).append("\",\"type\":\"");
        response.append(id).append("\",\"values\":");

        startTime = (startTime) / 60000 / Data.PERIOD;
        endTime = (endTime) / 60000 / Data.PERIOD;
        dataStartTime = dataStartTime / 60000 / Data.PERIOD;

        JSONArray list = new JSONArray();
        for (long j = startTime; j + period <= endTime && j - dataStartTime + period <= topLength; j += period) {
            double value = 0.0;
            for (int i = 0; i < period; ++i) {
                for (int k = 0; k < values.size(); ++k) {
                    int index = (int)j - (int)(long)dataStartTimes.get(k) + i;
                    if (index < values.get(k).length && index >= 0) {
                        value += values.get(k)[index];
                    }
                }
            }
            list.put(value * multiplier);
        }

        return response.append(list.toString()).append("}").toString();
    }

    private String getHouseData( Set<Integer> types, long startTime, long endTime, int period, double multiplier ) {
        period /= (int)Data.PERIOD;
        if (period < 1) period = 1;
        List<double[]> values = new ArrayList<>();
        List<Long> dataStartTimes = new ArrayList<>();
        List<Integer> dataTypes = new ArrayList<>();
        long dataStartTime = Long.MAX_VALUE;
        int topLength = 0;
        for (int i = 0; i < 4; ++i) {
            if (Data.START_TIMES[i] < dataStartTime) dataStartTime = Data.START_TIMES[i];
            if (Data.VALUES[i].length > topLength) topLength = Data.VALUES[i].length;
            dataStartTimes.add(Data.START_TIMES[i] / 60000 / Data.PERIOD);
            values.add(Data.VALUES[i]);
            dataTypes.add(Integer.parseInt(Data.TYPES[i]));
        }

        if (startTime < dataStartTime) startTime = dataStartTime;

        StringBuilder response = new StringBuilder("{\"start\":");
        response.append("\"").append(startTime).append("\",\"period\":\"");
        response.append(period * Data.PERIOD).append("\",\"types\":");
        JSONArray list = new JSONArray();
        for (int type : types) {
            list.put(type);
        }
        response.append(list.toString()).append(",\"values\":");

        startTime = (startTime) / 60000 / Data.PERIOD;
        endTime = (endTime) / 60000 / Data.PERIOD;
        dataStartTime = dataStartTime / 60000 / Data.PERIOD;

        JSONArray arrays = new JSONArray();
        for (int type : types) {
            list = new JSONArray();
            for (long j = startTime; j + period <= endTime && j - dataStartTime + period <= topLength; j += period) {
                double value = 0.0;
                for (int i = 0; i < period; ++i) {
                    for (int k = 0; k < values.size(); ++k) {
                        if (dataTypes.get(k) != type) continue;
                        int index = (int) j - (int) (long) dataStartTimes.get(k) + i;
                        if (index < values.get(k).length && index >= 0) {
                            value += values.get(k)[index];
                        }
                    }
                }
                list.put(value * multiplier);
            }
            arrays.put(list);
        }

        return response.append(arrays.toString()).append("}").toString();
    }

    private String getDeviceDeviation( int id, long startTime, long endTime, double edge ) {
        if (startTime < Data.DEVIATION_START_TIME) startTime = Data.DEVIATION_START_TIME;

        int period = 60 / (int)Data.PERIOD;
        DeviationRecord[] values = Data.DEVIATION_RECORDS;

        StringBuilder response = new StringBuilder("{\"start\":");
        response.append("\"").append(startTime).append("\",\"id\":\"").append(id).append("\",\"period\":\"");
        response.append(period * Data.PERIOD).append("\",\"name\":\"").append(Data.NAMES[id - 1]).append("\",\"type\":\"");
        response.append(Data.TYPES[id - 1]).append("\",\"values\":");

        startTime = (startTime - Data.DEVIATION_START_TIME) / 60000 / Data.PERIOD;
        endTime = (endTime - Data.DEVIATION_START_TIME) / 60000 / Data.PERIOD;

        JSONArray list = new JSONArray();
        for (long j = startTime; j + period <= endTime && j + period <= values.length; j += period) {
            if (Math.abs(values[(int)j].value) >= edge) list.put(new JSONObject(values[(int)j].toString()));
        }

        return response.append(list.toString()).append("}").toString();
    }

    private String getTypeDeviation( int id, long startTime, long endTime, double edge ) {
        if (startTime < Data.DEVIATION_START_TIME) startTime = Data.DEVIATION_START_TIME;

        int period = 60 / (int)Data.PERIOD;
        DeviationRecord[] values = Data.DEVIATION_RECORDS;

        StringBuilder response = new StringBuilder("{\"start\":");
        response.append("\"").append(startTime).append("\",\"id\":\"").append(id);
        response.append("\",\"values\":");

        startTime = (startTime - Data.DEVIATION_START_TIME) / 60000 / Data.PERIOD;
        endTime = (endTime - Data.DEVIATION_START_TIME) / 60000 / Data.PERIOD;

        JSONArray list = new JSONArray();
        for (long j = startTime; j + period <= endTime && j + period <= values.length; j += period) {
            if (Math.abs(values[(int)j].value) >= edge) list.put(new JSONObject(values[(int)j].toString()));
        }

        return response.append(list.toString()).append("}").toString();
    }

    private String getDevicePercentage( int id, long startTime, long endTime, int period ) {
        if (startTime < Data.START_TIMES[id - 1]) startTime = Data.START_TIMES[id - 1];

        period /= (int)Data.PERIOD;
        if (period < 1) period = 1;
        double[] values = Data.VALUES[id - 1];

        StringBuilder response = new StringBuilder("{\"start\":");
        response.append("\"").append(startTime).append("\",\"id\":\"").append(id).append("\",\"period\":\"");
        response.append(period * Data.PERIOD).append("\",\"name\":\"").append(Data.NAMES[id - 1]).append("\",\"type\":\"");
        response.append(Data.TYPES[id - 1]).append("\",\"values\":");

        startTime = (startTime - Data.START_TIMES[id - 1]) / 60000 / Data.PERIOD;
        endTime = (endTime - Data.START_TIMES[id - 1]) / 60000 / Data.PERIOD;

        JSONArray list = new JSONArray();
        for (long j = startTime; j + period <= endTime && j + period <= values.length; j += period) {
            double value = 0.0;
            for (int i = 0; i < period; ++i) {
                value += values[(int)j + i];
            }
            list.put(0.25 * value / (1000 * period));
        }

        return response.append(list.toString()).append("}").toString();
    }

    private String getTypePercentage( int id, long startTime, long endTime, int period ) {
        period /= (int)Data.PERIOD;
        if (period < 1) period = 1;
        List<double[]> values = new ArrayList<>();
        List<Long> dataStartTimes = new ArrayList<>();
        long dataStartTime = Long.MAX_VALUE;
        int topLength = 0;
        for (int i = 0; i < 4; ++i) {
            if (Data.TYPES[i].equals(Integer.toString(id))) {
                if (Data.START_TIMES[i] < dataStartTime) dataStartTime = Data.START_TIMES[i];
                if (Data.VALUES[i].length > topLength) topLength = Data.VALUES[i].length;
                dataStartTimes.add(Data.START_TIMES[i] / 60000 / Data.PERIOD);
                values.add(Data.VALUES[i]);
            }
        }

        if (startTime < dataStartTime) startTime = dataStartTime;

        StringBuilder response = new StringBuilder("{\"start\":");
        response.append("\"").append(startTime).append("\",\"period\":\"");
        response.append(period * Data.PERIOD).append("\",\"type\":\"");
        response.append(id).append("\",\"values\":");

        startTime = (startTime) / 60000 / Data.PERIOD;
        endTime = (endTime) / 60000 / Data.PERIOD;
        dataStartTime = dataStartTime / 60000 / Data.PERIOD;

        JSONArray list = new JSONArray();
        for (long j = startTime; j + period <= endTime && j - dataStartTime + period <= topLength; j += period) {
            double value = 0.0;
            for (int i = 0; i < period; ++i) {
                for (int k = 0; k < values.size(); ++k) {
                    int index = (int)j - (int)(long)dataStartTimes.get(k) + i;
                    if (index < values.get(k).length && index >= 0) {
                        value += values.get(k)[index];
                    }
                }
            }
            list.put(0.25 * value / (1000 * period));
        }

        return response.append(list.toString()).append("}").toString();
    }

    private String getHousePercentage( Set<Integer> types, long startTime, long endTime, int period ) {
        period /= (int)Data.PERIOD;
        if (period < 1) period = 1;
        List<double[]> values = new ArrayList<>();
        List<Long> dataStartTimes = new ArrayList<>();
        List<Integer> dataTypes = new ArrayList<>();
        long dataStartTime = Long.MAX_VALUE;
        int topLength = 0;
        for (int i = 0; i < 4; ++i) {
            if (Data.START_TIMES[i] < dataStartTime) dataStartTime = Data.START_TIMES[i];
            if (Data.VALUES[i].length > topLength) topLength = Data.VALUES[i].length;
            dataStartTimes.add(Data.START_TIMES[i] / 60000 / Data.PERIOD);
            values.add(Data.VALUES[i]);
            dataTypes.add(Integer.parseInt(Data.TYPES[i]));
        }

        if (startTime < dataStartTime) startTime = dataStartTime;

        StringBuilder response = new StringBuilder("{\"start\":");
        response.append("\"").append(startTime).append("\",\"period\":\"");
        response.append(period * Data.PERIOD).append("\",\"types\":");
        JSONArray list = new JSONArray();
        for (int type : types) {
            list.put(type);
        }
        response.append(list.toString()).append(",\"values\":");

        startTime = (startTime) / 60000 / Data.PERIOD;
        endTime = (endTime) / 60000 / Data.PERIOD;
        dataStartTime = dataStartTime / 60000 / Data.PERIOD;

        JSONArray arrays = new JSONArray();
        for (int type : types) {
            list = new JSONArray();
            for (long j = startTime; j + period <= endTime && j - dataStartTime + period <= topLength; j += period) {
                double value = 0.0;
                for (int i = 0; i < period; ++i) {
                    for (int k = 0; k < values.size(); ++k) {
                        if (dataTypes.get(k) != type) continue;
                        int index = (int) j - (int) (long) dataStartTimes.get(k) + i;
                        if (index < values.get(k).length && index >= 0) {
                            value += values.get(k)[index];
                        }
                    }
                }
                list.put(0.25 * value / (1000 * period));
            }
            arrays.put(list);
        }

        return response.append(arrays.toString()).append("}").toString();
    }

    public void deviceProfile( HttpServerExchange exchange, double multiplier ) throws IOException {
        if (!exchange.getRequestMethod().equals(Methods.POST)) {
            exchange.getResponseSender().send("error");
            return;
        }
        FormData postData = UndertowUtil.parsePostData(exchange);
        if (postData == null) {
            exchange.getResponseSender().send("error");
            return;
        }

        FormData.FormValue deviceID = postData.getFirst("id");
        FormData.FormValue start = postData.getFirst("start");
        FormData.FormValue end = postData.getFirst("end");
        FormData.FormValue period = postData.getFirst("period");
        FormData.FormValue count = postData.getFirst("count");

        if (count == null || count.getValue().isEmpty() ||
                deviceID == null || deviceID.getValue().isEmpty() ||
                start == null || start.getValue().isEmpty() ||
                end == null || end.getValue().isEmpty() ||
                period == null || period.getValue().isEmpty())
        {
            exchange.getResponseSender().send("error");
            return;
        }

        try {
            int id = Integer.parseInt(deviceID.getValue());
            long startTime = Long.parseLong(start.getValue());
            long endTime = Long.parseLong(end.getValue());
            int periodTime = Integer.parseInt(period.getValue());
            int countExpected = Integer.parseInt(count.getValue());
            int countNumber;
            if (periodTime == 60) {
                countNumber = 24;
            } else if (periodTime == 1440) {
                countNumber = 30;
            } else if (periodTime == 43200) {
                countNumber = 12;
            } else {
                exchange.getResponseSender().send("error");
                return;
            }

            exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
            exchange.getResponseSender().send(getDeviceProfile(id, startTime, endTime, periodTime, countNumber, countExpected, multiplier));

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void typeProfile( HttpServerExchange exchange, double multiplier ) throws IOException {
        if (!exchange.getRequestMethod().equals(Methods.POST)) {
            exchange.getResponseSender().send("error");
            return;
        }
        FormData postData = UndertowUtil.parsePostData(exchange);
        if (postData == null) {
            exchange.getResponseSender().send("error");
            return;
        }

        FormData.FormValue typeID = postData.getFirst("id");
        FormData.FormValue start = postData.getFirst("start");
        FormData.FormValue end = postData.getFirst("end");
        FormData.FormValue period = postData.getFirst("period");
        FormData.FormValue count = postData.getFirst("count");

        if (count == null || count.getValue().isEmpty() ||
                typeID == null || typeID.getValue().isEmpty() ||
                start == null || start.getValue().isEmpty() ||
                end == null || end.getValue().isEmpty() ||
                period == null || period.getValue().isEmpty())
        {
            exchange.getResponseSender().send("error");
            return;
        }

        try {
            int id = Integer.parseInt(typeID.getValue());
            long startTime = Long.parseLong(start.getValue());
            long endTime = Long.parseLong(end.getValue());
            int periodTime = Integer.parseInt(period.getValue());
            int countExpected = Integer.parseInt(count.getValue());
            int countNumber;
            if (periodTime == 60) {
                countNumber = 24;
            } else if (periodTime == 1440) {
                countNumber = 30;
            } else if (periodTime == 43200) {
                countNumber = 12;
            } else {
                exchange.getResponseSender().send("error");
                return;
            }

            exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
            exchange.getResponseSender().send(getTypeProfile(id, startTime, endTime, periodTime, countNumber, countExpected, multiplier));

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void houseProfile( HttpServerExchange exchange, double multiplier ) throws IOException {
        if (!exchange.getRequestMethod().equals(Methods.POST)) {
            exchange.getResponseSender().send("error");
            return;
        }
        FormData postData = UndertowUtil.parsePostData(exchange);
        if (postData == null) {
            exchange.getResponseSender().send("error");
            return;
        }

        FormData.FormValue start = postData.getFirst("start");
        FormData.FormValue end = postData.getFirst("end");
        FormData.FormValue period = postData.getFirst("period");
        Deque<FormData.FormValue> types = postData.get("types[]");
        FormData.FormValue count = postData.getFirst("count");

        if (count == null || count.getValue().isEmpty() ||
                types == null || types.isEmpty() ||
                start == null || start.getValue().isEmpty() ||
                end == null || end.getValue().isEmpty() ||
                period == null || period.getValue().isEmpty())
        {
            exchange.getResponseSender().send("error");
            return;
        }

        try {
            Set<Integer> dataTypes = new LinkedHashSet<>();
            for (FormData.FormValue type : types) {
                dataTypes.add(Integer.parseInt(type.getValue()));
            }
            long startTime = Long.parseLong(start.getValue());
            long endTime = Long.parseLong(end.getValue());
            int periodTime = Integer.parseInt(period.getValue());
            int countExpected = Integer.parseInt(count.getValue());
            int countNumber;
            if (periodTime == 60) {
                countNumber = 24;
            } else if (periodTime == 1440) {
                countNumber = 30;
            } else if (periodTime == 43200) {
                countNumber = 12;
            } else {
                exchange.getResponseSender().send("error");
                return;
            }

            exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
            exchange.getResponseSender().send(getHouseProfile(dataTypes, startTime, endTime, periodTime, countNumber, countExpected, multiplier));

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void deviceData( HttpServerExchange exchange, double multiplier ) throws IOException {
        if (!exchange.getRequestMethod().equals(Methods.POST)) {
            exchange.getResponseSender().send("error");
            return;
        }
        FormData postData = UndertowUtil.parsePostData(exchange);
        if (postData == null) {
            exchange.getResponseSender().send("error");
            return;
        }

        FormData.FormValue deviceID = postData.getFirst("id");
        FormData.FormValue start = postData.getFirst("start");
        FormData.FormValue end = postData.getFirst("end");
        FormData.FormValue period = postData.getFirst("period");

        if (deviceID == null || deviceID.getValue().isEmpty() ||
            start == null || start.getValue().isEmpty() ||
            end == null || end.getValue().isEmpty() ||
            period == null || period.getValue().isEmpty())
        {
            exchange.getResponseSender().send("error");
            return;
        }

        try {
            int id = Integer.parseInt(deviceID.getValue());
            long startTime = Long.parseLong(start.getValue());
            long endTime = Long.parseLong(end.getValue());
            int periodTime = Integer.parseInt(period.getValue());

            exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
            exchange.getResponseSender().send(getDeviceData(id, startTime, endTime, periodTime, multiplier));

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void typeData( HttpServerExchange exchange, double multiplier ) throws IOException {
        if (!exchange.getRequestMethod().equals(Methods.POST)) {
            exchange.getResponseSender().send("error");
            return;
        }
        FormData postData = UndertowUtil.parsePostData(exchange);
        if (postData == null) {
            exchange.getResponseSender().send("error");
            return;
        }

        FormData.FormValue typeID = postData.getFirst("id");
        FormData.FormValue start = postData.getFirst("start");
        FormData.FormValue end = postData.getFirst("end");
        FormData.FormValue period = postData.getFirst("period");

        if (typeID == null || typeID.getValue().isEmpty() ||
                start == null || start.getValue().isEmpty() ||
                end == null || end.getValue().isEmpty() ||
                period == null || period.getValue().isEmpty())
        {
            exchange.getResponseSender().send("error");
            return;
        }

        try {
            int id = Integer.parseInt(typeID.getValue());
            long startTime = Long.parseLong(start.getValue());
            long endTime = Long.parseLong(end.getValue());
            int periodTime = Integer.parseInt(period.getValue());

            exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
            exchange.getResponseSender().send(getTypeData(id, startTime, endTime, periodTime, multiplier));

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void houseData( HttpServerExchange exchange, double multiplier ) throws IOException {
        if (!exchange.getRequestMethod().equals(Methods.POST)) {
            exchange.getResponseSender().send("error");
            return;
        }
        FormData postData = UndertowUtil.parsePostData(exchange);
        if (postData == null) {
            exchange.getResponseSender().send("error");
            return;
        }

        FormData.FormValue start = postData.getFirst("start");
        FormData.FormValue end = postData.getFirst("end");
        FormData.FormValue period = postData.getFirst("period");
        Deque<FormData.FormValue> types = postData.get("types[]");

        if (types == null || types.isEmpty() ||
                start == null || start.getValue().isEmpty() ||
                end == null || end.getValue().isEmpty() ||
                period == null || period.getValue().isEmpty())
        {
            exchange.getResponseSender().send("error");
            return;
        }

        try {
            Set<Integer> dataTypes = new LinkedHashSet<>();
            for (FormData.FormValue type : types) {
                dataTypes.add(Integer.parseInt(type.getValue()));
            }
            long startTime = Long.parseLong(start.getValue());
            long endTime = Long.parseLong(end.getValue());
            int periodTime = Integer.parseInt(period.getValue());

            exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
            exchange.getResponseSender().send(getHouseData(dataTypes, startTime, endTime, periodTime, multiplier));

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void devicePercentage( HttpServerExchange exchange ) throws IOException {
        if (!exchange.getRequestMethod().equals(Methods.POST)) {
            exchange.getResponseSender().send("error");
            return;
        }
        FormData postData = UndertowUtil.parsePostData(exchange);
        if (postData == null) {
            exchange.getResponseSender().send("error");
            return;
        }

        FormData.FormValue deviceID = postData.getFirst("id");
        FormData.FormValue start = postData.getFirst("start");
        FormData.FormValue end = postData.getFirst("end");
        FormData.FormValue period = postData.getFirst("period");

        if (deviceID == null || deviceID.getValue().isEmpty() ||
                start == null || start.getValue().isEmpty() ||
                end == null || end.getValue().isEmpty() ||
                period == null || period.getValue().isEmpty())
        {
            exchange.getResponseSender().send("error");
            return;
        }

        try {
            int id = Integer.parseInt(deviceID.getValue());
            long startTime = Long.parseLong(start.getValue());
            long endTime = Long.parseLong(end.getValue());
            int periodTime = Integer.parseInt(period.getValue());

            exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
            exchange.getResponseSender().send(getDevicePercentage(id, startTime, endTime, periodTime));

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void typePercentage( HttpServerExchange exchange ) throws IOException {
        if (!exchange.getRequestMethod().equals(Methods.POST)) {
            exchange.getResponseSender().send("error");
            return;
        }
        FormData postData = UndertowUtil.parsePostData(exchange);
        if (postData == null) {
            exchange.getResponseSender().send("error");
            return;
        }

        FormData.FormValue typeID = postData.getFirst("id");
        FormData.FormValue start = postData.getFirst("start");
        FormData.FormValue end = postData.getFirst("end");
        FormData.FormValue period = postData.getFirst("period");

        if (typeID == null || typeID.getValue().isEmpty() ||
                start == null || start.getValue().isEmpty() ||
                end == null || end.getValue().isEmpty() ||
                period == null || period.getValue().isEmpty())
        {
            exchange.getResponseSender().send("error");
            return;
        }

        try {
            int id = Integer.parseInt(typeID.getValue());
            long startTime = Long.parseLong(start.getValue());
            long endTime = Long.parseLong(end.getValue());
            int periodTime = Integer.parseInt(period.getValue());

            exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
            exchange.getResponseSender().send(getTypePercentage(id, startTime, endTime, periodTime));

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void deviationRecordName( HttpServerExchange exchange ) throws IOException {
        if (!exchange.getRequestMethod().equals(Methods.POST)) {
            return;
        }
        FormData postData = UndertowUtil.parsePostData(exchange);
        if (postData == null) {
            return;
        }

        FormData.FormValue recordID = postData.getFirst("id");
        FormData.FormValue recordName = postData.getFirst("name");

        if (recordID == null || recordID.getValue().isEmpty() ||
            recordName == null || recordName.getValue().isEmpty())
        {
            return;
        }

        try {
            int id = Integer.parseInt(recordID.getValue());
            Data.DEVIATION_RECORDS[id - 1].name = recordName.getValue();

        } catch (Throwable e) {
            e.printStackTrace();
        }
    }

    public void housePercentage( HttpServerExchange exchange ) throws IOException {
        if (!exchange.getRequestMethod().equals(Methods.POST)) {
            exchange.getResponseSender().send("error");
            return;
        }
        FormData postData = UndertowUtil.parsePostData(exchange);
        if (postData == null) {
            exchange.getResponseSender().send("error");
            return;
        }

        FormData.FormValue start = postData.getFirst("start");
        FormData.FormValue end = postData.getFirst("end");
        FormData.FormValue period = postData.getFirst("period");
        Deque<FormData.FormValue> types = postData.get("types[]");

        if (types == null || types.isEmpty() ||
                start == null || start.getValue().isEmpty() ||
                end == null || end.getValue().isEmpty() ||
                period == null || period.getValue().isEmpty())
        {
            exchange.getResponseSender().send("error");
            return;
        }

        try {
            Set<Integer> dataTypes = new LinkedHashSet<>();
            for (FormData.FormValue type : types) {
                dataTypes.add(Integer.parseInt(type.getValue()));
            }
            long startTime = Long.parseLong(start.getValue());
            long endTime = Long.parseLong(end.getValue());
            int periodTime = Integer.parseInt(period.getValue());

            exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
            exchange.getResponseSender().send(getHousePercentage(dataTypes, startTime, endTime, periodTime));

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void deleteDevice( HttpServerExchange exchange ) throws IOException {

        String relPath = exchange.getRelativePath();
        int id = 0;
        try {
            id = Integer.parseInt(relPath.substring(1));
        } catch (Throwable ignored) { }

        if (id > 0 && id <= Data.DELETED.length) {
            Data.DELETED[id - 1] = true;
        }

        redirect(exchange, "/user");
    }

    public void deviceDeviation( HttpServerExchange exchange ) throws IOException {
        if (!exchange.getRequestMethod().equals(Methods.POST)) {
            exchange.getResponseSender().send("error");
            return;
        }
        FormData postData = UndertowUtil.parsePostData(exchange);
        if (postData == null) {
            exchange.getResponseSender().send("error");
            return;
        }

        FormData.FormValue deviceID = postData.getFirst("id");
        FormData.FormValue start = postData.getFirst("start");
        FormData.FormValue end = postData.getFirst("end");
        FormData.FormValue value = postData.getFirst("value");

        if (deviceID == null || deviceID.getValue().isEmpty() ||
                start == null || start.getValue().isEmpty() ||
                end == null || end.getValue().isEmpty() ||
                value == null || value.getValue().isEmpty())
        {
            exchange.getResponseSender().send("error");
            return;
        }

        try {
            int id = Integer.parseInt(deviceID.getValue());
            long startTime = Long.parseLong(start.getValue());
            long endTime = Long.parseLong(end.getValue());
            double edgeValue = Double.parseDouble(value.getValue());

            exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
            exchange.getResponseSender().send(getDeviceDeviation(id, startTime, endTime, edgeValue));

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void typeDeviation( HttpServerExchange exchange ) throws IOException {
        if (!exchange.getRequestMethod().equals(Methods.POST)) {
            exchange.getResponseSender().send("error");
            return;
        }
        FormData postData = UndertowUtil.parsePostData(exchange);
        if (postData == null) {
            exchange.getResponseSender().send("error");
            return;
        }

        FormData.FormValue typeID = postData.getFirst("id");
        FormData.FormValue start = postData.getFirst("start");
        FormData.FormValue end = postData.getFirst("end");
        FormData.FormValue value = postData.getFirst("value");

        if (typeID == null || typeID.getValue().isEmpty() ||
                start == null || start.getValue().isEmpty() ||
                end == null || end.getValue().isEmpty() ||
                value == null || value.getValue().isEmpty())
        {
            exchange.getResponseSender().send("error");
            return;
        }

        try {
            int id = Integer.parseInt(typeID.getValue());
            long startTime = Long.parseLong(start.getValue());
            long endTime = Long.parseLong(end.getValue());
            double edgeValue = Double.parseDouble(value.getValue());

            exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
            exchange.getResponseSender().send(getTypeDeviation(id, startTime, endTime, edgeValue));

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void profileUpdate( HttpServerExchange exchange ) throws IOException, SQLException {

        if (!exchange.getRequestMethod().equals(Methods.POST)) {
            redirect(exchange, "/profile");
            return;
        }
        SecurityContext securityContext = exchange.getSecurityContext();
        if (securityContext == null) {
            redirect(exchange, "/profile");
            return;
        }
        Account account = securityContext.getAuthenticatedAccount();
        if (account == null) {
            redirect(exchange, "/profile");
            return;
        }
        String login = account.getPrincipal().getName();
        FormData postData = UndertowUtil.parsePostData(exchange);
        if (postData == null) {
            redirect(exchange, "/profile");
            return;
        }

        FormData.FormValue password = postData.getFirst("j_password");
        FormData.FormValue repeat = postData.getFirst("j_repeat");
        FormData.FormValue current = postData.getFirst("j_current");

        if (password == null || repeat == null || current == null ||
                password.getValue().isEmpty() || repeat.getValue().isEmpty() ||
                current.getValue().isEmpty())
        {
            redirect(exchange, "/profileerror/0");
            return;
        }

        if (!password.getValue().equals(repeat.getValue())) {
            redirect(exchange, "/profileerror/2");
            return;
        }

        PasswordCredential passwordCredential = new PasswordCredential(DigestUtils.md5Hex(current.getValue()).toCharArray());
        if (identityManager.verify(login, passwordCredential) == null) {
            redirect(exchange, "/profileerror/1");
            return;
        }

        try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement(
                "UPDATE users SET md5_pass = ? WHERE login = ? LIMIT 1"))
        {
            statement.setString(1, DigestUtils.md5Hex(password.getValue()));
            statement.setString(2, login);
            statement.execute();
        }

        identityManager.logout(login);
        redirect(exchange, "/sportsmen");
    }

    public void addPlace( HttpServerExchange exchange ) throws IOException, SQLException {

        final String ADD_ERROR = "/places";

        String role;

        try {
            role = exchange.getSecurityContext().getAuthenticatedAccount().getRoles().iterator().next();
        } catch (Throwable e) {
            redirect(exchange, ADD_ERROR);
            return;
        }

        if (!role.equals("adm") || !exchange.getRequestMethod().equals(Methods.POST)) {
            redirect(exchange, ADD_ERROR);
            return;
        }

        FormData postData = UndertowUtil.parsePostData(exchange);
        if (postData == null) {
            redirect(exchange, ADD_ERROR);
            return;
        }

        FormData.FormValue address = postData.getFirst("j_address");
        FormData.FormValue name = postData.getFirst("j_name");

        if (address == null || name == null) {
            redirect(exchange, ADD_ERROR);
            return;
        }

        try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement(
                "INSERT INTO places (name, address) VALUES (?, ?)"))
        {
            statement.setString(1, name.getValue());
            statement.setString(2, address.getValue());
            statement.execute();
        }

        redirect(exchange, "/places");
    }

    public void inviteSportsman( HttpServerExchange exchange ) throws IOException, SQLException {

        final String INVITE_ERROR = "/sportsmen";
        final String MAIL_FROM = "noreply@analytica.ru";
        final String MAIL_SUBJECT = "Создана учетная запись";

        String role;

        try {
            role = exchange.getSecurityContext().getAuthenticatedAccount().getRoles().iterator().next();
        } catch (Throwable e) {
            redirect(exchange, INVITE_ERROR);
            return;
        }

        if (!role.equals("adm") && !role.equals("trn")) {
            redirect(exchange, INVITE_ERROR);
            return;
        }

        if (!exchange.getRequestMethod().equals(Methods.POST)) {
            redirect(exchange, "/sportsmenfill");
            return;
        }
        FormData postData = UndertowUtil.parsePostData(exchange);
        if (postData == null) {
            redirect(exchange, "/sportsmenfill");
            return;
        }
        FormData.FormValue email = postData.getFirst("j_email");
        FormData.FormValue name = postData.getFirst("j_name");
        FormData.FormValue insport = postData.getFirst("j_insport");
        FormData.FormValue gender = postData.getFirst("j_gender");
        FormData.FormValue category = postData.getFirst("j_category");

        if (email == null || name == null || insport == null || gender == null || category == null ||
                email.getValue().isEmpty() || name.getValue().isEmpty() ||
                insport.getValue().isEmpty() || gender.getValue().isEmpty() || category.getValue().isEmpty())
        {
            redirect(exchange, "/sportsmenfill");
            return;
        }
        String parentName;
        int parentID = 0;
        int disciplineID = 1;
        try {
            parentName = exchange.getSecurityContext().getAuthenticatedAccount().getPrincipal().getName();
        } catch ( NullPointerException e ) {
            redirect(exchange, INVITE_ERROR);
            return;
        }
        try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement("SELECT id, id_discipline FROM users WHERE login = ? LIMIT 1")) {
            statement.setString(1, parentName);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    parentID = result.getInt("id");
                    disciplineID = result.getInt("id_discipline");
                }
            }
        }
        if (parentID == 0) {
            redirect(exchange, INVITE_ERROR);
            return;
        }
        String password = DigestUtils.md5Hex(Long.toString(random.nextLong())).substring(0, 10);
        String login = email.getValue();
        if (!identityManager.userExists(login)) {
            try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement(
                    "INSERT INTO users (login, md5_pass, fio, type, id_parent, id_discipline) VALUES (?, ?, ?, ?, ?, ?)"))
            {
                statement.setString(1, login);
                statement.setString(2, password);
                statement.setString(3, name.getValue());
                statement.setString(4, "spt");
                statement.setInt(5, parentID);
                statement.setInt(6, disciplineID);
                statement.execute();
                int userID = SQLUtil.getLastInsertID();
                try (PreparedStatement statement2 = SQLUtil.getMySQLConnection().prepareStatement(
                        "INSERT INTO sportsman (id_user, id_discipline, fio, gender, insport, id_sportsman_categories) VALUES (?, ?, ?, ?, ?, ?)"))
                {
                    statement2.setInt(1, userID);
                    statement2.setInt(2, disciplineID);
                    statement2.setString(3, name.getValue());
                    statement2.setString(4, gender.getValue());
                    statement2.setString(5, insport.getValue());
                    statement2.setString(6, category.getValue());
                    statement2.execute();
                }
            }

            NetUtil.mail(login, MAIL_FROM, MAIL_SUBJECT, util.getInviteMail(login, password));

            redirect(exchange, "/sportsmen");
        } else {
            redirect(exchange, "/sportsmenerror");
        }
    }

    public void approve( HttpServerExchange exchange ) {
        SecurityContext securityContext = exchange.getSecurityContext();
        if (securityContext == null) return;
        Account account = securityContext.getAuthenticatedAccount();
        if (account == null) return;
        String role = account.getRoles().iterator().next();
        if (role.equals("adm")) {
            int id = 0;
            String relPath = exchange.getRelativePath();
            if (relPath != null) {
                try { id = Integer.parseInt(relPath.substring(1)); }
                catch (Throwable ignored) { }
            }
            if (id != 0) {
                try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement(
                        "UPDATE users SET type = \'trn\' WHERE id = ? LIMIT 1"))
                {
                    statement.setInt(1, id);
                    statement.execute();
                    redirect(exchange, "/users");
                } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }

    public void logout( HttpServerExchange exchange ) {
        final Cookie userCookie = exchange.getRequestCookies().get("user");
        if (userCookie == null) return;
        identityManager.logout(userCookie.getValue());
        exchange.getResponseCookies().put("user", new CookieImpl("user", ""));
        exchange.getResponseCookies().put("token", new CookieImpl("token", ""));
        redirect(exchange, "/sportsmen");
    }

    public void register( HttpServerExchange exchange ) throws IOException, SQLException {
        if (!exchange.getRequestMethod().equals(Methods.POST)) {
            redirect(exchange, "/signupfill");
            return;
        }
        FormData postData = UndertowUtil.parsePostData(exchange);
        if (postData == null) {
            redirect(exchange, "/signupfill");
            return;
        }
        FormData.FormValue password = postData.getFirst("j_password");
        FormData.FormValue email = postData.getFirst("j_email");
        FormData.FormValue fname = postData.getFirst("j_fname");
        FormData.FormValue sname = postData.getFirst("j_sname");
        FormData.FormValue discipline = postData.getFirst("j_discipline");
        if (password == null || email == null || fname == null || sname == null || discipline == null ||
                password.getValue().isEmpty() || email.getValue().isEmpty() ||
                fname.getValue().isEmpty() || sname.getValue().isEmpty() || discipline.getValue().isEmpty())
        {
            redirect(exchange, "/signupfill");
            return;
        }
        try {
            String login = email.getValue();
            if (!identityManager.userExists(login)) {
                String name = sname.getValue() + " " + fname.getValue();
                String pass = password.getValue();
                int disciplineID = 1;
                try {
                    disciplineID = Integer.parseInt(discipline.getValue());
                } catch (Throwable ignored) { }

                try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement(
                        "INSERT INTO users (login, md5_pass, fio, id_discipline) VALUES (?, ?, ?, ?)"))
                {
                    statement.setString(1, login);
                    System.out.println(DigestUtils.md5Hex(pass));
                    statement.setString(2, pass);
                    statement.setString(3, name);
                    statement.setInt(4, disciplineID);
                    statement.execute();
                }

                redirect(exchange, "/sportsmen");
            } else {
                redirect(exchange, "/signuperror");
            }
        } catch (SQLException e) { e.printStackTrace(); }
    }

    public void deletePlace( HttpServerExchange exchange ) throws IOException, SQLException {

        final String DELETE_ERROR = "/"; // TODO: add error page
        String role;
        try {
            role = exchange.getSecurityContext().getAuthenticatedAccount().getRoles().iterator().next();
        } catch (Throwable e) {
            redirect(exchange, DELETE_ERROR);
            return;
        }
        if (!role.equals("adm")) {
            redirect(exchange, DELETE_ERROR);
            return;
        }

        int id = 0;
        String relPath = exchange.getRelativePath();
        if (relPath != null) {
            try { id = Integer.parseInt(relPath.substring(1)); }
            catch (NumberFormatException ignored) { }
        }

        if (id > 0) {
            try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement("DELETE FROM places WHERE id = ?")) {
                statement.setInt(1, id);
                statement.execute();
            }
        }

        redirect(exchange, "/places");
    }

    public void deleteUser( HttpServerExchange exchange ) throws IOException, SQLException {

        final String DELETE_ERROR = "/";

        String role;
        try {
            role = exchange.getSecurityContext().getAuthenticatedAccount().getRoles().iterator().next();
        } catch (Throwable e) {
            redirect(exchange, DELETE_ERROR);
            return;
        }
        if (!role.equals("adm")) {
            redirect(exchange, DELETE_ERROR);
            return;
        }

        int id = 0;
        String relPath = exchange.getRelativePath();
        if (relPath != null) {
            try { id = Integer.parseInt(relPath.substring(1)); }
            catch (Throwable ignored) { }
        }

        if (id > 0) {
            try (PreparedStatement statement = SQLUtil.getMySQLConnection().prepareStatement("DELETE FROM users WHERE id = ?")) {
                statement.setInt(1, id);
                statement.execute();
                try (PreparedStatement statement2 = SQLUtil.getMySQLConnection().prepareStatement("DELETE FROM sportsman WHERE id_user = ?")) {
                    statement2.setInt(1, id);
                    statement2.execute();
                }
            }
        }

        redirect(exchange, "/users");
    }

    private static void redirect( HttpServerExchange exchange, String path ) {
        exchange.getResponseHeaders().put(Headers.LOCATION, path);
        exchange.setResponseCode(StatusCodes.TEMPORARY_REDIRECT);
    }

}
