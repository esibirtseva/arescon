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
var data = [
    {
        htmlId: "d1",
        name: "Счетчик Techem AP",
        image: "images/water.jpg",
        type: 0,//water
        description: "Водосчетчик Techem серий АР для горячей и холодной воды",
        dataDailyUsage : {
            labels: ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль"],
            datasets: [
                {
                    label: "My Second dataset",
                    fillColor: "rgba(151,187,205,0.2)",
                    strokeColor: "rgba(151,187,205,1)",
                    pointColor: "rgba(151,187,205,1)",
                    pointStrokeColor: "#fff",
                    pointHighlightFill: "#fff",
                    pointHighlightStroke: "rgba(151,187,205,1)",
                    data: [28, 48, 40, 19, 86, 27, 90]
                }
            ]
        },
        dataShareUsage : [
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
        ]

    },
    {
        htmlId: "d3",
        name: "Счетчик ГРАНД-25Т",
        image: "images/gas.jpg",
        description: "Электронные бытовые счетчики газа ГРАНД-25Т предназначены для измерения объема газа, расходуемого газопотребляющим оборудованием с суммарным максимальным расходом до 25 м3/час",
        type: 1,//gas
        dataDailyUsage : {
            labels: ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль"],
            datasets: [
                {
                    label: "My Second dataset",
                    fillColor: "rgba(151,187,205,0.2)",
                    strokeColor: "rgba(151,187,205,1)",
                    pointColor: "rgba(151,187,205,1)",
                    pointStrokeColor: "#fff",
                    pointHighlightFill: "#fff",
                    pointHighlightStroke: "rgba(151,187,205,1)",
                    data: [28, 48, 40, 19, 86, 27, 90]
                }
            ]
        },
        dataShareUsage : [
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
        ]

    },
    {
        htmlId: "d2",
        name: "Счетчик однофазный СОЭ-52",
        image: "images/electro.jpg",
        description: "Электросчётчики СОЭ-52 предназначены для учёта потребления электроэнергии в двухпроводных цепях электрического тока в закрытых помещениях",
        type: 2,//electro
        dataDailyUsage : {
            labels: ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль"],
            datasets: [
                {
                    label: "My Second dataset",
                    fillColor: "rgba(151,187,205,0.2)",
                    strokeColor: "rgba(151,187,205,1)",
                    pointColor: "rgba(151,187,205,1)",
                    pointStrokeColor: "#fff",
                    pointHighlightFill: "#fff",
                    pointHighlightStroke: "rgba(151,187,205,1)",
                    data: [28, 48, 40, 19, 86, 27, 90]
                }
            ]
        },
        dataShareUsage : [
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
        ]

    },
    {
        htmlId: "d4",
        name: "Счетчик СВ-15 Х \"МЕТЕР\"",
        description: "Счетчики воды крыльчатые СВ-15Х (одноструйные, сухоходные) предназначены для измерения объема горячей воды, протекающей по трубопроводу при температуре от 5°С до 90°С и рабочем давлении в водопроводной сети не более 1, 0 МПа",
        image: "images/water-2.jpeg",
        type: 0,//water
        dataDailyUsage : {
            labels: ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль"],
            datasets: [
                {
                    label: "My Second dataset",
                    fillColor: "rgba(151,187,205,0.2)",
                    strokeColor: "rgba(151,187,205,1)",
                    pointColor: "rgba(151,187,205,1)",
                    pointStrokeColor: "#fff",
                    pointHighlightFill: "#fff",
                    pointHighlightStroke: "rgba(151,187,205,1)",
                    data: [28, 48, 40, 19, 86, 27, 90]
                }
            ]
        },
        dataShareUsage : [
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
        ]

    },
]
var ctxDailyUsage, dailyUsageChart, dataDailyUsage, optionsDailyUsage, dailyDataSetsStore;
window.onload = function(){
    //devices
    for (var i = 0; i < data.length; i++){
        var currentDevice = $('#'+data[i].htmlId);
        currentDevice.children('.device_info').children('h4').html(data[i].name);
    }
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

    //daily
    setGraph("#dailyUsageChart", 2, [red, blue]);
    //share
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

};
$(window).resize(function(){
    if (!ctxDailyUsage) return;
    // ctxDailyUsage.canvas.width = $('.data').width();
    // dailyUsageChart = new Chart(ctxDailyUsage).Line(dataDailyUsage, optionsDailyUsage);
    
    dailyUsageChart.resize();
    // dailyUsageChart.update();
});
var focusDataSet = function(index){
    dailyUsageChart.datasets = jQuery.extend({},dailyDataSetsStore);
    if (index == -1){
        dailyUsageChart.update();
        return;  
    } 
    for (var i = 0; dailyUsageChart.datasets[i]; i++){
        if (i != index) dailyUsageChart.datasets[i] = {};
    } 
    dailyUsageChart.update();
};
$('.device').click(function(){
    $('.device').removeClass('active');
    var currentDevice = $(this);
    currentDevice.addClass('active');
    var id = currentDevice.attr('id');
    showDevice(id);
});
var showDevice = function(htmlId){
    var index = -1;
    for (var i = 0; i < data.length; i++){
        if (data[i].htmlId == htmlId) index = i;
    }
    console.log(index);
    if (index != -1){
        var currentDeviceData = data[index];
        $('.data .device_name h4').html(currentDeviceData.name);
        $('.data .device_name p').html(currentDeviceData.description);
        $('.data .device_image').css("background-image", "url(" + currentDeviceData.image + ")");
        if (currentDeviceData.type == 0) setGraph("#dailyUsageChart", 2, [red, blue]);
        if (currentDeviceData.type == 1) setGraph("#dailyUsageChart", 1, [green]);
        if (currentDeviceData.type == 2) setGraph("#dailyUsageChart", 1, [orange]);
    }
};
var setGraph = function(canvasId, numOfLines, colors){
    //daily
    ctxDailyUsage = $(canvasId).get(0).getContext("2d");
    ctxDailyUsage.canvas.width = $(canvasId).parent().width();
    dataDailyUsage = {
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
    optionsDailyUsage = {
        scaleShowGridLines : false,
        showTooltips: true,
        responsive: true,
        legendTemplate : "<div class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=-1; i<datasets.length; i++){%><%if(!datasets[i]){%><p onclick=\"focusDataSet(<%=i%>)\"><span>●</span>Показать всё</p><%} else {%><p onclick=\"focusDataSet(<%=i%>)\"><span style=\"color:<%=datasets[i].strokeColor%>\">●</span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></p><%}}%></div>"
    };
    dailyUsageChart = new Chart(ctxDailyUsage).Line(dataDailyUsage, optionsDailyUsage);
};
