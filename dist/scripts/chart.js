var data = [
    {
        name: "Счетчик Techem AP",
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
        name: "Счетчик ГРАНД-25Т",
        description: "Электронные бытовые счетчики газа ГРАНД-25Т предназначены для измерения объема газа, расходуемого газопотребляющим оборудованием с суммарным максимальным расходом до 25 м3/час",
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
        name: "Счетчик однофазный СОЭ-52",
        description: "Электросчётчики СОЭ-52 предназначены для учёта потребления электроэнергии в двухпроводных цепях электрического тока в закрытых помещениях",
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
        name: "Счетчик СВ-15 Х \"МЕТЕР\"",
        description: "Счетчики воды крыльчатые СВ-15Х (одноструйные, сухоходные) предназначены для измерения объема горячей воды, протекающей по трубопроводу при температуре от 5°С до 90°С и рабочем давлении в водопроводной сети не более 1, 0 МПа",
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
var ctxDailyUsage, dailyUsageChart, dataDailyUsage, optionsDailyUsage;
window.onload = function(){
    //daterange
    var a = $('input[name="daterange"]').daterangepicker(
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

    console.log(a);
    //daily
    ctxDailyUsage = $("#dailyUsageChart").get(0).getContext("2d");
    ctxDailyUsage.canvas.width = $("#dailyUsageChart").parent().width();
    dataDailyUsage = {
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
    };
    optionsDailyUsage = {
        scaleShowGridLines : false,
    };
    dailyUsageChart = new Chart(ctxDailyUsage).Line(dataDailyUsage, optionsDailyUsage);

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
	// Boolean - Whether to show labels on the scale
    scaleShowLabels: true,

    // Interpolated JS string - can access value
    scaleLabel: "<%=value%>",

    // Boolean - Whether the scale should stick to integers, not floats even if drawing space is there
    scaleIntegersOnly: true,

    // Boolean - Whether the scale should start at zero, or an order of magnitude down from the lowest value
    scaleBeginAtZero: false,

    // String - Scale label font declaration for the scale label
    scaleFontFamily: "'Helvetica Neue', 'Helvetica', 'Arial', sans-serif",

    // Number - Scale label font size in pixels
    scaleFontSize: 12,
	
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
    ctxDailyUsage.canvas.width = $('.data').width();
    dailyUsageChart = new Chart(ctxDailyUsage).Line(dataDailyUsage, optionsDailyUsage);
});
