package net.avkorneenkov;

public class TimeUtil {

    private final static String[] inDateRussian = { "Января", "Февраля", "Марта", "Апреля", "Мая", "Июня", "Июля", "Августа", "Сентября", "Октября", "Ноября", "Декабря" };

    public static String getMonthRussianInDate( int number ) {
        if (number < 1 || number > 12) return "";
        return inDateRussian[number - 1];
    }

}
