var typeMap = [
    {
        type: 0,
        label: 'Холодная вода',
        measure: "л",
        colors: {
            fill: "rgba(151,187,205,0.2)",
            stroke: "rgba(151,187,205,1)"
        }      
    },
    {
        type: 1,
        measure: "л",
        colors: {
            fill: "rgba(231, 75, 59, 0.2)",
            stroke: "rgba(231, 75, 59, 1)"
        }      
    },
    {
        type: 2,
        measure: "куб. м.",
        colors: {
            fill: "rgba(75, 231, 59, 0.2)",
            stroke: "rgba(75, 231, 59, 1)"
        }      
    },
    {
        type: 3,
        measure: "кВт.ч",
        colors: {
            fill: "rgba(243, 156, 18, 0.2)",
            stroke: "rgba(243, 156, 18, 1)"
        }      
    },
    {
        type: 4,
        measure: "отопл",
        colors: {
            fill: "rgba(231, 75, 59, 0.2)",
            stroke: "rgba(231, 75, 59, 1)"
        }      
    },
]
var ctxDailyUsage, dailyUsageChart, dataDailyUsage, optionsDailyUsage, dailyDataSetsStore;
var deviceID;
var currentCanvasID;
var currentData;
var currentRoute;
var odnDataSet = [];
window.onload = function(){
    //canvasID
    currentCanvasID = "#dailyUsageChart";
    //daterange
    initDateRangePicker();
    var date = new Date();
    daterangeStart = date.setDate(date.getDate()-7);
    daterangeEnd = -1;
    if ($('.device.active').length > 0){//device
        //init deviceId
        deviceID = $('.device.active').data("deviceid");
        
        //daily        
        setGraphAjax(deviceID, daterangeStart, daterangeEnd, currentCanvasID);
        //share
        // setDonut();
    }
    else if (getLastParamUrl() === "water"){
        deviceID = 5;
        setGraphAjax(deviceID, daterangeStart, daterangeEnd, currentCanvasID);//TODO: change request
    }
    else if (getLastParamUrl() === "gas"){
        deviceID = 7;
        setGraphAjax(deviceID, daterangeStart, daterangeEnd, currentCanvasID);//TODO: change request
    }
    else if (getLastParamUrl() === "electricity"){
        deviceID = 6;
        setGraphAjax(deviceID, daterangeStart, daterangeEnd, currentCanvasID);//TODO: change request
    }
    else if (getLastParamUrl() === "heat"){
        window.location.href = "/404";//TODO: change request
    }
    else if (getLastParamUrl() === "odn"){
        currentRoute = "odn";
        setAllOdnData();
    }

};
var getLastParamUrl = function(){
    var url      = window.location.href; 
    return (url.substr(url.lastIndexOf('/')+1));
     
}
$(window).resize(function(){
    dailyUsageChart.resize();
});
$('#graph_tab').click(function(){   
    currentCanvasID = "#dailyUsageChart";
    setGraphAjax(deviceID, daterangeStart, daterangeEnd, currentCanvasID);
});
$('#graph_tab_money').click(function(){   
    currentCanvasID = "#dailyUsageChartMoney";
    setGraphAjax(deviceID+1, daterangeStart, daterangeEnd, currentCanvasID);//TODO: change request
});
$('#table_tab').click(function(){   
    // setTable(currentData);
});
var period = 1440;
var setGraphAjax = function(id, start, end, canvasID){//period is global
    $.post('/device',{
        'deviceID' : id,
        'start' : start+"",
        'end' : end+"",
        'period' : period
    }, function(data){
        currentData = JSON.parse(data);
        setGraph(canvasID, currentData);
        
        if (currentRoute === "odn"){
            setOdnTable(currentData, canvasID);
        }
        else setTable();
        if (deviceID && deviceID > 0){
            setDonut();
        }
    });
};
var setAllOdnData = function(){
    setGraphAjax(1, daterangeStart, daterangeEnd, "#odnWater");
    setGraphAjax(3, daterangeStart, daterangeEnd, "#odnGas");
    setGraphAjax(2, daterangeStart, daterangeEnd, "#odnElectricity");
    setGraphAjax(4, daterangeStart, daterangeEnd, "#odnHeat");
}
var getLabels = function(data){
    var initial_time = new Date(data['start']);
    var labels = [];
    var max_labels = 6;
    var data_size = data.values.length;
    var segment_step = data_size < 15 ? 1 : data_size/max_labels;
    var current_segment = -1;
    for (var i = 0; i < data_size; i++){
        if (Math.floor(i/segment_step) > current_segment){
            current_segment++;
            labels.push(getStrDate(new Date(i*data.period*60*1000 + data.start*1)));//i*data.period*60*1000 + 
        }
        else labels.push("");  
    } 
    return labels;
}
var months = ['янв.','фев.','мрт.','апр.','мая','июня','июля','авг.','сент.','окт.','ноя.','дек.'];
var getStrDate = function(date){            
    return date.getDate() + ' ' + months[date.getMonth()] + ' ' + date.getFullYear();
};
var removeGraph = function(){

}
var setGraph = function(canvasId, data){
    //preset
    if (typeof dailyUsageChart !== 'undefined') dailyUsageChart.destroy();
    $('#graph_tab .measure').html(typeMap[data['type']].measure);
    //DATA
    data['period'] = period;
    //
    var labels = getLabels(data);
    //daily
    $(canvasId).attr("height", "250");
    ctxDailyUsage = $(canvasId).get(0).getContext("2d");
    ctxDailyUsage.clearRect(0, 0, 1000, 10000);
    ctxDailyUsage.canvas.width = $(canvasId).parent().width();
    dataDailyUsage = {
        labels: labels,
        datasets: [
            {
                label: typeMap[data['type']].label,
                fillColor: typeMap[data['type']].colors.fill,
                strokeColor: typeMap[data['type']].colors.stroke,
                pointColor: typeMap[data['type']].colors.stroke,
                pointStrokeColor: "#fff",
                pointHighlightFill: "#fff",
                pointHighlightStroke: "rgba(220,220,220,1)",
                data: data['values']
            }
        ]   
    };

    //TODO: change implementation
    if (currentRoute == "odn"){
        var new_data = [];
        for (var i = 0; i < data.values.length; i++) new_data[i] = data.values[i]*3;
        dataDailyUsage.datasets.push(
            {
                label: typeMap[data['type']].label,
                fillColor: typeMap[data['type']].colors.fill,
                strokeColor: typeMap[data['type']].colors.stroke,
                pointColor: typeMap[data['type']].colors.stroke,
                pointStrokeColor: "#fff",
                pointHighlightFill: "#fff",
                pointHighlightStroke: "rgba(220,220,220,1)",
                data: new_data
            }
        );
    }
    //END TODO

    optionsDailyUsage = {
        scaleShowGridLines : false,
        showTooltips: true,
        responsive: true,
        legendTemplate : "<div class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=-1; i<datasets.length; i++){%><%if(!datasets[i]){%><p onclick=\"focusDataSet(<%=i%>)\"><span>●</span>Показать всё</p><%} else {%><p onclick=\"focusDataSet(<%=i%>)\"><span style=\"color:<%=datasets[i].strokeColor%>\">●</span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></p><%}}%></div>"
    };
    dailyUsageChart = new Chart(ctxDailyUsage).Line(dataDailyUsage, optionsDailyUsage);
};
var sumCosts = function(){
    var sum = 0;
    for (var i = 0; i < currentData.values.length; i++) sum += currentData.values[i];
    return sum;
}
var setDonut = function(){
    var ctxShareUsage = $("#shareUsageChart").get(0).getContext("2d");
    ctxShareUsage.canvas.width = $("#shareUsageChart").parent().width();
    
    var personal_costs = Math.round(sumCosts());
    var all_costs = personal_costs*3;//TODO: change implementation
    var dataShareUsage = [
        {
            value: all_costs,
            color:"rgba(66, 139, 202, 0.2)",
            highlight: "rgba(66, 139, 202, 0.4)",
            label: "Общие расходы (руб.)"
        },
        {
            value: personal_costs,
            color: "rgba(66, 139, 202, 0.8)",
            highlight: "rgba(66, 139, 202, 1)",
            label: "Ваши расходы (руб.)"
        }
    ];
    var optionsShareUsage = {
        segmentShowStroke : true,
        segmentStrokeColor : "#fff",
        segmentStrokeWidth : 5,
        percentageInnerCutout : 50,
        animationSteps : 100,
        animationEasing : "easeOutBounce",
        animateRotate : true,
        animateScale : false,
        legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<segments.length; i++){%><li><span style=\"background-color:<%=segments[i].fillColor%>\"></span><%if(segments[i].label){%><%=segments[i].label%><%}%></li><%}%></ul>"
    };
    var shareUsageChart = new Chart(ctxShareUsage).Doughnut(dataShareUsage, optionsShareUsage);
}
var daterangeStart, daterangeEnd;
var dataBank; //TODO change implementation
var initDateRangePicker = function(){
    $('input[name="daterange"]').daterangepicker(
        {
            format: 'DD.MM.YYYY',
            ranges: {
                'Сегодня': [moment(), moment()],
                'Вчера': [moment().subtract('days', 1), moment().subtract('days', 1)],
                'Последние 7 дней': [moment().subtract('days', 6), moment()],
                'Последние 30 дней': [moment().subtract('days', 29), moment()],
                'Этот месяц': [moment().startOf('month'), moment().endOf('month')],
                'Предыдущий месяц': [moment().subtract('month', 1).startOf('month'), moment().subtract('month', 1).endOf('month')]
            },
            startDate: moment().subtract('days', 29),
            endDate: moment(),
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
            if (currentRoute === "odn") setAllOdnData();
            else setGraphAjax(deviceID, start, end, currentCanvasID);
        }
    );
}
$('#period').change(function(e){
    period = $(this).val();
    if (currentRoute === "odn") setAllOdnData();
    else setGraphAjax(deviceID, daterangeStart, daterangeEnd, currentCanvasID);
});
var setTable = function(){
    $('.tab-content tbody').html("");
    var data_size = currentData.values.length;
    for(var i = 0; i < data_size; i++){
        var current_date = new Date(i*currentData.period*60*1000 + currentData.start*1);
        var date_str = current_date.getDate() + "." + (current_date.getMonth()+1) + "." + current_date.getFullYear();
        var time_str = ("0" + current_date.getHours()).slice(-2) + ":" + ("0" + current_date.getMinutes()).slice(-2);
        // console.log(date_str + "\t" + time_str + "\t" + currentData.values[i].toFixed(2) + "\t" + (currentData.values[i]/3).toFixed(2));//TODO: change cost
        $('.tab-content tbody').append("<tr><td>"+date_str+"</td><td>"+time_str+"</td><td>"+currentData.values[i].toFixed(2)+"</td><td>"+(currentData.values[i]/3).toFixed(2)+"</td></tr>")
    }
}
var setOdnTable = function(data, canvasID){
    var tableID = "table_" + canvasID.substr(canvasID.lastIndexOf("odn") + 3).toLowerCase();
    var current_tbody = $('#'+tableID+' tbody');
    current_tbody.html("");
    var data_size = data.values.length;
    for(var i = 0; i < data_size; i++){
        var current_date = new Date(i*data.period*60*1000 + data.start*1);
        var date_str = current_date.getDate() + "." + (current_date.getMonth()+1) + "." + current_date.getFullYear();
        var time_str = ("0" + current_date.getHours()).slice(-2) + ":" + ("0" + current_date.getMinutes()).slice(-2);
        current_tbody.append("<tr><td>"+time_str+"</td><td>"+time_str+"</td><td>"+currentData.values[i].toFixed(2)+"</td><td>"+(currentData.values[i]/3).toFixed(2)+"</td></tr>")
    }
}
$('.remove_device').click(function(e){
    bootbox.dialog({
        message: "Вы действительно хотите удалить прибор? Это может привести к потере данных, для восстановления которых Вам придется обратиться в службу технической поддержки.",
        title: "Удалить прибор?",
        buttons: {
            success: {
              label: "Нет",
              className: "btn-success",
              callback: function() {
                console.log("Not deleted");
              }
            },
            danger: {
              label: "Да",
              className: "btn-danger",
              callback: function() {
                console.log("Deleted");
                document.location.href = $('.remove_device').attr('href');
              }
            }            
        }
    });   
    e.preventDefault();
});
 