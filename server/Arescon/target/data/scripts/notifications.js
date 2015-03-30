/**
 * Created by Striker on 30.03.15.
 */

// hide-show saved reports block
$('.history_notifications h4').click(function(){
    $('.notifications').toggle();
});

// mask for max value input
$('.limit input').keyup(function () {
    this.value = this.value.replace(/[^0-9\.]/g,'');
});

var getTimeFormatddmmyyyy = function(date_ms){
    var current_date = new Date(date_ms);
    var date_str = current_date.getDate() + "." + (current_date.getMonth()+1) + "." + current_date.getFullYear();
    return date_str;
};

var initDateRangePicker = function(){
    var date = new Date();
    currentEnd = date.getTime();
    // start on current month
    currentStart = (new Date(date.getFullYear(), date.getMonth(), 1)).getTime();
    $('input[name="daterange"]').val(getTimeFormatddmmyyyy(currentStart) + " - " + getTimeFormatddmmyyyy(currentEnd));
    $('input[name="daterange"]').daterangepicker(
        {
            format: 'DD.MM.YYYY',
            ranges: {
                'Сегодня': [moment(), moment()],
                'Вчера': [moment().subtract('days', 1), moment().subtract('days', 1)],
                'Этот месяц': [moment().startOf('month'), moment().endOf('month')],
                'Предыдущий месяц': [moment().subtract('month', 1).startOf('month'), moment().subtract('month', 1).endOf('month')],
                'Последние 7 дней': [moment().subtract('days', 6), moment()],
                'Последние 30 дней': [moment().subtract('days', 29), moment()]
            },
            startDate: currentStart,//moment().subtract('days', 29),
            endDate: currentEnd,//moment(),
            locale: {
                applyLabel: 'Применить',
                cancelLabel: 'Очистить',
                fromLabel: 'С',
                toLabel: 'До',
                customRangeLabel: 'Другой',
                daysOfWeek: ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт','Сб'],
                monthNames: ['Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'],
                firstDay: 1
            }
        },
        function(start, end) {
            daterangeStart = start;
            daterangeEnd = end;
        }
    );
};

window.onload = function(){
    //daterange
    initDateRangePicker();
};
