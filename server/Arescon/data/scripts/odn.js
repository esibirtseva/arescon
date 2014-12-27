var typeMap = [
    {
        type: 0,
        label: 'Холодная вода',
        measure: "л",
        colors: {
            fill: "rgba(151,187,205,0.2)",
            fillDarken: "rgba(151,187,205,0.4)",
            stroke: "rgba(151,187,205,1)"
        },
        selector: "#type_coldwater"
    },
    {
        type: 1,
        label: 'Горячая вода',
        measure: "л",
        colors: {
            fill: "rgba(231, 75, 59, 0.2)",
            fillDarken: "rgba(231, 75, 59, 0.4)",
            stroke: "rgba(231, 75, 59, 1)"
        } ,
        selector: "#type_hotwater"     
    },
    {
        type: 2,
        label: 'Газ',
        measure: "куб. м.",
        colors: {
            fill: "rgba(75, 231, 59, 0.2)",
            fillDarken: "rgba(75, 231, 59, 0.4)",
            stroke: "rgba(75, 231, 59, 1)"
        },
        selector: "#type_gas"     
    },
    {
        type: 3,
        label: 'Электричество',
        measure: "кВт.ч",
        colors: {
            fill: "rgba(243, 156, 18, 0.2)",
            fillDarken: "rgba(243, 156, 18, 0.4)",
            stroke: "rgba(243, 156, 18, 1)"
        }  ,
        selector: "#type_electricity"   
    },
    {
        type: 4,
        label: 'Отопление',
        measure: "отопл",
        colors: {
            fill: "rgba(231, 75, 59, 0.2)",
            fillDarken: "rgba(231, 75, 59, 0.4)",
            stroke: "rgba(231, 75, 59, 1)"
        } ,
        selector: "#type_heat"     
    },
]
function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}
var currentPageData;//new meta!
var currentReporttype, currentPeriod, currentStart, currentEnd;
window.onload = function(){
    //daterange
    initDateRangePicker();
    
    currentReporttype = $('#reporttype').val();
    currentPeriod = $('#period').val();

    buildPageData(currentReporttype, currentPeriod, currentStart, currentEnd);
};
$('#reporttype').change(function(e){
    var reporttype = $(this).val();
    currentReporttype = reporttype;
    buildPageData(reporttype, currentPeriod, currentStart, currentEnd);
});
var initDateRangePicker = function(){
    var date = new Date();
    currentEnd = date.getTime();
    date.setDate(date.getDate()-7);
    currentStart = date.getTime();
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
            
            currentPageData.updDateRange(start, end);
            currentPageData.updateData(true);
        }
    );
};
$('#period').change(function(e){
    var period = $(this).val();

    currentPageData.updPeriod(period);
    currentPageData.updateData(true);
});
var buildPageData = function(reporttype, period, start, end){
    // console.log('hello1');
    $('.data_block').show();
    if (typeof currentPageData !== 'undefined') currentPageData.destroyAllData();
    if (reporttype === '1'){
        currentPageData = new ODNvalues(start, end, period);     
    }else if (reporttype === '2'){
        currentPageData = new ODNshare(start, end, period); 
    }else{//no PageData
        //let user watch previous reports
        console.log("nothing to do here");
        return;
    }
    currentPageData.updateData(true);
}
function PageData(start, end, period, selectiontype){//root class
    var self = this;

    self.selectiontype = selectiontype;
    self.period = period;
    self.start = start;
    self.end = end;
    self.isUpdated = false;//ajax callback flag
    self.graphs = [];//all graphs

    self.updateData = function(updateRepresentation){};
    self.updateRepresentation = function(){};
    self.updPeriod = function(period){
        self.period = period;
    };
    self.updDateRange = function(start, end){
        self.start = start;
        self.end = end;
    };
    self.destroyAllData = function(){
        self.graphs.forEach(function(entry) {
            entry.destroy();
        });
    };
}
function ODNvalues(start, end, period, selectiontype){
    var self = this;

    PageData.call(this, start, end, period, selectiontype); 

    self.valuesData = [];
    self.dates = [];
    self.requstStatus = [];
  
    self.updateData = function(updateRepresentation){
        // console.log('hello2');
        self.isUpdated = false;
        self.valuesData = [];
        self.requstStatus = [];
        self.multipleDataFetch(updateRepresentation);     
    };

    self.multipleDataFetch = function(updateRepresentation){
        //multiple graph multiple data fetch
        // console.log('hello');
        $.post('/flat/money',{
            'types' : [0,1,2,3,4],
            'start' : self.start+"",
            'end' : self.end+"",
            'period' : self.period
        }, function(data){
            var currentData = JSON.parse(data);
            self.valuesData = currentData;
            self.requstStatus.push(true);

            $.post('/house/money',{
                'types' : [0,1,2,3,4],
                'start' : self.start+"",
                'end' : self.end+"",
                'period' : self.period
            }, function(data){
                var currentData = JSON.parse(data);
                self.profileData = currentData;
                self.requstStatus.push(true);
            });
        });
        var shouldContinue = true;
        var periodicFunction = setInterval(function(){
            if (!shouldContinue) clearInterval(periodicFunction);
            shouldContinue = false;
            if(self.requstStatus.length === self.dates.length + 2){
                self.updateRepresentation();
            } else{
                shouldContinue = true;
            }
        },10); 
    };
    self.updateRepresentation = function(){        
        self.destroyAllData();//multiple
        $('.data_block').show();
        $('.table,.share').hide();
        for(var i = 0; i < self.profileData.types.length; i++)
            $(typeMap[self.profileData.types[i]].selector).show();

        for (var i = 0; i < self.profileData.values.length; i++){
            self.graphs.push(self.setLinearGraph(self.profileData, self.valuesData, i));
        }
    };
    self.setLinearGraph = function(profileData, valuesData, type){  
        var data_points = filter_dataset({
            type: type,
            start: profileData.start,
            period: profileData.period,
            values: profileData.values[type]
        });
        //daily
        var selector = typeMap[type].selector + ' .linear';
        var canvas = $(selector);
        ctxDailyUsage = canvas.get(0).getContext("2d");
        ctxDailyUsage.clearRect(0, 0, 1000, 10000);
        ctxDailyUsage.canvas.width = canvas.parent().width();
        canvas.attr("height", "250");
        var dataDailyUsage = {
            datasets: [
                {
                    label: typeMap[type].label,
                    fillColor: 'rgb(244, 247, 251)',
                    strokeColor: 'rgb(216, 219, 223)',
                    pointColor: 'rgb(216, 219, 223)',
                    pointStrokeColor: "#fff",
                    pointHighlightFill: "#fff",
                    pointHighlightStroke: "rgba(220,220,220,1)",
                    data: data_points.values
                }
            ]   
        };
        data_points = filter_dataset({
            type: type,
            start: self.valuesData.start,
            period: profileData.period,
            values: valuesData.values[type]
        });
        dataDailyUsage.datasets.push({
            label: typeMap[type].label,
            fillColor: typeMap[type].colors.fill,
            strokeColor: typeMap[type].colors.stroke,
            pointColor: typeMap[type].colors.stroke,
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: "rgba(220,220,220,1)",
            data: data_points.values
        });
        
        dataDailyUsage.labels = data_points.labels;
        optionsDailyUsage = {
            scaleShowGridLines : false,
            showTooltips: true,
            responsive: true,
            legendTemplate : "<div class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=-1; i<datasets.length; i++){%><%if(!datasets[i]){%><p onclick=\"focusDataSet(<%=i%>)\"><span>●</span>Показать всё</p><%} else {%><p onclick=\"focusDataSet(<%=i%>)\"><span style=\"color:<%=datasets[i].strokeColor%>\">●</span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></p><%}}%></div>"
        };
        var chart = new Chart(ctxDailyUsage).Line(dataDailyUsage, optionsDailyUsage);
        return chart;
    };
};
function ODNshare(start, end, period, selectiontype){
    var self = this;

    ODNvalues.call(this, start, end, period, selectiontype); 

    self.setLinearGraph = function(profileData, valuesData, type){  
        var data_points = filter_dataset({
            type: type,
            start: profileData.start,
            period: profileData.period,
            values: profileData.values[type]
        });
        //daily
        var selector = typeMap[type].selector + ' .linear';
        var canvas = $(selector);
        ctxDailyUsage = canvas.get(0).getContext("2d");
        ctxDailyUsage.clearRect(0, 0, 1000, 10000);
        ctxDailyUsage.canvas.width = canvas.parent().width();
        canvas.attr("height", "250");
        var dataDailyUsage = {datasets: []};
        var dataToDevide = [data_points.values];
        data_points = filter_dataset({
            type: type,
            start: self.valuesData.start,
            period: profileData.period,
            values: valuesData.values[type]
        });
        dataToDevide.push(data_points.values);
        var dataToShow = [];
        for (var i = 0; i < dataToDevide[0].length; i++){
            dataToShow.push(Math.round(dataToDevide[1][i]/dataToDevide[0][i]*100));
        }
        console.log(dataToShow);
        dataDailyUsage.datasets.push({
            label: typeMap[type].label,
            fillColor: typeMap[type].colors.fill,
            strokeColor: typeMap[type].colors.stroke,
            pointColor: typeMap[type].colors.stroke,
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: "rgba(220,220,220,1)",
            data: dataToShow
        });
        
        dataDailyUsage.labels = data_points.labels;
        optionsDailyUsage = {
            scaleShowGridLines : false,
            showTooltips: true,
            responsive: true,
            legendTemplate : "<div class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=-1; i<datasets.length; i++){%><%if(!datasets[i]){%><p onclick=\"focusDataSet(<%=i%>)\"><span>●</span>Показать всё</p><%} else {%><p onclick=\"focusDataSet(<%=i%>)\"><span style=\"color:<%=datasets[i].strokeColor%>\">●</span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></p><%}}%></div>"
        };
        var chart = new Chart(ctxDailyUsage).Line(dataDailyUsage, optionsDailyUsage);

        return chart;
    };
}
var filter_dataset = function(data){
    var result = {};
    result.labels = [];
    result.values = [];
    var max_number_of_datapoints = 30;
    var max_labels = 6;
    var data_size = data.values.length;
    var segment_step = data_size < 15 ? 1 : data_size/max_labels;
    var current_segment = -1;
    var point_segment_step = data_size < max_number_of_datapoints ? 1 : data_size/max_number_of_datapoints;
    var current_point_segment = -1;

    var temp_sum = 0;
    var temp_counter = 0;
    for (var i = 0; i < data_size; i++){
        if (Math.floor(i/point_segment_step) > current_point_segment){
            current_point_segment++;
            var label = " ";
            var value = (temp_sum + data.values[i]) / (temp_counter + 1);
            // console.log(value);
            label = getStrDate(new Date(i*data.period*60*1000 + data.start*1));
            result.values.push(value.toFixed(2));
            result.labels.push(label);
            temp_sum = 0;
            temp_counter = 0;
        }else{
            temp_sum += data.values[i];
            temp_counter++;
        }
    }
    return result;
};
var months = ['янв.','фев.','мрт.','апр.','мая','июня','июля','авг.','сент.','окт.','ноя.','дек.'];
var getStrDate = function(date){            
    return date.getDate() + ' ' + months[date.getMonth()] + ' ' + date.getFullYear() + ' ' + ("0" + date.getHours()).slice(-2) + ":" + ("0" + date.getMinutes()).slice(-2);
};
function toFixed ( number, precision ) {
    var multiplier = Math.pow( 10, precision + 1 ),
        wholeNumber = Math.floor( number * multiplier );
    return Math.round( wholeNumber / 10 ) * 10 / multiplier;
}
var getTimeFormatddmmyyyy = function(date_ms){
    var current_date = new Date(date_ms);
    var date_str = current_date.getDate() + "." + (current_date.getMonth()+1) + "." + current_date.getFullYear();
    return date_str;
}