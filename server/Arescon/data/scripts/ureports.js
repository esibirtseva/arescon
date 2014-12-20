var typeMap = [
    {
        type: 0,
        label: 'Холодная вода',
        measure: "л",
        colors: {
            fill: "rgba(151,187,205,0.2)",
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
            stroke: "rgba(231, 75, 59, 1)"
        } ,
        selector: "#type_hotwater"     
    },
    {
        type: 2,
        measure: "куб. м.",
        colors: {
            fill: "rgba(75, 231, 59, 0.2)",
            stroke: "rgba(75, 231, 59, 1)"
        },
        selector: "#type_gas"     
    },
    {
        type: 3,
        measure: "кВт.ч",
        colors: {
            fill: "rgba(243, 156, 18, 0.2)",
            stroke: "rgba(243, 156, 18, 1)"
        }  ,
        selector: "#type_electricity"   
    },
    {
        type: 4,
        measure: "отопл",
        colors: {
            fill: "rgba(231, 75, 59, 0.2)",
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
    
    var date = new Date();

    currentStart = date.setDate(date.getDate()-7);
    currentEnd = date.setDate(date.getDate()+7);
    currentReporttype = $('#reporttype').val();
    currentPeriod = $('#period').val();

    buildPageData(currentReporttype, currentPeriod, currentStart, currentEnd);
};
var hideAllDataBlocks = function(){
    $('.data_block').hide();
}
$('#reporttype').change(function(e){
    var reporttype = $(this).val();
    currentReporttype = reporttype;
    currentPageData = buildPageData(reporttype, currentPeriod, currentStart, currentEnd);
});
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
            
            currentPageData.updDateRange(start, end);
            currentPageData.updateData(true);
        }
    );
}
$('#period').change(function(e){
    var period = $(this).val();

    currentPageData.updPeriod(period);
    currentPageData.updateData(true);
});

var buildPageData = function(reporttype, period, start, end){

    var selectiontype = getParameterByName('selectiontype');

    if (reporttype === '1'){
        console.log("PROFILE");        
        if (selectiontype === '5'){//device lvl
            var id = getParameterByName('deviceid');
            console.log(id);
            currentPageData = new Profile(id, start, end, period);      
        }
        else{
            console.log('not implemented yet');//TODO implement
        }      
    }else{//no PageData
        //let user watch previous reports
        return;
    }
    currentPageData.updateData(true);
}
function PageData(id, start, end, period){//root class
    var self = this;

    self.id = id; //could be value and array both
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

function Profile(id, start, end, period){
    var self = this;

    PageData.call(this, id, start, end, period);    

    self.updateData = function(updateRepresentation){
        self.isUpdated = false;
        $.post('/device/profile/values',{
            'deviceID' : self.id,
            'start' : self.start+"",
            'end' : self.end+"",
            'period' : self.period,
            'count' : '24'
        }, function(data){
            var currentData = JSON.parse(data);
            console.log(currentData);
            self.profileData = currentData;

            if (updateRepresentation){
                self.updateRepresentation();
            }
            // $('#graph_tab .measure').html(typeMap[currentData.type].measure);
            self.isUpdated = true;
        });
    };
    self.updateRepresentation = function(){        
        self.destroyAllData();
        $(typeMap[self.profileData.type].selector).show();
        self.graphs.push(self.setLinearGraph());
    };
    self.setLinearGraph = function(){        
        var data_points = filter_dataset(self.profileData);
        //daily
        var selector = typeMap[self.profileData.type].selector + ' .linear';
        console.log(selector);
        var canvas = $(selector);
        ctxDailyUsage = canvas.get(0).getContext("2d");
        ctxDailyUsage.clearRect(0, 0, 1000, 10000);
        ctxDailyUsage.canvas.width = canvas.parent().width();
        canvas.attr("height", "250");
        var dataDailyUsage = {
            labels: data_points.labels,//labels,
            datasets: [
                {
                    label: typeMap[self.profileData.type].label,
                    fillColor: typeMap[self.profileData.type].colors.fill,
                    strokeColor: typeMap[self.profileData.type].colors.stroke,
                    pointColor: typeMap[self.profileData.type].colors.stroke,
                    pointStrokeColor: "#fff",
                    pointHighlightFill: "#fff",
                    pointHighlightStroke: "rgba(220,220,220,1)",
                    data: data_points.values
                }
            ]   
        };

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
    console.log(data);
    var data_size = data.values.length;
    var segment_step = data_size < 15 ? 1 : data_size/max_labels;
    var current_segment = -1;
    var point_segment_step = data_size < max_number_of_datapoints ? 1 : data_size/max_number_of_datapoints;
    var current_point_segment = -1;

    var temp_sum = 0;
    var temp_counter = 0;
    for (var i = 0; i < data_size; i++){
        // console.log(getStrDate(new Date(i*data.period*60*1000 + data.start*1)) + " " + data.period);
        if (Math.floor(i/point_segment_step) > current_point_segment){
            current_point_segment++;
            var label = " ";
            var value = (temp_sum + data.values[i]) / (temp_counter + 1);
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