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

var dataTypeToMeasure = {
    0 : "л",
    1 : "куб. м.",
    2 : "кВт.ч",
    3 : "л",
    4 : "отопл"
};
var data = [
    {
        htmlId: "d1",
        htmlServiceId: "s1",
        name: "Счетчик Techem AP",
        image: "images/water.jpg",
        type: 0,//watercold
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
        htmlServiceId: "s2",
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
        htmlServiceId: "s3",
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
        htmlServiceId: "s1",
        name: "Счетчик СВ-15 Х \"МЕТЕР\"",
        description: "Счетчики воды крыльчатые СВ-15Х (одноструйные, сухоходные) предназначены для измерения объема горячей воды, протекающей по трубопроводу при температуре от 5°С до 90°С и рабочем давлении в водопроводной сети не более 1, 0 МПа",
        image: "images/water-2.jpeg",
        type: 3,//waterwarm
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
var dataServices = [
    {
        htmlId: "s1",
        deviceIds: ["d1", "d4"],
        name: "Вода",
        bgColor: "#2980b8",
        type: 0,//water
        description: "Данные обо всех приборах данной услуги",
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
        htmlId: "s2",
        deviceIds: ["d2"],
        name: "Газ",
        bgColor: "#2dcc70",
        type: 1,//gas
        description: "Данные обо всех приборах данной услуги",
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
        htmlId: "s3",
        deviceIds: ["d3"],
        name: "Электричество",
        bgColor: "#f39c12",
        type: 2,//electro
        description: "Данные обо всех приборах данной услуги",
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
        htmlId: "s4",
        deviceIds: [],
        name: "Отопление",
        bgColor: "#e74b3b",
        type: 4,//heating
        description: "Данные обо всех приборах данной услуги",
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
];
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
            $('#reportrange span').html(start.format('MMMM D, YYYY') + ' - ' + end.format('MMMM D, YYYY'));
        }
    );

    //daily
    showDevice("d1");
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
    dailyUsageChart.resize();
});
var currentDeviceId = "d1";
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
var focusDataSet = function(index){
    dailyUsageChart.update();
    dailyUsageChart.datasets = jQuery.extend({},dailyDataSetsStore);
    if (index == -1){
        dailyUsageChart.update();
        return;  
    } 
    console.log(dailyUsageChart);
    for (var i = 0; i < dailyUsageChart.datasets.length; i++){
        if (i != index) dailyUsageChart.datasets[i] = {};
    } 
    console.log(dailyUsageChart);
    dailyUsageChart.upadate();
};

$('.device').click(function(e){
    $('.device').removeClass('active');
    $('.service').removeClass('active');
    $('.service').removeClass('active_b');
    var currentDevice = $(this);
    currentDevice.addClass('active');
    currentDevice.parent().parent().addClass('active');
    var id = currentDevice.attr('id');
    currentDeviceId = id;
    showDevice(id);
    e.stopPropagation();
});
$('.service').click(function(){
    $('.service').removeClass('active');
    $('.service').removeClass('active_b');
    $('.device').removeClass('active');
    var currentService = $(this);
    currentService.addClass('active_b');
    var id = currentService.attr('id');
    currentDeviceId = id;
    showDevice(id);
});
var showDevice = function(htmlId){
    console.log(htmlId);
    $('.data').html(deviceTemplate);
    var index = -1;
    for (var i = 0; i < data.length; i++){
        if (data[i].htmlId == htmlId) index = i;
    }
    if (index != -1){
        var currentDeviceData = data[index];
        $('.data .remove_device').attr("onclick", "removeDevice('"+htmlId+"');"); 
        $('.data .device_name h4').html(currentDeviceData.name);
        $('.data .device_name p').html(currentDeviceData.description);
        $('.data .device_image').css("background-image", "url(" + currentDeviceData.image + ")");
        $('#graph_tab .measure').html(dataTypeToMeasure[currentDeviceData.type]);
        if (currentDeviceData.type == 0)setGraph("#dailyUsageChart", 1, [blue]);
        if (currentDeviceData.type == 3)setGraph("#dailyUsageChart", 1, [red]);
        if (currentDeviceData.type == 1) setGraph("#dailyUsageChart", 1, [green]);
        if (currentDeviceData.type == 2) setGraph("#dailyUsageChart", 1, [orange]);
        dailyDataSetsStore = jQuery.extend({},dataDailyUsage.datasets);
    }
    else{
        for (var i = 0; i < dataServices.length; i++){
            if (dataServices[i].htmlId == htmlId) index = i;
        }
        if (index != -1){
            var currentServiceData = dataServices[index];
            $('.data .device_name h4').html(currentServiceData.name);
            $('.data .device_name p').html(currentServiceData.description);
            $('.data .device_image').css("background-image", "none");
            $('.data .device_image').css("background-color", currentServiceData.bgColor);
            $('#graph_tab .measure').html(dataTypeToMeasure[currentServiceData.type]);
            if (currentServiceData.type == 0)setGraph("#dailyUsageChart", 2, [red, blue]);
            if (currentServiceData.type == 1)setGraph("#dailyUsageChart", 1, [green]);
            if (currentServiceData.type == 2)setGraph("#dailyUsageChart", 1, [orange]);
        } 
    }
    if (htmlId == "s5") showODN();
};
var setGraph = function(canvasId, numOfLines, colors){
    //daily
    console.log( $(canvasId).attr("height"));
    $(canvasId).attr("height", "250");
    
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
var deviceTemplate = $('.data').html();
var showODN = function(){
    $('.data').html(odnTemplate);
}
var odnTemplate = 'template for ODN';
var removeDevice = function(htmlId){
    $('#'+htmlId).remove();
    // console.log($('.device')[1]);
    $('.device').last().click();
    // showDevice($('.device').last().attr('id'));
}