var ctxDailyUsage, dailyUsageChart, dataDailyUsage, optionsDailyUsage, dailyDataSetsStore;
window.onload = function(){
    //daterange
    $('input[name="daterange"]').daterangepicker(
        {
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
            $('#reportrange span').html(start.format('MMMM D, YYYY') + ' - ' + end.format('MMMM D, YYYY'));
        }
    );
    var blue = {
            fill: "rgba(151,187,205,0.2)",
            stroke: "rgba(151,187,205,1)",
            point: "rgba(151,187,205,1)"
        },
        red = {
            fill: "rgba(231, 75, 59, 0.2)",
            stroke: "rgba(231, 75, 59, 1)",
            point: "rgba(231, 75, 59, 1)"
        },
        green = {
            fill: "rgba(75, 231, 59, 0.2)",
            stroke: "rgba(75, 231, 59, 1)",
            point: "rgba(75, 231, 59, 1)"
        },
        orange = {
            fill: "rgba(243, 156, 18, 0.2)",
            stroke: "rgba(243, 156, 18, 1)",
            point: "rgba(243, 156, 18, 1)"
        };
    //daily
    var type = getParameterByName("type");
    if (type != ""){
        if (type == 0){
            $('.data_block h4').html('Вода');
            setGraph("#dailyUsageChart", 2, [red, blue]);
        }
        if (type == 1){
            $('.data_block h4').html('Газ');
            setGraph("#dailyUsageChart", 1, [green]);
        }
        if (type == 2){
            $('.data_block h4').html('Электричество');
            setGraph("#dailyUsageChart", 1, [orange]);
        }
        return;
    }
    
    setGraph("#dailyUsageChart", 2, [red, blue]);
    setGraph("#dailyUsageChart2", 1, [green]);
    setGraph("#dailyUsageChart3", 1, [blue]);
    setGraph("#dailyUsageChart4", 1, [red]);
    setGraph("#dailyUsageChart5", 1, [orange]);

};
$(window).resize(function(){
    if (!ctxDailyUsage) return;    
    dailyUsageChart.resize();
});
var setGraph = function(canvasId, numOfLines, colors){
    //daily
    var ctxDailyUsage = $(canvasId).get(0).getContext("2d");
    ctxDailyUsage.canvas.width = $(canvasId).parent().width();
    var dataDailyUsage = {
        labels: ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль"],
        datasets: []
    };
    for (var i = 0; i < numOfLines; i++){
        var data_points = [];
        for (var j = 0; j < 7; j++) data_points.push(Math.random()*90);
        dataDailyUsage.datasets.push({
                label: "Холодная вода",
                fillColor: colors[i].fill,
                strokeColor: colors[i].stroke,
                pointColor: colors[i].point,
                pointStrokeColor: "#fff",
                pointHighlightFill: "#fff",
                pointHighlightStroke: "rgba(151,187,205,1)",
                data: data_points
            });
    }
    var optionsDailyUsage = {
        scaleShowGridLines : false,
        showTooltips: true,
        responsive: true,
        legendTemplate : "<div class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=-1; i<datasets.length; i++){%><%if(!datasets[i]){%><p onclick=\"focusDataSet(<%=i%>)\"><span>●</span>Показать всё</p><%} else {%><p onclick=\"focusDataSet(<%=i%>)\"><span style=\"color:<%=datasets[i].strokeColor%>\">●</span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></p><%}}%></div>"
    };
    var dailyUsageChart = new Chart(ctxDailyUsage).Line(dataDailyUsage, optionsDailyUsage);
}
function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}