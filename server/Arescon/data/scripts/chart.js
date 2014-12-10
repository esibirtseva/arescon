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
window.onload = function(){
    //init deviceId
    deviceID = $('.device.active').data("deviceid");
    //daterange
    initDateRangePicker();
    //daily
    getDateRange();
    var date = new Date();
    daterangeStart = date.setDate(date.getDate()-7);
    daterangeEnd = -1;
    setGraphAjax(deviceID, daterangeStart, -1);
    //share
    setDonut();

};
$(window).resize(function(){
    dailyUsageChart.resize();
});
$('#graph_tab').click(function(){   
    setTimeout(function() {
          showDevice(currentDeviceId);
    }, 10);
});
$('#graph_tab_money').click(function(){   
    setTimeout(function() {          
        setGraph("#dailyUsageChartMoney", 1, [orange]);
    }, 10);
});
var period = 1440;
var setGraphAjax = function(id, start, end){//period is global
    console.log(start.toString() + " " + end)
    $.post('/device',{
        'deviceID' : id,
        'start' : start+"",
        'end' : end+"",
        'period' : period
    }, function(data){
        // console.log(data);
        removeGraph();
        setGraph("#dailyUsageChart", JSON.parse(data));
    });
};
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
    //DATA
    data['type'] = 0;
    data['period'] = period;
    //
    var labels = getLabels(data);
    //daily
    $(canvasId).attr("height", "250");
    console.log(labels);
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
    optionsDailyUsage = {
        scaleShowGridLines : false,
        showTooltips: true,
        responsive: true,
        legendTemplate : "<div class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=-1; i<datasets.length; i++){%><%if(!datasets[i]){%><p onclick=\"focusDataSet(<%=i%>)\"><span>●</span>Показать всё</p><%} else {%><p onclick=\"focusDataSet(<%=i%>)\"><span style=\"color:<%=datasets[i].strokeColor%>\">●</span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></p><%}}%></div>"
    };
    dailyUsageChart = new Chart(ctxDailyUsage).Line(dataDailyUsage, optionsDailyUsage);
};
var setDonut = function(){
    var ctxShareUsage = $("#shareUsageChart").get(0).getContext("2d");
    ctxShareUsage.canvas.width = $("#shareUsageChart").parent().width();
    var dataShareUsage = [
        {
            value: 350,
            color:"rgba(66, 139, 202, 0.1)",
            highlight: "#FF5A5E",
            label: "Red"
        },
        {
            value: 100,
            color: "rgb(66, 139, 202)",
            highlight: "#FFC870",
            label: "Yellow"
        }
    ];
    var optionsShareUsage = {
        //Boolean - Whether we should show a stroke on each segment
        segmentShowStroke : true,

        //String - The colour of each segment stroke
        segmentStrokeColor : "#fff",

        //Number - The width of each segment stroke
        segmentStrokeWidth : 2,

        //Number - The percentage of the chart that we cut out of the middle
        percentageInnerCutout : 50, // This is 0 for Pie charts

        //Number - Amount of animation steps
        animationSteps : 100,

        //String - Animation easing effect
        animationEasing : "easeOutBounce",

        //Boolean - Whether we animate the rotation of the Doughnut
        animateRotate : true,

        //Boolean - Whether we animate scaling the Doughnut from the centre
        animateScale : false,

        //String - A legend template
        legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<segments.length; i++){%><li><span style=\"background-color:<%=segments[i].fillColor%>\"></span><%if(segments[i].label){%><%=segments[i].label%><%}%></li><%}%></ul>"
    };
    var shareUsageChart = new Chart(ctxShareUsage).Doughnut(dataShareUsage, optionsShareUsage);
}
var daterangeStart, daterangeEnd;
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
            console.log(start + ' - ' + end);
            daterangeStart = start;
            daterangeEnd = end;
            setGraphAjax(1, start, end);
        }
    );
}
var getDateRange = function(){
    console.log($('#date_filter').value);
}
$('#period').change(function(e){
    period = $(this).val();
    setGraphAjax(1, daterangeStart, daterangeEnd);
});