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
};

function updateSavedList() {
    $.post('/notifications/read', {'deviceId': getParameterByName('id')}, function(data) {
        var currentData = JSON.parse(data);

        var current_tbody = $('.notifications tbody');
        current_tbody.html("");
        var data_size = currentData.length;
        for(var i = 0; i < data_size; i++){
            current_tbody.append("<tr>" +
                "<td>"+currentData[i].datarange+"</td>" +
                "<td>"+currentData[i].limit+"</td>" +
                "<td>"+currentData[i].alert_type+"</td>" +
                "<td style=\"cursor: pointer;\" onclick='removeItem("+currentData[i].id+")'>"+'Удалить'+"</td>" +
                "</tr>");
        }
    });
};

function removeItem(id) {
    $.post('/notifications/delete', {'id': id}, function(data) {
        if(data == 'removed') {
            updateSavedList();
        }
    });
};

$('#save_notification').click(function() {
    function getFormData(dom_query) {
        var out = {},
            s_data = $(dom_query).serializeArray();
        //transform into simple data/value object
        for(var i = 0; i<s_data.length; i++) {
            var record = s_data[i],
                tempArr = [];
            if(!out[record.name]) {
                if (record.name != 'alert_type') {
                    out[record.name] = record.value;
                } else {
                    out[record.name] = [];
                    out[record.name][0] = record.value;
                }
            } else {
                if (typeof out[record.name] == "object") {
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

    // obj - send to ajax request
    $.post('/notifications/create', obj, function(data){
        var currentData = JSON.parse(data);

        updateSavedList();
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
    updateSavedList();
};
