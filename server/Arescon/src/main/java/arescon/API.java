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
import org.joda.time.format.DateTimeFormat;
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
    private int trendDegrees;

    private List<JSONObject> requests;

    public API( DatabaseIdentityManager identityManager, Util util, int trendDegrees ) {
        this.identityManager = identityManager;
        this.util = util;
        this.random = new SecureRandom();
        this.requests = new LinkedList<>();
        this.trendDegrees = trendDegrees;
    }

    int getType( int id ) {
        switch (id) {
            case 1:
            case 4:
            case 7:
            case 10:
                return 2;
            case 2:
            case 5:
            case 8:
            case 11:
                return 0;
            case 3:
            case 6:
            case 9:
            case 12:
                return 3;
            default:
                return -1;
        }
    }

    double STEP = 1.5;

    double[] getProfile( double[] data, int period, int count, boolean weighted ) {
        double[] profile = new double[count];
        int len = count * period;
        int iterations = data.length / len;
        double divisor = weighted ? 0 : iterations;
        double step = weighted ? STEP : 1;
        if (weighted) for (int i = 0; i < iterations; ++i) {
            divisor += Math.pow(STEP, i);
        }
        for (int j = 0; j + period <= len; j += period) {
            double value = 0.0;
            double weight = 1;
            for (int k = 0; k < iterations; ++k) {
                for (int i = 0; i < period; ++i) {
                    value += data[k * len + j + i] * weight;
                }
                weight *= step;
            }
            profile[j / period] = value / divisor;
        }
        return profile;
    }

    void getProfile( double[] data, int period, int count, double[] profile, boolean weighted ) {
        int len = count * period;
        int iterations = data.length / len;
        int divisor = iterations;
        double step = weighted ? STEP : 1;
        if (weighted) for (int i = 0; i < iterations; ++i) {
            divisor += Math.pow(STEP, i);
        }
        for (int j = 0; j + period <= len; j += period) {
            double value = 0.0;
            double weight = 1;
            for (int k = 0; k < iterations; ++k) {
                for (int i = 0; i < period; ++i) {
                    value += data[k * len + j + i] * weight;
                }
                weight *= step;
            }
            profile[j / period] += value / divisor;
        }
    }

    private JSONObject getLastRequests( int count, int selectionType ) {
        JSONArray result = new JSONArray();
        for (int i = requests.size() - 1; i >= 0 && result.length() < count; --i) {
            JSONObject entry = requests.get(i);
            if (selectionType == -1 || entry.getInt("selectiontype") == selectionType) {
                result.put(entry);
            }
        }
        return new JSONObject().put("count", result.length()).put("requests", result);
    }

    private String getDeviceProfile( int id, long startTime, long endTime, int period, int count, int expected, double multiplier, boolean trend, boolean weighted ) {
        if (startTime < Data.START_TIMES[id - 1]) startTime = Data.START_TIMES[id - 1];

        if (multiplier / 20 >= 1.0) {
            multiplier = Data.getMoneyMultiplier(Data.TYPES[id - 1]) * (multiplier / 20);
        }

        period /= (int) Data.PERIOD;
        if (period < 1) period = 1;
        double[] values = Data.VALUES[id - 1];

        StringBuilder response = new StringBuilder("{\"start\":");
        response.append("\"").append(startTime).append("\",\"id\":\"").append(id).append("\",\"period\":\"");
        response.append(period * Data.PERIOD).append("\",\"name\":\"").append(Data.NAMES[id - 1]).append("\",\"type\":\"");
        response.append(Data.TYPES[id - 1]).append("\",\"legendItem\":\"").append(weighted ? "Прогноз" : "Профиль");
        response.append(multiplier != Math.floor(multiplier) ? " (руб.)" : "").append(trend ? " (тренд)" : "").append("\",\"values\":");

        startTime = (startTime - Data.START_TIMES[id - 1]) / 60000 / Data.PERIOD;
        endTime = (endTime - Data.START_TIMES[id - 1]) / 60000 / Data.PERIOD;

        JSONArray list = new JSONArray();

        double[] profile = getProfile(
                Arrays.copyOfRange(values, (int) startTime, (int) Math.min(endTime, values.length)),
                period, count, weighted);

        if (!trend) {
            for (int i = 0; i < expected; ++i) {
                if (Double.isFinite(profile[i % profile.length])) list.put(profile[i % profile.length] * multiplier);
            }
        } else {
            PolynomialFitter trendFitter = new PolynomialFitter(this.trendDegrees);
            for (int i = 0; i < expected; ++i) {
                int index = i % profile.length;
                if (Double.isFinite(profile[index])) trendFitter.addPoint(i, profile[index] * multiplier);
            }
            PolynomialFitter.Polynomial polynomial = trendFitter.getBestFit();
            for (int i = 0; i < expected; ++i) {
                double y = polynomial.getY(i);
                if (Double.isFinite(y)) list.put(y);
            }
        }

        return response.append(list.toString()).append("}").toString();
    }

    private String getTypeProfile( int id, long startTime, long endTime, int period, int count, int expected, double multiplier, boolean trend, boolean weighted ) {

        if (multiplier / 20 >= 1.0) {
            multiplier = Data.getMoneyMultiplier(id + "") * (multiplier / 20);
        }

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
        response.append(id).append("\",\"legendItem\":\"").append(weighted ? "Прогноз" : "Профиль");
        response.append(multiplier != Math.floor(multiplier) ? " (руб.)" : "").append(trend ? " (тренд)" : "").append("\",\"values\":");

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
                    period, count, profile, weighted);
        }

        if (values.size() > 0) {
            if (!trend) {
                for (int i = 0; i < expected; ++i) {
                    if (Double.isFinite(profile[i % profile.length])) {
                        list.put(profile[i % profile.length] * multiplier / values.size());
                    }
                }
            } else {
                PolynomialFitter trendFitter = new PolynomialFitter(this.trendDegrees);

                for (int i = 0; i < expected; ++i) {
                    int index = i % profile.length;
                    if (Double.isFinite(profile[index])) {
                        trendFitter.addPoint(i, profile[index] * multiplier / values.size());
                    }
                }

                PolynomialFitter.Polynomial polynomial = trendFitter.getBestFit();

                for (int i = 0; i < expected; ++i) {
                    double y = polynomial.getY(i);
                    if (Double.isFinite(y)) list.put(y);
                }
            }
        }

        return response.append(list.toString()).append("}").toString();
    }

    private String getHouseProfile( Set<Integer> types, long startTime, long endTime, int period, int count, int expected, double multiplier, boolean trend, boolean weighted ) {

        final double inputMultiplier = multiplier;

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
        response.append(list.toString()).append("\",\"legendItem\":\"").append(weighted ? "Прогноз" : "Профиль");
        response.append(multiplier != Math.floor(multiplier) ? " (руб.)" : "").append(trend ? " (тренд)" : "").append(",\"values\":");

        startTime = (startTime) / 60000 / Data.PERIOD;
        endTime = (endTime) / 60000 / Data.PERIOD;

        JSONArray arrays = new JSONArray();
        for (int type : types) {

            if (inputMultiplier / 20 >= 1.0) {
                multiplier = Data.getMoneyMultiplier(type + "") * (inputMultiplier / 20);
            }

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
                        period, count, profile, weighted);
                ++typeCount;
            }

            if (typeCount > 0) {
                if (!trend) {
                    for (int i = 0; i < expected; ++i) {
                        if (Double.isFinite(profile[i % profile.length]))
                            list.put(profile[i % profile.length] * multiplier / typeCount);
                    }
                } else {
                    PolynomialFitter trendFitter = new PolynomialFitter(this.trendDegrees);
                    for (int i = 0; i < expected; ++i) {
                        int index = i % profile.length;
                        if (Double.isFinite(profile[index])) {
                            trendFitter.addPoint(i, profile[index] * multiplier / typeCount);
                        }
                    }
                    PolynomialFitter.Polynomial polynomial = trendFitter.getBestFit();
                    for (int i = 0; i < expected; ++i) {
                        double y = polynomial.getY(i);
                        if (Double.isFinite(y)) list.put(y);
                    }
                }
            }

            arrays.put(list);
        }

        return response.append(arrays.toString()).append("}").toString();
    }

    private String getDeviceData( int id, long startTime, long endTime, int period, double multiplier, boolean trend ) {

        if (startTime < Data.START_TIMES[id - 1]) startTime = Data.START_TIMES[id - 1];
        if (endTime > new DateTime().getMillis()) endTime = new DateTime().getMillis();

        if (multiplier / 20 >= 1.0) {
            multiplier = Data.getMoneyMultiplier(Data.TYPES[id - 1]) * (multiplier / 20);
        }

        String timeInterval = " (" + new DateTime(startTime).toString(DateTimeFormat.forPattern("dd/MM/yyyy")) +
                " -- "+ new DateTime(endTime).toString(DateTimeFormat.forPattern("dd/MM/yyyy")) + ")";

        period /= (int)Data.PERIOD;
        if (period < 1) period = 1;
        double[] values = Data.VALUES[id - 1];

        StringBuilder response = new StringBuilder("{\"start\":");
        response.append("\"").append(startTime).append("\",\"id\":\"").append(id).append("\",\"period\":\"");
        response.append(period * Data.PERIOD).append("\",\"name\":\"").append(Data.NAMES[id - 1]).append("\",\"type\":\"");
        response.append(Data.TYPES[id - 1]).append("\",\"legendItem\":\"").append("Реальные данные");
        response.append(multiplier != Math.floor(multiplier) ? " (руб.)" : "").append(trend ? " (тренд)" : "");
        response.append(timeInterval).append("\",\"values\":");

        startTime = (startTime - Data.START_TIMES[id - 1]) / 60000 / Data.PERIOD;
        endTime = (endTime - Data.START_TIMES[id - 1]) / 60000 / Data.PERIOD;

        JSONArray list = new JSONArray();
        if (!trend) {
            for (long j = startTime; j + period <= endTime && j + period <= values.length; j += period) {
                double value = 0.0;
                for (int i = 0; i < period; ++i) {
                    value += values[(int) j + i];
                }
                list.put(value * multiplier);
            }
        } else {
            PolynomialFitter trendFitter = new PolynomialFitter(this.trendDegrees);
            for (long j = startTime; j + period <= endTime && j + period <= values.length; j += period) {
                double value = 0.0;
                for (int i = 0; i < period; ++i) {
                    value += values[(int) j + i];
                }
                if (Double.isFinite(value)) trendFitter.addPoint(j, value * multiplier);
            }
            PolynomialFitter.Polynomial polynomial = trendFitter.getBestFit();
            for (long j = startTime; j + period <= endTime && j + period <= values.length; j += period) {
                double y = polynomial.getY(j);
                if (Double.isFinite(y)) list.put(y);
            }
        }

        return response.append(list.toString()).append("}").toString();
    }

    private String getTypeData( int id, long startTime, long endTime, int period, double multiplier, boolean trend ) {

        if (multiplier / 20 >= 1.0) {
            multiplier = Data.getMoneyMultiplier(id + "") * (multiplier / 20);
        }

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
        if (endTime > new DateTime().getMillis()) endTime = new DateTime().getMillis();

        String timeInterval = " (" + new DateTime(startTime).toString(DateTimeFormat.forPattern("dd/MM/yyyy")) +
                " -- "+ new DateTime(endTime).toString(DateTimeFormat.forPattern("dd/MM/yyyy")) + ")";

        StringBuilder response = new StringBuilder("{\"start\":");
        response.append("\"").append(startTime).append("\",\"period\":\"");
        response.append(period * Data.PERIOD).append("\",\"type\":\"");
        response.append(id).append("\",\"legendItem\":\"").append("Реальные данные");
        response.append(multiplier != Math.floor(multiplier) ? " (руб.)" : "").append(trend ? " (тренд)" : "");
        response.append(timeInterval).append("\",\"values\":");

        startTime = (startTime) / 60000 / Data.PERIOD;
        endTime = (endTime) / 60000 / Data.PERIOD;
        dataStartTime = dataStartTime / 60000 / Data.PERIOD;

        JSONArray list = new JSONArray();
        if (!trend) {
            for (long j = startTime; j + period <= endTime && j - dataStartTime + period <= topLength; j += period) {
                double value = 0.0;
                for (int i = 0; i < period; ++i) {
                    for (int k = 0; k < values.size(); ++k) {
                        int index = (int) j - (int) (long) dataStartTimes.get(k) + i;
                        if (index < values.get(k).length && index >= 0) {
                            value += values.get(k)[index];
                        }
                    }
                }
                list.put(value * multiplier);
            }
        } else {
            PolynomialFitter trendFitter = new PolynomialFitter(this.trendDegrees);
            for (long j = startTime; j + period <= endTime && j - dataStartTime + period <= topLength; j += period) {
                double value = 0.0;
                for (int i = 0; i < period; ++i) {
                    for (int k = 0; k < values.size(); ++k) {
                        int index = (int) j - (int) (long) dataStartTimes.get(k) + i;
                        if (index < values.get(k).length && index >= 0) {
                            value += values.get(k)[index];
                        }
                    }
                }
                if (Double.isFinite(value)) trendFitter.addPoint(j, value * multiplier);
            }
            PolynomialFitter.Polynomial polynomial = trendFitter.getBestFit();
            for (long j = startTime; j + period <= endTime && j - dataStartTime + period <= topLength; j += period) {
                double y = polynomial.getY(j);
                if (Double.isFinite(y)) list.put(y);
            }
        }

        return response.append(list.toString()).append("}").toString();
    }

    private String getHouseData( Set<Integer> types, long startTime, long endTime, int period, double multiplier, boolean trend ) {

        final double inputMultiplier = multiplier;

        period /= (int) Data.PERIOD;
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
        if (endTime > new DateTime().getMillis()) endTime = new DateTime().getMillis();

        String timeInterval = " (" + new DateTime(startTime).toString(DateTimeFormat.forPattern("dd/MM/yyyy")) +
                " -- "+ new DateTime(endTime).toString(DateTimeFormat.forPattern("dd/MM/yyyy")) + ")";

        StringBuilder response = new StringBuilder("{\"start\":");
        response.append("\"").append(startTime).append("\",\"period\":\"");
        response.append(period * Data.PERIOD).append("\",\"types\":");
        JSONArray list = new JSONArray();
        for (int type : types) {
            list.put(type);
        }
        response.append(list.toString()).append("\",\"legendItem\":\"").append("Реальные данные");
        response.append(multiplier != Math.floor(multiplier) ? " (руб.)" : "").append(trend ? " (тренд)" : "");
        response.append(timeInterval).append(",\"values\":");

        startTime = (startTime) / 60000 / Data.PERIOD;
        endTime = (endTime) / 60000 / Data.PERIOD;
        dataStartTime = dataStartTime / 60000 / Data.PERIOD;

        JSONArray arrays = new JSONArray();


        for (int type : types) {

            if (inputMultiplier / 20 >= 1.0) {
                multiplier = Data.getMoneyMultiplier(type + "") * (inputMultiplier / 20);
            }

            list = new JSONArray();
            if (!trend) {
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
            } else {
                PolynomialFitter trendFitter = new PolynomialFitter(this.trendDegrees);
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
                    if (Double.isFinite(value)) trendFitter.addPoint(j, value * multiplier);
                }
                PolynomialFitter.Polynomial polynomial = trendFitter.getBestFit();
                for (long j = startTime; j + period <= endTime && j - dataStartTime + period <= topLength; j += period) {
                    double y = polynomial.getY(j);
                    if (Double.isFinite(y)) list.put(y);
                }
            }
            arrays.put(list);
        }

        return response.append(arrays.toString()).append("}").toString();
    }

    private String getDeviceDeviation( int id, long startTime, long endTime, double edge, String search ) {
        if (startTime < Data.DEVIATION_START_TIME) startTime = Data.DEVIATION_START_TIME;

        DeviationRecord[] values = Data.DEVIATION_RECORDS;

        int period = 1;

        StringBuilder response = new StringBuilder("{\"start\":");
        response.append("\"").append(startTime).append("\",\"id\":\"").append(id).append("\",\"period\":\"");
        response.append(period * Data.PERIOD * 12).append("\",\"name\":\"").append(Data.NAMES[id - 1]).append("\",\"type\":\"");
        response.append(Data.TYPES[id - 1]).append("\",\"values\":");

        startTime = (startTime - Data.DEVIATION_START_TIME) / 60000 / Data.PERIOD / 12;
        endTime = (endTime - Data.DEVIATION_START_TIME) / 60000 / Data.PERIOD / 12;

        JSONArray list = new JSONArray();
        String[] contextSearch = search.split(" ");
        outer: for (long j = startTime; j + period <= endTime && j + period <= values.length; j += period) {
            if (Math.abs(values[(int) j].value) >= edge) {
                for (String searchTerm : contextSearch) {
                    if (!values[(int)j].name.toLowerCase().contains(searchTerm.toLowerCase())) continue outer;
                }
                list.put(new JSONObject(values[(int) j].toString()));
            }
        }

        return response.append(list.toString()).append("}").toString();
    }

    private String getTypeDeviation( int id, long startTime, long endTime, double edge, String search ) {
        if (startTime < Data.DEVIATION_START_TIME) startTime = Data.DEVIATION_START_TIME;

        int period = 1;
        DeviationRecord[] values = Data.DEVIATION_RECORDS;

        StringBuilder response = new StringBuilder("{\"start\":");
        response.append("\"").append(startTime).append("\",\"id\":\"").append(id);
        response.append("\",\"values\":");

        startTime = (startTime - Data.DEVIATION_START_TIME) / 60000 / Data.PERIOD / 12;
        endTime = (endTime - Data.DEVIATION_START_TIME) / 60000 / Data.PERIOD / 12;

        JSONArray list = new JSONArray();
        String[] contextSearch = search.split(" ");
        outer: for (long j = startTime; j + period <= endTime && j + period <= values.length; j += period) {
            if (Math.abs(values[(int)j].value) >= edge) {
                for (String searchTerm : contextSearch) {
                    if (!values[(int)j].name.toLowerCase().contains(searchTerm.toLowerCase())) continue outer;
                }
                list.put(new JSONObject(values[(int)j].toString()));
            }
        }

        return response.append(list.toString()).append("}").toString();
    }

    private String getDevicePercentage( int id, long startTime, long endTime, int period, boolean trend ) {
        if (startTime < Data.START_TIMES[id - 1]) startTime = Data.START_TIMES[id - 1];
        if (endTime > new DateTime().getMillis()) endTime = new DateTime().getMillis();
        String timeInterval = " (" + new DateTime(startTime).toString(DateTimeFormat.forPattern("dd/MM/yyyy")) +
                " -- "+ new DateTime(endTime).toString(DateTimeFormat.forPattern("dd/MM/yyyy")) + ")";

        period /= (int)Data.PERIOD;
        if (period < 1) period = 1;
        double[] values = Data.PERCENTAGE_VALUES[id - 1];

        StringBuilder response = new StringBuilder("{\"start\":");
        response.append("\"").append(startTime).append("\",\"id\":\"").append(id).append("\",\"period\":\"");
        response.append(period * Data.PERIOD).append("\",\"name\":\"").append(Data.NAMES[id - 1]).append("\",\"type\":\"");
        response.append(Data.TYPES[id - 1]).append("\",\"legendItem\":\"").append("Реальные данные");
        response.append(trend ? " (тренд)" : "");
        response.append(timeInterval).append("\",\"values\":");

        startTime = (startTime - Data.START_TIMES[id - 1]) / 60000 / Data.PERIOD;
        endTime = (endTime - Data.START_TIMES[id - 1]) / 60000 / Data.PERIOD;

        JSONArray list = new JSONArray();
        if (!trend) {
            for (long j = startTime; j + period <= endTime && j + period <= values.length; j += period) {
                double value = 0.0;
                for (int i = 0; i < period; ++i) {
                    value += values[(int) j + i];
                }
                if (Double.isFinite(value)) list.put(0.25 * value / (period));
            }
        } else {
            PolynomialFitter trendFitter = new PolynomialFitter(this.trendDegrees);
            for (long j = startTime; j + period <= endTime && j + period <= values.length; j += period) {
                double value = 0.0;
                for (int i = 0; i < period; ++i) {
                    value += values[(int) j + i];
                }
                if (Double.isFinite(value)) trendFitter.addPoint(j, 0.25 * value / (period));
            }
            PolynomialFitter.Polynomial polynomial = trendFitter.getBestFit();
            for (long j = startTime; j + period <= endTime && j + period <= values.length; j += period) {
                double y = polynomial.getY(j);
                if (Double.isFinite(y)) list.put(y);
            }
        }

        return response.append(list.toString()).append("}").toString();
    }

    private String getTypePercentage( int id, long startTime, long endTime, int period, boolean trend ) {
        period /= (int)Data.PERIOD;
        if (period < 1) period = 1;
        List<double[]> values = new ArrayList<>();
        List<Long> dataStartTimes = new ArrayList<>();
        long dataStartTime = Long.MAX_VALUE;
        int topLength = 0;
        for (int i = 0; i < 4; ++i) {
            if (Data.TYPES[i].equals(Integer.toString(id))) {
                if (Data.START_TIMES[i] < dataStartTime) dataStartTime = Data.START_TIMES[i];
                if (Data.PERCENTAGE_VALUES[i].length > topLength) topLength = Data.PERCENTAGE_VALUES[i].length;
                dataStartTimes.add(Data.START_TIMES[i] / 60000 / Data.PERIOD);
                values.add(Data.PERCENTAGE_VALUES[i]);
            }
        }

        if (startTime < dataStartTime) startTime = dataStartTime;
        if (endTime > new DateTime().getMillis()) endTime = new DateTime().getMillis();
        String timeInterval = " (" + new DateTime(startTime).toString(DateTimeFormat.forPattern("dd/MM/yyyy")) +
                " -- "+ new DateTime(endTime).toString(DateTimeFormat.forPattern("dd/MM/yyyy")) + ")";

        StringBuilder response = new StringBuilder("{\"start\":");
        response.append("\"").append(startTime).append("\",\"period\":\"");
        response.append(period * Data.PERIOD).append("\",\"type\":\"");
        response.append(id).append("\",\"legendItem\":\"").append("Реальные данные");
        response.append(trend ? " (тренд)" : "");
        response.append(timeInterval).append("\",\"values\":");

        startTime = (startTime) / 60000 / Data.PERIOD;
        endTime = (endTime) / 60000 / Data.PERIOD;
        dataStartTime = dataStartTime / 60000 / Data.PERIOD;

        JSONArray list = new JSONArray();
        if (!trend) {
            for (long j = startTime; j + period <= endTime && j - dataStartTime + period <= topLength; j += period) {
                double value = 0.0;
                for (int i = 0; i < period; ++i) {
                    for (int k = 0; k < values.size(); ++k) {
                        int index = (int) j - (int) (long) dataStartTimes.get(k) + i;
                        if (index < values.get(k).length && index >= 0) {
                            value += values.get(k)[index];
                        }
                    }
                }
                if (Double.isFinite(value)) list.put(0.25 * value / (period));
            }
        } else {
            PolynomialFitter trendFitter = new PolynomialFitter(this.trendDegrees);
            for (long j = startTime; j + period <= endTime && j - dataStartTime + period <= topLength; j += period) {
                double value = 0.0;
                for (int i = 0; i < period; ++i) {
                    for (int k = 0; k < values.size(); ++k) {
                        int index = (int) j - (int) (long) dataStartTimes.get(k) + i;
                        if (index < values.get(k).length && index >= 0) {
                            value += values.get(k)[index];
                        }
                    }
                }
                if (Double.isFinite(value)) trendFitter.addPoint(j, 0.25 * value / (period));
            }
            PolynomialFitter.Polynomial polynomial = trendFitter.getBestFit();
            for (long j = startTime; j + period <= endTime && j - dataStartTime + period <= topLength; j += period) {
                double y = polynomial.getY(j);
                if (Double.isFinite(y)) list.put(y);
            }
        }

        return response.append(list.toString()).append("}").toString();
    }

    private String getHousePercentage( Set<Integer> types, long startTime, long endTime, int period, boolean trend ) {
        period /= (int)Data.PERIOD;
        if (period < 1) period = 1;
        List<double[]> values = new ArrayList<>();
        List<Long> dataStartTimes = new ArrayList<>();
        List<Integer> dataTypes = new ArrayList<>();
        long dataStartTime = Long.MAX_VALUE;
        int topLength = 0;
        for (int i = 0; i < 4; ++i) {
            if (Data.START_TIMES[i] < dataStartTime) dataStartTime = Data.START_TIMES[i];
            if (Data.PERCENTAGE_VALUES[i].length > topLength) topLength = Data.PERCENTAGE_VALUES[i].length;
            dataStartTimes.add(Data.START_TIMES[i] / 60000 / Data.PERIOD);
            values.add(Data.PERCENTAGE_VALUES[i]);
            dataTypes.add(Integer.parseInt(Data.TYPES[i]));
        }

        if (startTime < dataStartTime) startTime = dataStartTime;
        if (endTime > new DateTime().getMillis()) endTime = new DateTime().getMillis();
        String timeInterval = " (" + new DateTime(startTime).toString(DateTimeFormat.forPattern("dd/MM/yyyy")) +
                " -- "+ new DateTime(endTime).toString(DateTimeFormat.forPattern("dd/MM/yyyy")) + ")";

        StringBuilder response = new StringBuilder("{\"start\":");
        response.append("\"").append(startTime).append("\",\"period\":\"");
        response.append(period * Data.PERIOD).append("\",\"types\":");
        JSONArray list = new JSONArray();
        for (int type : types) {
            list.put(type);
        }
        response.append(list.toString()).append("\",\"legendItem\":\"").append("Реальные данные");
        response.append(trend ? " (тренд)" : "");
        response.append(timeInterval).append(",\"values\":");

        startTime = (startTime) / 60000 / Data.PERIOD;
        endTime = (endTime) / 60000 / Data.PERIOD;
        dataStartTime = dataStartTime / 60000 / Data.PERIOD;

        JSONArray arrays = new JSONArray();
        for (int type : types) {
            list = new JSONArray();
            if (!trend) {
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
                    list.put(0.25 * value / (period));
                }
            } else {
                PolynomialFitter trendFitter = new PolynomialFitter(this.trendDegrees);
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
                    if (Double.isFinite(value)) trendFitter.addPoint(j, 0.25 * value / (period));
                }
                PolynomialFitter.Polynomial polynomial = trendFitter.getBestFit();
                for (long j = startTime; j + period <= endTime && j - dataStartTime + period <= topLength; j += period) {
                    double y = polynomial.getY(j);
                    if (Double.isFinite(y)) list.put(y);
                }
            }
            arrays.put(list);
        }

        return response.append(arrays.toString()).append("}").toString();
    }

    private String getTypeRates( int id ) {
        JSONArray result = new JSONArray();
        for (Rate r : Data.RATES.get(id)) {
            result.put(r.toJSON());
        }

        return result.toString();
    }

    private String getDevicePayments( int id ) {
        JSONArray result = new JSONArray();
        for (Payment p : Data.PAYMENTS.get(id)) {
            result.put(p.toJSON());
        }
        result.put(Payment.sum(Data.PAYMENTS.get(id)));

        return result.toString();
    }

    public void deviceProfile( HttpServerExchange exchange, double multiplier, String link, boolean trend ) throws IOException {
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
        FormData.FormValue saveData = postData.getFirst("save");

        boolean weighted = postData.getFirst("predict") != null && !postData.getFirst("predict").getValue().isEmpty();

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
            } else if (periodTime == 43200 || periodTime == 10800) {
                countNumber = 12;
            } else {
                exchange.getResponseSender().send("error");
                return;
            }

            exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
            exchange.getResponseSender().send(getDeviceProfile(id, startTime, endTime, periodTime, countNumber, countExpected, multiplier, trend, weighted));

            if (saveData != null && !saveData.getValue().isEmpty()) {
                JSONObject request = new JSONObject().put("selectiontype", 5).put("link", link).
                        put("time", new DateTime().getMillis()).put("request",
                        new JSONObject().put("id", id).put("start", startTime).put("end", endTime)
                                .put("period", periodTime).put("count", countExpected));
                requests.add(request);
            }

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void typeProfile( HttpServerExchange exchange, double multiplier, String link, boolean trend ) throws IOException {
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
        FormData.FormValue saveData = postData.getFirst("save");

        boolean weighted = postData.getFirst("predict") != null && !postData.getFirst("predict").getValue().isEmpty();

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
            } else if (periodTime == 43200 || periodTime == 10800) {
                countNumber = 12;
            } else {
                exchange.getResponseSender().send("error");
                return;
            }

            exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
            exchange.getResponseSender().send(getTypeProfile(id, startTime, endTime, periodTime, countNumber, countExpected, multiplier, trend, weighted));

            if (saveData != null && !saveData.getValue().isEmpty()) {
                JSONObject request = new JSONObject().put("selectiontype", 4).put("link", link).
                        put("time", new DateTime().getMillis()).put("request",
                        new JSONObject().put("id", id).put("start", startTime).put("end", endTime)
                                .put("period", periodTime).put("count", countExpected));
                requests.add(request);
            }

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void serviceProfile( HttpServerExchange exchange, double multiplier, String link, boolean trend ) throws IOException {
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
        FormData.FormValue saveData = postData.getFirst("save");

        boolean weighted = postData.getFirst("predict") != null && !postData.getFirst("predict").getValue().isEmpty();

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
            } else if (periodTime == 43200 || periodTime == 10800) {
                countNumber = 12;
            } else {
                exchange.getResponseSender().send("error");
                return;
            }

            exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
            exchange.getResponseSender().send(getTypeProfile(getType(id), startTime, endTime, periodTime, countNumber, countExpected, multiplier, trend, weighted));

            if (saveData != null && !saveData.getValue().isEmpty()) {
                JSONObject request = new JSONObject().put("selectiontype", 4).put("link", link).
                        put("time", new DateTime().getMillis()).put("request",
                        new JSONObject().put("id", id).put("start", startTime).put("end", endTime)
                                .put("period", periodTime).put("count", countExpected));
                requests.add(request);
            }

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void houseProfile( HttpServerExchange exchange, double multiplier, String link, boolean trend ) throws IOException {
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
        FormData.FormValue saveData = postData.getFirst("save");

        boolean weighted = postData.getFirst("predict") != null && !postData.getFirst("predict").getValue().isEmpty();

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
            Set dataTypes = new LinkedHashSet();
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
            } else if (periodTime == 43200 || periodTime == 10800) {
                countNumber = 12;
            } else {
                exchange.getResponseSender().send("error");
                return;
            }

            exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
            exchange.getResponseSender().send(getHouseProfile(dataTypes, startTime, endTime, periodTime, countNumber, countExpected, multiplier, trend, weighted));

            int selectionType = 0;

            if (link.startsWith("/flat")) selectionType = 3;
            else if (link.startsWith("/house")) selectionType = 2;
            else if (link.startsWith("/tszh")) selectionType = 1;
            else if (link.startsWith("/uk")) selectionType = 0;

            if (saveData != null && !saveData.getValue().isEmpty()) {
                JSONObject request = new JSONObject().put("selectiontype", selectionType).put("link", link).
                        put("time", new DateTime().getMillis()).put("request",
                        new JSONObject().put("types", new JSONArray(dataTypes)).put("start", startTime).put("end", endTime)
                                .put("period", periodTime).put("count", countExpected));
                requests.add(request);
            }

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void deviceData( HttpServerExchange exchange, double multiplier, boolean trend ) throws IOException {
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
            exchange.getResponseSender().send(getDeviceData(id, startTime, endTime, periodTime, multiplier, trend));

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void typeData( HttpServerExchange exchange, double multiplier, boolean trend ) throws IOException {
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
            exchange.getResponseSender().send(getTypeData(id, startTime, endTime, periodTime, multiplier, trend));

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void serviceData( HttpServerExchange exchange, double multiplier, boolean trend ) throws IOException {
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
            exchange.getResponseSender().send(getTypeData(getType(id), startTime, endTime, periodTime, multiplier, trend));

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void houseData( HttpServerExchange exchange, double multiplier, boolean trend ) throws IOException {
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
            exchange.getResponseSender().send(getHouseData(dataTypes, startTime, endTime, periodTime, multiplier, trend));

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void devicePercentage( HttpServerExchange exchange, boolean trend ) throws IOException {
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
            exchange.getResponseSender().send(getDevicePercentage(id, startTime, endTime, periodTime, trend));

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void typePercentage( HttpServerExchange exchange, boolean trend ) throws IOException {
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
            exchange.getResponseSender().send(getTypePercentage(id, startTime, endTime, periodTime, trend));

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void servicePercentage( HttpServerExchange exchange, boolean trend ) throws IOException {
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
            exchange.getResponseSender().send(getTypePercentage(getType(id), startTime, endTime, periodTime, trend));

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void housePercentage( HttpServerExchange exchange, boolean trend ) throws IOException {
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
            exchange.getResponseSender().send(getHousePercentage(dataTypes, startTime, endTime, periodTime, trend));

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
            String search = "";
            if (postData.contains("search")) {
                search = postData.getFirst("search").getValue();
            }

            exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
            exchange.getResponseSender().send(getDeviceDeviation(id, startTime, endTime, edgeValue, search));

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

            String search = "";
            if (postData.contains("search")) {
                search = postData.getFirst("search").getValue();
            }

            exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
            exchange.getResponseSender().send(getTypeDeviation(id, startTime, endTime, edgeValue, search));

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
            String value = recordName.getValue();
            Data.DEVIATION_RECORDS[id - 1].name = value;
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }

    public void lastRequests( HttpServerExchange exchange ) throws IOException {
        if (!exchange.getRequestMethod().equals(Methods.POST)) {
            exchange.getResponseSender().send("error");
            return;
        }
        FormData postData = UndertowUtil.parsePostData(exchange);
        if (postData == null) {
            exchange.getResponseSender().send("error");
            return;
        }

        FormData.FormValue countData = postData.getFirst("count");
        FormData.FormValue selectionTypeData = postData.getFirst("selectionType");

        if (countData == null || countData.getValue().isEmpty()) {
            exchange.getResponseSender().send("error");
            return;
        }

        try {
            int count = Integer.parseInt(countData.getValue());

            exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
            if (selectionTypeData == null || selectionTypeData.getValue().isEmpty()) {
                exchange.getResponseSender().send(getLastRequests(count, -1).toString());
            } else {
                exchange.getResponseSender().send(getLastRequests(count,
                        Integer.parseInt(selectionTypeData.getValue())).toString());
            }

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void deviceRates( HttpServerExchange exchange ) throws IOException {
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

        if (deviceID == null || deviceID.getValue().isEmpty()) {
            exchange.getResponseSender().send("error");
            return;
        }

        try {
            int id = Integer.parseInt(deviceID.getValue());

            exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
            exchange.getResponseSender().send(getTypeRates(Integer.parseInt(Data.TYPES[id - 1])));

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void typeRates( HttpServerExchange exchange ) throws IOException {
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

        if (deviceID == null || deviceID.getValue().isEmpty()) {
            exchange.getResponseSender().send("error");
            return;
        }

        try {
            int id = Integer.parseInt(deviceID.getValue());

            exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
            exchange.getResponseSender().send(getTypeRates(id));

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void devicePayments( HttpServerExchange exchange ) throws IOException {
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

        if (deviceID == null || deviceID.getValue().isEmpty()) {
            exchange.getResponseSender().send("error");
            return;
        }

        try {
            int id = Integer.parseInt(deviceID.getValue());

            exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
            exchange.getResponseSender().send(getDevicePayments(id - 1));

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void typePayments( HttpServerExchange exchange ) throws IOException {
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

        if (deviceID == null || deviceID.getValue().isEmpty()) {
            exchange.getResponseSender().send("error");
            return;
        }

        try {
            int id = Integer.parseInt(deviceID.getValue());

            exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
            exchange.getResponseSender().send(getDevicePayments(Data.getDevice(id) - 1));

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    private List<Notification> notifications = new ArrayList<>();

    public void notificationsCreate( HttpServerExchange exchange ) throws IOException {
        if (!exchange.getRequestMethod().equals(Methods.POST)) {
            exchange.getResponseSender().send("error");
            return;
        }
        FormData postData = UndertowUtil.parsePostData(exchange);
        if (postData == null) {
            exchange.getResponseSender().send("error");
            return;
        }

        FormData.FormValue deviceIdData = postData.getFirst("deviceId");
        FormData.FormValue dateRangeData = postData.getFirst("daterange");
        FormData.FormValue limitData = postData.getFirst("limit");
        Deque<FormData.FormValue> alertTypesData = postData.get("alert_type[]");

        if (deviceIdData == null || deviceIdData.getValue().isEmpty() ||
                dateRangeData == null || dateRangeData.getValue().isEmpty() ||
                limitData == null || limitData.getValue().isEmpty() ||
                alertTypesData == null || alertTypesData.isEmpty()) {
            exchange.getResponseSender().send("error");
            return;
        }

        try {
            int deviceID = Integer.parseInt(deviceIdData.getValue());
            String dataRange = dateRangeData.getValue();
            double limit = Double.parseDouble(limitData.getValue().replace(',', '.'));
            List<String> alertTypes = new ArrayList<>(alertTypesData.size());
            for (FormData.FormValue alertType : alertTypesData) alertTypes.add(alertType.getValue());

            Notification notification = new Notification(deviceID, dataRange, limit, alertTypes);
            notifications.add(notification);

            exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
            exchange.getResponseSender().send(notification.toJSON().toString());

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void notificationsRead( HttpServerExchange exchange ) throws IOException {
        if (!exchange.getRequestMethod().equals(Methods.POST)) {
            exchange.getResponseSender().send("error");
            return;
        }
        FormData postData = UndertowUtil.parsePostData(exchange);
        FormData.FormValue deviceIdData = null;
        FormData.FormValue idData = null;
        if (postData != null) {
            deviceIdData = postData.getFirst("deviceId");
            idData = postData.getFirst("id");
        }

        try {
            JSONArray answer = new JSONArray();

            if (idData != null && !idData.getValue().isEmpty()) {
                int id = Integer.parseInt(idData.getValue());
                for (Notification n : notifications) {
                    if (n.id == id) {
                        answer.put(n.toJSON());
                        break;
                    }
                }
            } else if (deviceIdData != null && !deviceIdData.getValue().isEmpty()) {
                int deviceID = Integer.parseInt(deviceIdData.getValue());
                for (Notification n : notifications) {
                    if (n.deviceID == deviceID) answer.put(n.toJSON());
                }
            } else {
                for (Notification n : notifications) answer.put(n.toJSON());
            }

            exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
            exchange.getResponseSender().send(answer.toString());

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void notificationsUpdate( HttpServerExchange exchange ) throws IOException {
        if (!exchange.getRequestMethod().equals(Methods.POST)) {
            exchange.getResponseSender().send("error");
            return;
        }
        FormData postData = UndertowUtil.parsePostData(exchange);
        if (postData == null) {
            exchange.getResponseSender().send("error");
            return;
        }

        FormData.FormValue idData = postData.getFirst("id");
        FormData.FormValue dateRangeData = postData.getFirst("daterange");
        FormData.FormValue limitData = postData.getFirst("limit");
        Deque<FormData.FormValue> alertTypesData = postData.get("alert_type[]");

        if (idData == null || idData.getValue().isEmpty() ||
                dateRangeData == null || dateRangeData.getValue().isEmpty() ||
                limitData == null || limitData.getValue().isEmpty() ||
                alertTypesData == null || alertTypesData.isEmpty()) {
            exchange.getResponseSender().send("error");
            return;
        }

        try {
            int id = Integer.parseInt(idData.getValue());
            String dataRange = dateRangeData.getValue();
            double limit = Double.parseDouble(limitData.getValue().replace(',', '.'));
            List<String> alertTypes = new ArrayList<>(alertTypesData.size());
            for (FormData.FormValue alertType : alertTypesData) alertTypes.add(alertType.getValue());

            Notification notification = null;
            for (Notification n : notifications) {
                if (n.id == id) {
                    notification = n;
                    break;
                }
            }

            if (notification != null) {
                notification.daterange = dataRange;
                notification.limit = limit;
                notification.alertTypes = alertTypes;

                exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
                exchange.getResponseSender().send(notification.toJSON().toString());
            } else {
                exchange.getResponseSender().send("error");
            }

        } catch (Throwable e) {
            e.printStackTrace();
            exchange.getResponseSender().send("error");
        }
    }

    public void notificationsDelete( HttpServerExchange exchange ) throws IOException {
        if (!exchange.getRequestMethod().equals(Methods.POST)) {
            exchange.getResponseSender().send("error");
            return;
        }
        FormData postData = UndertowUtil.parsePostData(exchange);
        if (postData == null) {
            exchange.getResponseSender().send("error");
            return;
        }

        FormData.FormValue idData = postData.getFirst("id");

        if (idData == null || idData.getValue().isEmpty()) {
            exchange.getResponseSender().send("error");
            return;
        }

        try {
            int id = Integer.parseInt(idData.getValue());

            for (int i = 0; i < notifications.size(); ++i) {
                if (notifications.get(i).id == id) {
                    notifications.remove(i);
                    exchange.getResponseHeaders().put(Headers.CONTENT_TYPE, "text/plain");
                    exchange.getResponseSender().send("removed");
                    return;
                }
            }

            exchange.getResponseSender().send("error");

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
