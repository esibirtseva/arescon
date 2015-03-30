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

function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}

$('#save_notification').click(function(){
    function getFormData(dom_query){
        var out = {},
            s_data = $(dom_query).serializeArray(),
            tempArr;
        //transform into simple data/value object
        for(var i = 0; i<s_data.length; i++){
            var record = s_data[i];
            if(!out[record.name]) {
                out[record.name] = record.value;
            } else {
                if (typeof out[record.name] == "string") {
                    tempArr = (new Array(out[record.name]));
                } else if (typeof out[record.name] == "array") {
                    tempArr = out[record.name];
                }
                tempArr.push(record.value);
                out[record.name] = tempArr;
            }

        }
        return out;
    }

    var obj = getFormData('form');

    // setting params from URI
    obj['deviceId'] = getParameterByName('id');

    console.log(obj); // obj - send to ajax request

    $.post('/notifications/create', obj, function(data){
        var currentData = JSON.parse(data);

        // do some magic on response
    });
});

var getTimeFormatddmmyyyy = function(date_ms){
    var current_date = new Date(date_ms);
    return current_date.getDate() + "." + (current_date.getMonth()+1) + "." + current_date.getFullYear();
};

var initDateRangePicker = function(){
    var date = new Date(),
        currentEnd = date.getTime();
    // start on current month
    var currentStart = (new Date(date.getFullYear(), date.getMonth(), 1)).getTime();
    var dateRange = $('input[name="daterange"]');
    dateRange.val(getTimeFormatddmmyyyy(currentStart) + " - " + getTimeFormatddmmyyyy(currentEnd));
    dateRange.daterangepicker(
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
            /*daterangeStart = start;
            daterangeEnd = end;*/
        }
    );
};

window.onload = function(){
    //daterange
    initDateRangePicker();
};
