var typeMap = [
    {
        type: 0,
        label: 'Холодная вода',
        measure: "л",
        colors: {
            fill: "rgba(151,187,205,0.2)",
            stroke: "rgba(151,187,205,1)"
        },
        odnSelector: "#odnWater"
    },
    {
        type: 1,
        label: 'Горячая вода',
        measure: "л",
        colors: {
            fill: "rgba(231, 75, 59, 0.2)",
            stroke: "rgba(231, 75, 59, 1)"
        } ,
        odnSelector: "#odnWater"     
    },
    {
        type: 2,
        measure: "куб. м.",
        colors: {
            fill: "rgba(75, 231, 59, 0.2)",
            stroke: "rgba(75, 231, 59, 1)"
        },
        odnSelector: "#odnGas"      
    },
    {
        type: 3,
        measure: "кВт.ч",
        colors: {
            fill: "rgba(243, 156, 18, 0.2)",
            stroke: "rgba(243, 156, 18, 1)"
        }  ,
        odnSelector: "#odnElectricity"    
    },
    {
        type: 4,
        measure: "отопл",
        colors: {
            fill: "rgba(231, 75, 59, 0.2)",
            stroke: "rgba(231, 75, 59, 1)"
        } ,
        odnSelector: "#odnHeat"     
    },
]

var currentRoute;//odn
var odnDataSet = [];
var currentPageData;//new meta!
var daterangeStart, daterangeEnd;
window.onload = function(){
    //daterange
    initDateRangePicker();
    // to update frequency select by hiding some options
    periodItemsFilter($('input[name="daterange"]').data('daterangepicker'));

    var currentRoute = getLastParamUrl();
    var period = $("#period").val();
    if ($('.device.active').length > 0){
        var deviceID = $('.device.active').data("deviceid");
        currentPageData = new Device(deviceID, daterangeStart, daterangeEnd, period);
        currentPageData.updateData(true);
    }
    else if (currentRoute === "water"){
        var arr_types = [];
        arr_types.push(new Type(0, daterangeStart, daterangeEnd, period));
        arr_types.push(new Type(1, daterangeStart, daterangeEnd, period));
        currentPageData = new MultTypes(arr_types);
        currentPageData.updateData(true);
    }
    else if (currentRoute === "gas"){
        currentPageData = new Type(2, daterangeStart, daterangeEnd, period);
        currentPageData.updateData(true);
    }
    else if (currentRoute === "electricity"){
        currentPageData = new Type(3, daterangeStart, daterangeEnd, period);
        currentPageData.updateData(true);
    }
    else if (currentRoute === "coldwater"){
        currentPageData = new Type(0, daterangeStart, daterangeEnd, period);
        currentPageData.updateData(true);
    }
    else if (currentRoute === "hotwater"){
        currentPageData = new Type(1, daterangeStart, daterangeEnd, period);
        currentPageData.updateData(true);
    }
    else if (currentRoute === "heat"){
        currentPageData = new Type(4, daterangeStart, daterangeEnd, period);
        currentPageData.updateData(true);
    }
    else if (currentRoute === "odn"){
        currentPageData = new ODN([
                new odnItem(0, daterangeStart, daterangeEnd, period),
                new odnItem(2, daterangeStart, daterangeEnd, period),
                new odnItem(3, daterangeStart, daterangeEnd, period),
                new odnItem(4, daterangeStart, daterangeEnd, period),
            ]);
        currentPageData.updateData(true);
    }

};
var getLastParamUrl = function(){
    var url      = window.location.href; 
    return (url.substr(url.lastIndexOf('/')+1));    
}
$('.nav-tabs>li').click(function(){
    setTimeout(function(){
        currentPageData.updateRepresentation();
    }, 100);
});

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
    return date.getDate() + ' ' + months[date.getMonth()] + ' ' + date.getFullYear() + ' ' + ("0" + date.getHours()).slice(-2) + ":" + ("0" + date.getMinutes()).slice(-2);
};

var sumCosts = function(data){
    var sum = 0;
    for (var i = 0; i < data.values.length; i++) sum += data.values[i];
    return sum;
}

var daterangeStart, daterangeEnd;
var dataBank; //TODO change implementation
var initDateRangePicker = function(){
    var date = new Date();
    daterangeEnd = date.getTime();
    // start on current month
    daterangeStart = (new Date(date.getFullYear(), date.getMonth(), 1)).getTime();
    $('input[name="daterange"]').val(getTimeFormatddmmyyyy(daterangeStart) + " - " + getTimeFormatddmmyyyy(daterangeEnd));
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
            startDate: daterangeStart,//moment().subtract('days', 29),
            endDate: daterangeEnd,//moment(),
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
            else {
                currentPageData.updateDateRange(start, end);
                currentPageData.updateData(true);
            } 
        }
    );
}
$('#period').change(function(e){
    period = $(this).val();
    if (currentRoute === "odn") setAllOdnData();
    else {
        currentPageData.updPeriod(period);
        currentPageData.updateData(true);
    } 
});

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
 


function Device(id, start, end, _period){
    var self = this;

    self.id = id;
    self.start = start;
    self.end = end;
    self.period = _period;
    self.valuesData = {};
    self.moneyData = {};

    //defaults
    self.canvasValuesSelector = "#dailyUsageChart";
    self.canvasMoneySelector = "#dailyUsageChartMoney";
    self.tableSelector = '.tab-content tbody.simple-table';//tbody!
    self.rateSelector = '.tab-content tbody.rate-table';//tbody!
    self.paymentsSelector = '.tab-content tbody.payments-table';//tbody!
    self.canvasShareSelector = "#shareUsageChart";

    self.graphs = [];

    self.updPeriod = function(_period){
        self.period = _period;
    };
    self.updDateRange = function(start, end){
        self.start = start;
        self.end = end;
    };
    self.updateData = function(updateRepresentation){

        $.post('/device/values',{
            'id' : self.id,
            'start' : self.start+"",
            'end' : self.end+"",
            'period' : self.period
        }, function(data){
            var currentData = JSON.parse(data);
            self.valuesData = currentData;
            $.post('/device/money',{
                'id' : self.id,
                'start' : self.start+"",
                'end' : self.end+"",
                'period' : self.period
            }, function(data){
                var currentData = JSON.parse(data);
                self.moneyData = currentData;
                if (updateRepresentation){
                    self.updateRepresentation();
                }
                $('#graph_tab .measure').html(typeMap[currentData.type].measure);
            });
        });
    };

    self.updateRepresentation = function(){
        self.destroyAllGraphs();
        self.graphs.push(self.setLinearGraph(self.canvasValuesSelector, self.valuesData));
        self.graphs.push(self.setLinearGraph(self.canvasMoneySelector, self.moneyData));
        self.setTable(self.valuesData, self.moneyData);
        self.setRate();
        self.setPayments();
        self.graphs.push(self.setShareGraph());
    };

    self.setLinearGraph = function(selector, data){        
        var data_points = filter_dataset(data);
        //daily
        var canvas = $(selector);
        ctxDailyUsage = canvas.get(0).getContext("2d");
        ctxDailyUsage.clearRect(0, 0, 1000, 10000);
        ctxDailyUsage.canvas.width = canvas.parent().width();
        canvas.attr("height", "250");
        var dataDailyUsage = {
            labels: data_points.labels,//labels,
            datasets: [
                {
                    label: typeMap[data.type].label,
                    fillColor: typeMap[data.type].colors.fill,
                    strokeColor: typeMap[data.type].colors.stroke,
                    pointColor: typeMap[data.type].colors.stroke,
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

    self.setTable = function(){
        var tbody = $(self.tableSelector);
        tbody.html("");
        var data_size = self.valuesData.values.length;
        for(var i = 0; i < data_size; i++){
            var current_date = new Date(i*self.period*60*1000 + self.start*1);
            var date_str = current_date.getDate() + "." + (current_date.getMonth()+1) + "." + current_date.getFullYear();
            var time_str = ("0" + current_date.getHours()).slice(-2) + ":" + ("0" + current_date.getMinutes()).slice(-2);
            tbody.append("<tr><td>"+date_str+"</td><td>"+time_str+"</td><td>"+self.valuesData.values[i].toFixed(2)+"</td><td>"+self.moneyData.values[i].toFixed(2)+"</td></tr>")
        }
    };

    self.setRate = function(){
        var tbody = $(self.rateSelector);
        tbody.html("");

        // temporary function to generate previous n dates
        var getPreviousDatesArray = function (n, curDate, array) {
            array.push(curDate.getDate() + "." + (curDate.getMonth()+1) + "." + curDate.getFullYear());
            if (n > 0) {
                curDate.setDate(curDate.getDate() - 1);
                return getPreviousDatesArray(n - 1, curDate, array);
            } else {
                return array;
            }
        };

        function generateRandomNumber(min, max) {
            return (Math.random() * (max - min) + min).toFixed(2);
        };

        var reverseDatesArray = getPreviousDatesArray(30, new Date(), []);

        var data_size = reverseDatesArray.length;
        for (var i = data_size-1; i >= 0; i--) {
            tbody.append("<tr><td>"+reverseDatesArray[i]+"</td><td>"+generateRandomNumber(66, 99)+"</td><td>"+generateRandomNumber(33, 66)+"</td><td>"+generateRandomNumber(1, 33)+"</td></tr>")
        }

    };

    self.setPayments = function(){
        var tbody = $(self.paymentsSelector);
        tbody.html("");

        // temporary function to generate previous n dates
        var getPreviousDatesArray = function (n, curDate, array) {
            array.push(curDate.getDate() + "." + (curDate.getMonth()+1) + "." + curDate.getFullYear());
            if (n > 0) {
                curDate.setDate(curDate.getDate() - 1);
                return getPreviousDatesArray(n - 1, curDate, array);
            } else {
                return array;
            }
        };

        var booleanGenerate = function() {
            return !Math.floor((Math.random() * 2));
        };

        var booleanButtonGenerate = function() {
            return '<p class="glyphicon glyphicon-'+((booleanGenerate())?'ok':'remove')+'"></p>';
        };

        var reverseDatesArray = getPreviousDatesArray(30, new Date(), []);

        var data_size = reverseDatesArray.length;
        for (var i = data_size-1; i >= 0; i--) {
            tbody.append("<tr><td>"+reverseDatesArray[i]+"</td><td>"+booleanButtonGenerate()+"</td></tr>")
        }

    };

    self.setShareGraph = function(){
        var canvas = $(self.canvasShareSelector);
        var ctxShareUsage = canvas.get(0).getContext("2d");
        ctxShareUsage.canvas.width = canvas.parent().width();
        
        var personal_costs = Math.round(sumCosts(self.moneyData));
        var all_costs = personal_costs*3;//TODO: change implementation
        var type = typeMap[self.moneyData.type];
        var dataShareUsage = [
            {
                value: all_costs,
                color:"rgba(66, 139, 202, 0.2)",
                highlight: "rgba(66, 139, 202, 0.4)",
                label: "Общие расходы (руб.)"
            },
            {
                value: Math.round(personal_costs),
                color: type.colors.stroke,
                highlight: type.colors.fill,
                label: type.label + " (руб.)"
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
        var chart = new Chart(ctxShareUsage).Doughnut(dataShareUsage, optionsShareUsage);
        return chart;
    };

    self.resizeAllGraphs = function(){
        for (var i = 0; i < self.graphs.length; i++){
            self.graphs[i].resize();
        }
    };
    self.destroyAllGraphs = function(){
        for (var i = 0; i < self.graphs.length; i++){
            self.graphs[i].destroy();
        }
    };
    self.updateDateRange = function(start, end){
        self.start = start;
        self.end = end;
    };
};

function Type(typeID, start, end, _period){    
    var self = this;

    Device.call(this, typeID, start, end, _period);

    self.isUpdated = false;
    self.updateData = function(updateRepresentation){
        self.isUpdated = false;
        $.post('/type/values',{
            'id' : self.id,
            'start' : self.start+"",
            'end' : self.end+"",
            'period' : self.period
        }, function(data){
            var currentData = JSON.parse(data);
            self.valuesData = currentData;
            $.post('/type/money',{
                'id' : self.id,
                'start' : self.start+"",
                'end' : self.end+"",
                'period' : self.period
            }, function(data){
                var currentData = JSON.parse(data);
                self.moneyData = currentData;
                if (updateRepresentation){
                    self.updateRepresentation();
                }
                $('#graph_tab .measure').html(typeMap[currentData.type].measure);
                self.isUpdated = true;
            });
        });
    };    
};

//2 lines, 3 sectors, table in sum values
function MultTypes(arr_types){
    var self = this;
    self.types = arr_types;
    self.graphs = [];

    self.updateData = function(updateRepresentation){
        for (var i = 0; i < self.types.length; i++){
            self.types[i].updateData(false);
        }
        var shouldContinue = true;
        var periodicFunction = setInterval(function(){
            if (!shouldContinue) clearInterval(periodicFunction);
            shouldContinue = false;
            for (var i = 0; i < self.types.length; i++){
                if (self.types[i].isUpdated){
                    self.updateRepresentation();
                }else{
                    shouldContinue = true;
                }
            }   
        },10);
    };

    self.updateRepresentation = function(){
        self.destroyAllGraphs();
        self.graphs.push(self.setLinearGraph(self.types[0].canvasValuesSelector));
        self.graphs.push(self.setLinearGraph(self.types[0].canvasMoneySelector));
        self.setTable();
        self.graphs.push(self.setShareGraph());
    };
    self.setLinearGraph = function(selector){   
        //daily
        var canvas = $(selector);
        ctxDailyUsage = canvas.get(0).getContext("2d");
        ctxDailyUsage.clearRect(0, 0, 1000, 10000);
        ctxDailyUsage.canvas.width = canvas.parent().width();
        canvas.attr("height", "250");
        var dataDailyUsage = {
            labels: [],
            datasets: [
            ]   
        };
        for (var i = 0; i < self.types.length; i++){
            var data_points = filter_dataset(self.types[i].valuesData);
            var type = self.types[i].valuesData.type;
            var dataset = {
                label: typeMap[type].label,
                fillColor: typeMap[type].colors.fill,
                strokeColor: typeMap[type].colors.stroke,
                pointColor: typeMap[type].colors.stroke,
                pointStrokeColor: "#fff",
                pointHighlightFill: "#fff",
                pointHighlightStroke: "rgba(220,220,220,1)",
                data: data_points.values
            }
            dataDailyUsage.datasets.push(dataset);
            dataDailyUsage.labels = data_points.labels;
        }
        optionsDailyUsage = {
            scaleShowGridLines : false,
            showTooltips: true,
            responsive: true,
            legendTemplate : "<div class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=-1; i<datasets.length; i++){%><%if(!datasets[i]){%><p onclick=\"focusDataSet(<%=i%>)\"><span>●</span>Показать всё</p><%} else {%><p onclick=\"focusDataSet(<%=i%>)\"><span style=\"color:<%=datasets[i].strokeColor%>\">●</span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></p><%}}%></div>"
        };
        var chart = new Chart(ctxDailyUsage).Line(dataDailyUsage, optionsDailyUsage);
        return chart;
    };

    self.setTable = function(){
        var tbody = $(self.types[0].tableSelector);
        tbody.html("");
        var data_size = self.types[0].valuesData.values.length;
        var period = self.types[0].period,
            start = self.types[0].start;
        for(var i = 0; i < data_size; i++){
            var current_date = new Date(i*period*60*1000 + start*1);
            var date_str = current_date.getDate() + "." + (current_date.getMonth()+1) + "." + current_date.getFullYear();
            var time_str = ("0" + current_date.getHours()).slice(-2) + ":" + ("0" + current_date.getMinutes()).slice(-2);
            var volume = 0,
                money = 0;
            for (var j = 0; j < self.types.length; j++){
                volume += self.types[j].valuesData.values[i];
                money += self.types[j].moneyData.values[i];
            }
            tbody.append("<tr><td>"+date_str+"</td><td>"+time_str+"</td><td>"+volume.toFixed(2)+"</td><td>"+money.toFixed(2)+"</td></tr>")
        }
    };

    self.setShareGraph = function(){
        var canvas = $(self.types[0].canvasShareSelector);
        var ctxShareUsage = canvas.get(0).getContext("2d");
        ctxShareUsage.canvas.width = canvas.parent().width();

        var dataShareUsage = [];
        for (var i = 0; i < self.types.length; i++){
            var costs = sumCosts(self.types[i].moneyData);
            var type = typeMap[self.types[i].moneyData.type];
            dataShareUsage.push({
                value: Math.round(costs),
                color: type.colors.stroke,
                highlight: type.colors.fill,
                label: type.label + " (руб.)"
            });
        }
        var all_costs = sumCosts(self.types[0].moneyData) * 5;//TODO: change implementation
        dataShareUsage.push({
            value: Math.round(all_costs),
            color:"rgba(66, 139, 202, 0.1)",
            highlight: "rgba(66, 139, 202, 0.2)",
            label: "Общие расходы (руб.)"
        });
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
        var chart = new Chart(ctxShareUsage).Doughnut(dataShareUsage, optionsShareUsage);
        return chart;
    };

    self.resizeAllGraphs = function(){
        for (var i = 0; i < self.graphs.length; i++){
            self.graphs[i].resize();
        }
    };
    self.destroyAllGraphs = function(){
        for (var i = 0; i < self.graphs.length; i++){
            self.graphs[i].destroy();
        }
    }; 
    self.updPeriod = function(_period){
        for (var i = 0; i < self.types.length; i++) self.types[i].updPeriod(_period);
    };
    
    self.updateDateRange = function(start, end){
        for (var i = 0; i < self.types.length; i++) self.types[i].updDateRange(start, end);  
    };
}


//obj type+wholedata of type
function odnItem(type, start, end, _period){
    var self = this;
    
    Type.call(this, type, start, end, _period);

    self.odnData = {};
    self.selector = typeMap[type].odnSelector;

    self.updateData = function(updateRepresentation){
        self.isUpdated = false;
        $.post('/type/money',{
            'id' : self.id,
            'start' : self.start+"",
            'end' : self.end+"",
            'period' : self.period
        }, function(data){
            var currentData = JSON.parse(data);
            self.moneyData = currentData;
            $.post('/house/money',{
                'types' : [self.id],
                'start' : self.start+"",
                'end' : self.end+"",
                'period' : self.period
            }, function(data){
                var currentData = JSON.parse(data);
                self.odnData = currentData;
                self.odnData.values = currentData.values[0];
                if (updateRepresentation){
                    self.updateRepresentation();
                }
                // $('#graph_tab .measure').html(typeMap[currentData.type].measure);
                self.isUpdated = true;
            });
        });
    };
    self.updateRepresentation = function(){
        self.destroyAllGraphs();
        self.graphs.push(self.setLinearGraph());
        self.setTable();
    };

    self.setLinearGraph = function(){
        //daily
        var canvas = $(self.selector);
        ctxDailyUsage = canvas.get(0).getContext("2d");
        ctxDailyUsage.clearRect(0, 0, 1000, 10000);
        ctxDailyUsage.canvas.width = canvas.parent().width();
        canvas.attr("height", "250");
        var dataDailyUsage = {
            labels: [],
            datasets: [
            ]   
        };
       
        var data_points = filter_dataset(self.moneyData);
        var type = self.id;
        var dataset = {
            label: typeMap[type].label,
            fillColor: typeMap[type].colors.stroke,
            strokeColor: typeMap[type].colors.stroke,
            pointColor: typeMap[type].colors.stroke,
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: "rgba(220,220,220,1)",
            data: data_points.values
        }
        dataDailyUsage.datasets.push(dataset);
        dataDailyUsage.labels = data_points.labels;

        data_points = filter_dataset(self.odnData);
        var datasetOdn = {
            label: typeMap[type].label,
            fillColor: typeMap[type].colors.fill,
            strokeColor: typeMap[type].colors.stroke,
            pointColor: typeMap[type].colors.stroke,
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: "rgba(220,220,220,1)",
            data: data_points.values
        }
        dataDailyUsage.datasets.push(datasetOdn);


        optionsDailyUsage = {
            scaleShowGridLines : false,
            showTooltips: true,
            responsive: true,
            legendTemplate : "<div class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=-1; i<datasets.length; i++){%><%if(!datasets[i]){%><p onclick=\"focusDataSet(<%=i%>)\"><span>●</span>Показать всё</p><%} else {%><p onclick=\"focusDataSet(<%=i%>)\"><span style=\"color:<%=datasets[i].strokeColor%>\">●</span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></p><%}}%></div>"
        };
        var chart = new Chart(ctxDailyUsage).Line(dataDailyUsage, optionsDailyUsage);
        return chart;
    };
    self.setTable = function(){
        var data = self.moneyData;
        var tableID = "table_" + self.selector.substr(self.selector.lastIndexOf("odn") + 3).toLowerCase();
        var current_tbody = $('#'+tableID+' tbody');
        current_tbody.html("");
        var data_size = data.values.length;
        for(var i = 0; i < data_size; i++){
            var current_date = new Date(i*data.period*60*1000 + data.start*1);
            var date_str = current_date.getDate() + "." + (current_date.getMonth()+1) + "." + current_date.getFullYear();
            var time_str = ("0" + current_date.getHours()).slice(-2) + ":" + ("0" + current_date.getMinutes()).slice(-2);
            current_tbody.append("<tr><td>"+time_str+"</td><td>"+time_str+"</td><td>"+(data.values[i]).toFixed(2)+"</td><td>"+(self.odnData.values[i]).toFixed(2)+"</td></tr>")
        }
    };
}
function ODN(arr_odnitems){
    var self = this;

    self.odnItems = arr_odnitems;

    self.updateData = function(updateRepresentation){
        self.destroyAllGraphs();
        for (var i = 0; i < self.odnItems.length; i++) self.odnItems[i].updateData(updateRepresentation);
    };
    self.updateRepresentation = function(){
        for (var i = 0; i < self.odnItems.length; i++) self.odnItems[i].updateRepresentation();
    };
    self.destroyAllGraphs = function(){
        for (var i = 0; i < self.odnItems.length; i++) self.odnItems[i].destroyAllGraphs();
    }
}
var getTimeFormatddmmyyyy = function(date_ms){
    var current_date = new Date(date_ms);
    var date_str = current_date.getDate() + "." + (current_date.getMonth()+1) + "." + current_date.getFullYear();
    return date_str;
}