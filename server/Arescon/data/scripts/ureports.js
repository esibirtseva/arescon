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
        var id = getParameterByName('id');
        currentPageData = new Profile(id, start, end, period, selectiontype);     
    }else{//no PageData
        //let user watch previous reports
        return;
    }
    currentPageData.updateData(true);
}
function PageData(id, start, end, period, selectiontype){//root class
    var self = this;

    self.selectiontype = selectiontype;
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

function Profile(id, start, end, period, selectiontype){
    var self = this;

    PageData.call(this, id, start, end, period, selectiontype);  

    

    self.updateData = function(updateRepresentation){
        self.isUpdated = false;

        var selectiontype_str = '';
        if(selectiontype === '5'){//device
            selectiontype_str = 'device';
        }else if (selectiontype === '4'){//type
            selectiontype_str = 'type';
        }else if (selectiontype === '3'){//flat
            selectiontype_str = 'flat';
        }else if (selectiontype === '2'){//house
            selectiontype_str = 'house';
        }else if (selectiontype === '1'){//tszh
            selectiontype_str = 'tszh';
        }else if (selectiontype === '0'){//uk
            selectiontype_str = 'uk';
        }
        $.post('/' + selectiontype_str + '/values',{
                'deviceID' : self.id,
                'start' : self.start+"",
                'end' : self.end+"",
                'period' : self.period
            }, function(data){
                var currentData = JSON.parse(data);
                self.valuesData = currentData;

                $.post('/' + selectiontype_str + '/profile/values',{
                    'deviceID' : self.id,
                    'start' : '0',
                    'end' : '999999999999999999',
                    'period' : self.period,
                    'count' : self.valuesData.values.length
                }, function(data){
                    var currentData = JSON.parse(data);
                    self.profileData = currentData;
                    
                    if (updateRepresentation){
                        self.updateRepresentation();
                    }
                    // $('#graph_tab .measure').html(typeMap[currentData.type].measure);
                    self.isUpdated = true;
                });    
                
            });

    };
    self.updateRepresentation = function(){        
        self.destroyAllData();
        //show neede blocks        
        $(typeMap[self.profileData.type].selector).show();

        self.graphs.push(self.setLinearGraph());
    };
    self.setLinearGraph = function(){        
        var data_points = filter_dataset(self.profileData);
        //daily
        var selector = typeMap[self.profileData.type].selector + ' .linear';
        var canvas = $(selector);
        ctxDailyUsage = canvas.get(0).getContext("2d");
        ctxDailyUsage.clearRect(0, 0, 1000, 10000);
        ctxDailyUsage.canvas.width = canvas.parent().width();
        canvas.attr("height", "250");
        var dataDailyUsage = {
            datasets: [
                {
                    label: typeMap[self.profileData.type].label,
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
        //values
        data_points = filter_dataset(self.valuesData);
        dataDailyUsage.datasets.push({
            label: typeMap[self.valuesData.type].label,
            fillColor: typeMap[self.valuesData.type].colors.fill,
            strokeColor: typeMap[self.valuesData.type].colors.stroke,
            pointColor: typeMap[self.valuesData.type].colors.stroke,
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

    self.updateControls = function(){
        $('#period option').hide()
                           .removeAttr('selected');
        $('#period .report_profile').show();
        $('#period .report_profile').first().attr('selected','selected');
    };
    self.updateControls();
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