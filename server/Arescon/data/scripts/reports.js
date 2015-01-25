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
var hideAllDataBlocks = function(){
    $('.data_block').hide();
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
var initDatePicker = function(name){
    $('input[name="'+ name +'"]').daterangepicker(
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
            },
            singleDatePicker: true
        },
        function(start, end) {
            daterangeStart = start;
            daterangeEnd = end; 
            
            currentPageData.addDate(start);
        }
    );
};
$('#period').change(function(e){
    var period = $(this).val();

    currentPageData.updPeriod(period);
    currentPageData.updateData(true);
});
$('#forecast_period').change(function(e){
    var period = $(this).val();

    currentPageData.updPeriod(period);
    currentPageData.updateData(true);
});
$('#deviation').change(function(e){
    var deviation = $(this).val()/100;

    currentPageData.updDeviation(deviation);
    currentPageData.updateData(true);
});
var interfaceInit = function(only){
    $('.data_block').hide();
    switch(only){
        case '0':
            $('#type_coldwater').show();
            break;
        case '1':
            $('#type_hotwater').show();
            break;
        case '2':
            $('#type_gas').show();
            break;
        case '3':
            $('#type_electricity').show();
            break;
        case '4':
            $('#type_heat').show();
            break;
        default:
            $('.data_block').show();
            break;
    }
    $('#type_share').hide();
}
var buildPageData = function(reporttype, period, start, end){
    var selectiontype = getParameterByName('selectiontype');
    // here we will write smthg about with report
    var descriptionObj = {
        1: 'Profile',
        2: 'Forecast',
        3: 'Multiple',
        4: 'Share',
        5: 'ODN',
        6: 'Deviation',
        7: 'ShareLines'
    }
    $('.percentpicker,.forecastpicker').hide();
    $('#add_interval,.datepicker').hide();
    $('.rangepicker,.frequencypicker').show();
    $('.table,.share').show();
    $('#type_deviation').hide();
    $('.reportdescription').text(descriptionObj[reporttype]);

    if (typeof currentPageData !== 'undefined') {
        currentPageData.destroyAllData();
        $( ".legend" ).remove();
    }

    if (selectiontype === '5' || selectiontype === '4'){
        $('#reporttype option[value="4"]').hide();
        $('#reporttype option[value="6"]').show();
    }else{
        $('#reporttype option[value="6"]').hide();
        $('#reporttype option[value="4"]').show();
    }
    if (selectiontype === '4'){
        $('#reporttype option[value="5"]').show();
    }else{
        $('#reporttype option[value="5"]').hide();
    }
    if (selectiontype === '3' || selectiontype === '4'){
        $('#reporttype option[value="7"]').show();
    }else{
        $('#reporttype option[value="7"]').hide();
    }
    if (reporttype === '1'){
        var id = getParameterByName('id');
        currentPageData = new Profile(id, start, end, period, selectiontype);     
    }else if (reporttype === '2'){
        var id = getParameterByName('id');
        $('.rangepicker,.frequencypicker').hide();
        currentPageData = new Forecast(id, start, end, period, selectiontype); 
    }else if (reporttype === '3'){
        var id = getParameterByName('id');
        $('#add_interval').show();
        currentPageData = new Multiple(id, start, end, period, selectiontype); 
    }else if (reporttype === '4'){
        var id = getParameterByName('id');
        $('.frequencypicker').hide();
        currentPageData = new Share(id, start, end, period, selectiontype); 
    }else if (reporttype === '5'){
        var id = getParameterByName('id');
        currentPageData = new ODN(id, start, end, period, selectiontype); 
    }else if (reporttype === '6'){
        var id = getParameterByName('id');
        currentPageData = new Deviation(id, start, end, period, selectiontype); 
    }else if (reporttype === '7'){
        var id = getParameterByName('id');
        currentPageData = new ShareLines(id, start, end, period, selectiontype); 
    }else{//no PageData
        //let user watch previous reports
        console.log("nothing to do here");
        return;
    }
    currentPageData.updateData(true);
}
$('#add_interval').click(function(){
    if ($('.datepicker[style="display: none;"]').length){
        var new_picker = $('.datepicker[style="display: none;"]:first');
        new_picker.attr('style', 'display: block;');
        initDatePicker(new_picker.children('input').attr('name'));
        // currentPageData.addDate(new Date());    
    }    
});
$('.datepicker .btn-danger').click(function(){
    var index = $('.datepicker[style="display: block;"]').index($(this).parent());

    $(this).parent().attr('style', 'display: none;');
    // alert(index);
    currentPageData.removeDate(index);
});
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
            self.multipleDataFetch(selectiontype_str, updateRepresentation);
            return;
        }else if (selectiontype === '2'){//house
            selectiontype_str = 'house';
            self.multipleDataFetch(selectiontype_str, updateRepresentation);
            return;
        }else if (selectiontype === '1'){//tszh
            selectiontype_str = 'tszh';
            self.multipleDataFetch(selectiontype_str, updateRepresentation);
            return;
        }else if (selectiontype === '0'){//uk
            selectiontype_str = 'uk';
            self.multipleDataFetch(selectiontype_str, updateRepresentation);
            return;
        }

        $.post('/' + selectiontype_str + '/values',{
            'id' : self.id,
            'start' : self.start+"",
            'end' : self.end+"",
            'period' : self.period
        }, function(data){
            var currentData = JSON.parse(data);
            self.valuesData = currentData;

            $.post('/' + selectiontype_str + '/profile/values',{
                'id' : self.id,//TODO: change implementation
                'start' : '0',
                'end' : '99999999999999',
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

    self.multipleDataFetch = function(selectiontype_str, updateRepresentation){
        $.post('/' + selectiontype_str + '/values',{
            'types' : [0,1,2,3,4],
            'start' : self.start+"",
            'end' : self.end+"",
            'period' : self.period
        }, function(data){
            var currentData = JSON.parse(data);
            self.valuesData = currentData;
            $.post('/' + selectiontype_str + '/profile/values',{
                'types' : [0,1,2,3,4],
                'start' : '0',
                'end' : '99999999999999',
                'period' : self.period,
                'count' : self.valuesData.values[0].length
            }, function(data){
                var currentData = JSON.parse(data);
                self.profileData = currentData;
                if (updateRepresentation){
                    self.updateRepresentation();
                }
                self.isUpdated = true;
            });
        });
    };
    self.updateRepresentation = function(){        
        self.destroyAllData();
        if(selectiontype === '5' || selectiontype === '4'){//one
            $(typeMap[self.profileData.type].selector).show();
            $('.table,.share').hide();
            self.graphs.push(self.setLinearGraph(self.profileData, self.valuesData));
            self.graphs.push(self.setRublesGraph(self.profileData, self.valuesData));
        }else{//multiple
            $('.data_block').show();
            $('#type_share').hide();
            $('#type_hide').hide();
            $('.table,.share').hide();
            interfaceInit(getParameterByName('only'));
            for (var i = 0; i < self.profileData.values.length; i++){
                self.graphs.push(self.setLinearGraph({
                    type : i,
                    start : self.profileData.start,
                    period : self.profileData.period,
                    values : self.profileData.values[i]
                }, {
                    type : i,
                    start : self.valuesData.start,
                    period : self.valuesData.period,
                    values : self.valuesData.values[i]
                }));
            }
            
        } 
    };
    self.setLinearGraph = function(profileData, valuesData){        
        var data_points = filter_dataset(profileData);
        //daily
        var selector = typeMap[profileData.type].selector + ' .linear';
        var canvas = $(selector);
        ctxDailyUsage = canvas.get(0).getContext("2d");
        ctxDailyUsage.clearRect(0, 0, 1000, 10000);
        ctxDailyUsage.canvas.width = canvas.parent().width();
        canvas.attr("height", "250");
        var dataDailyUsage = {
            datasets: [
                {
                    label: typeMap[profileData.type].label,
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
        data_points = filter_dataset(valuesData);
        dataDailyUsage.datasets.push({
            label: typeMap[valuesData.type].label,
            fillColor: typeMap[valuesData.type].colors.fill,
            strokeColor: typeMap[valuesData.type].colors.stroke,
            pointColor: typeMap[valuesData.type].colors.stroke,
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
//            legendTemplate : "<div class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=-1; i<datasets.length; i++){%><%if(!datasets[i]){%><p onclick=\"focusDataSet(<%=i%>)\"><span>●</span>Показать всё</p><%} else {%><p onclick=\"focusDataSet(<%=i%>)\"><span style=\"color:<%=datasets[i].strokeColor%>\">●</span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></p><%}}%></div>"
            legendTemplate : "<div class=\"legend <%=name.toLowerCase()%>-legend\"><% for (var i=0; i<datasets.length; i++){%><p onclick=\"focusDataSet(<%=i%>)\"><span style=\"color:<%=datasets[i].strokeColor%>\">●</span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></p><%}%></div>"
        };
        var chart = new Chart(ctxDailyUsage).Line(dataDailyUsage, optionsDailyUsage);
        // put legend (temporary on the bottom)
        canvas.after(chart.generateLegend());
        return chart;
    };
    self.setRublesGraph = function(profileData, valuesData){
        var data_points = filter_dataset(profileData);
        //daily
        var selector = typeMap[profileData.type].selector + ' .rubles';
        var canvas = $(selector);
        ctxDailyUsage = canvas.get(0).getContext("2d");
        ctxDailyUsage.clearRect(0, 0, 1000, 10000);
        ctxDailyUsage.canvas.width = canvas.parent().width();
        canvas.attr("height", "250");
        var dataDailyUsage = {
            datasets: [
                {
                    label: "Среднее",
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
        data_points = filter_dataset(valuesData);
        dataDailyUsage.datasets.push({
            label: typeMap[valuesData.type].label,
            fillColor: typeMap[valuesData.type].colors.fill,
            strokeColor: typeMap[valuesData.type].colors.stroke,
            pointColor: typeMap[valuesData.type].colors.stroke,
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
//            legendTemplate : "<div class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=-1; i<datasets.length; i++){%><%if(!datasets[i]){%><p onclick=\"focusDataSet(<%=i%>)\"><span>●</span>Показать всё</p><%} else {%><p onclick=\"focusDataSet(<%=i%>)\"><span style=\"color:<%=datasets[i].strokeColor%>\">●</span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></p><%}}%></div>"
            legendTemplate : "<div class=\"legend <%=name.toLowerCase()%>-legend\"><% for (var i=0; i<datasets.length; i++){%><p onclick=\"focusDataSet(<%=i%>)\"><span style=\"color:<%=datasets[i].strokeColor%>\">●</span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></p><%}%></div>"
        };
        var chart = new Chart(ctxDailyUsage).Line(dataDailyUsage, optionsDailyUsage);
        // put legend (temporary on the bottom)
        canvas.after(chart.generateLegend());
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
function Forecast(id, start, end, period, selectiontype){
    var self = this;

    PageData.call(this, id, start, end, period, selectiontype);  

    self.period = $('#forecast_period').val();
    var map = [];
    map['1440'] = {period: 60,count: 24};
    map['302400'] = {period: 1440,count: 30};
    map['907200'] = {period: 43200,count: 3};
    map['3628800'] = {period: 43200,count: 12};

    self.updateData = function(updateRepresentation){
        self.isUpdated = false;
        
        var selectiontype_str = '';
        if(selectiontype === '5'){//device
            selectiontype_str = 'device';
        }else if (selectiontype === '4'){//type
            selectiontype_str = 'type';
        }else if (selectiontype === '3'){//flat
            selectiontype_str = 'flat';
            self.multipleDataFetch(selectiontype_str, updateRepresentation);
            return;
        }else if (selectiontype === '2'){//house
            selectiontype_str = 'house';
            self.multipleDataFetch(selectiontype_str, updateRepresentation);
            return;
        }else if (selectiontype === '1'){//tszh
            selectiontype_str = 'tszh';
            self.multipleDataFetch(selectiontype_str, updateRepresentation);
            return;
        }else if (selectiontype === '0'){//uk
            selectiontype_str = 'uk';
            self.multipleDataFetch(selectiontype_str, updateRepresentation);
            return;
        }
        $.post('/' + selectiontype_str + '/profile/values',{
            'id' : self.id,
            'start' : '0',
            'end' : '99999999999999',
            'period' : map[self.period].period,
            'count' : map[self.period].count
        }, function(data){
            var currentData = JSON.parse(data);
            self.profileData = currentData;
            
            if (updateRepresentation){
                self.updateRepresentation();
            }
            // $('#graph_tab .measure').html(typeMap[currentData.type].measure);
            self.isUpdated = true;
        });
    };

    self.multipleDataFetch = function(selectiontype_str, updateRepresentation){
        $.post('/' + selectiontype_str + '/profile/values',{
            'types' : [0,1,2,3,4],
            'start' : '0',
            'end' : '99999999999999',
            'period' : map[self.period].period,
            'count' : map[self.period].count
            // 'period' : '1440',
            // 'count' : '30'
        }, function(data){
            var currentData = JSON.parse(data);
            self.profileData = currentData;
            
            if (updateRepresentation){
                self.updateRepresentation();
            }
            self.isUpdated = true;
        });
    };
    self.updateRepresentation = function(){        
        self.destroyAllData();
        $('.forecastpicker').show();
        if(selectiontype === '5' || selectiontype === '4'){//one
            $(typeMap[self.profileData.type].selector).show();
            $('.table,.share').hide();
            self.graphs.push(self.setLinearGraph(self.profileData));
            self.graphs.push(self.setRublesGraph(self.profileData));
        }else{//multiple
            $('.data_block').show();
            $('#type_deviation').hide();
            $('.table,.share').hide();
            interfaceInit(getParameterByName('only'));
            for (var i = 0; i < self.profileData.values.length; i++){
                self.graphs.push(self.setLinearGraph({
                    type : i,
                    start : self.profileData.start,
                    period : self.profileData.period,
                    values : self.profileData.values[i]
                }));
            }            
        } 
        $('#type_share').hide();
    };
    self.setLinearGraph = function(profileData){ 
        profileData.start = new Date();       
        var data_points = filter_dataset(profileData);
        
        //daily
        var selector = typeMap[profileData.type].selector + ' .linear';
        var canvas = $(selector);
        ctxDailyUsage = canvas.get(0).getContext("2d");
        ctxDailyUsage.clearRect(0, 0, 1000, 10000);
        ctxDailyUsage.canvas.width = canvas.parent().width();
        canvas.attr("height", "250");
        var dataDailyUsage = {
            datasets: [
                {
                    label: typeMap[profileData.type].label,
                    fillColor: 'rgb(244, 247, 251)',
                    strokeColor: '#707DB5',
                    pointColor: '#707DB5',
                    pointStrokeColor: "#fff",
                    pointHighlightFill: "#fff",
                    pointHighlightStroke: "rgba(220,220,220,1)",
                    data: data_points.values
                }
            ]   
        };
        dataDailyUsage.labels = data_points.labels;
        optionsDailyUsage = {
            scaleShowGridLines : false,
            showTooltips: true,
            responsive: true,
//            legendTemplate : "<div class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=-1; i<datasets.length; i++){%><%if(!datasets[i]){%><p onclick=\"focusDataSet(<%=i%>)\"><span>●</span>Показать всё</p><%} else {%><p onclick=\"focusDataSet(<%=i%>)\"><span style=\"color:<%=datasets[i].strokeColor%>\">●</span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></p><%}}%></div>"
            legendTemplate : "<div class=\"legend<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<datasets.length; i++){%><p onclick=\"focusDataSet(<%=i%>)\"><span style=\"color:<%=datasets[i].strokeColor%>\">●</span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></p><%}%></div>"
        };
        var chart = new Chart(ctxDailyUsage).Line(dataDailyUsage, optionsDailyUsage);
        // put legend (temporary on the bottom)
        canvas.after(chart.generateLegend());
        return chart;
    };
    self.setRublesGraph = function(profileData){
        profileData.start = new Date();
        var data_points = filter_dataset(profileData);

        //daily
        var selector = typeMap[profileData.type].selector + ' .linear';
        var canvas = $(selector);
        ctxDailyUsage = canvas.get(0).getContext("2d");
        ctxDailyUsage.clearRect(0, 0, 1000, 10000);
        ctxDailyUsage.canvas.width = canvas.parent().width();
        canvas.attr("height", "250");
        var dataDailyUsage = {
            datasets: [
                {
                    label: typeMap[profileData.type].label,
                    fillColor: 'rgb(244, 247, 251)',
                    strokeColor: '#707DB5',
                    pointColor: '#707DB5',
                    pointStrokeColor: "#fff",
                    pointHighlightFill: "#fff",
                    pointHighlightStroke: "rgba(220,220,220,1)",
                    data: data_points.values
                }
            ]
        };
        dataDailyUsage.labels = data_points.labels;
        optionsDailyUsage = {
            scaleShowGridLines : false,
            showTooltips: true,
            responsive: true,
//            legendTemplate : "<div class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=-1; i<datasets.length; i++){%><%if(!datasets[i]){%><p onclick=\"focusDataSet(<%=i%>)\"><span>●</span>Показать всё</p><%} else {%><p onclick=\"focusDataSet(<%=i%>)\"><span style=\"color:<%=datasets[i].strokeColor%>\">●</span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></p><%}}%></div>"
            legendTemplate : "<div class=\"legend <%=name.toLowerCase()%>-legend\"><% for (var i=0; i<datasets.length; i++){%><p onclick=\"focusDataSet(<%=i%>)\"><span style=\"color:<%=datasets[i].strokeColor%>\">●</span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></p><%}%></div>"
        };
        var chart = new Chart(ctxDailyUsage).Line(dataDailyUsage, optionsDailyUsage);
        // put legend (temporary on the bottom)
        canvas.after(chart.generateLegend());
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
function Multiple(id, start, end, period, selectiontype){
    var self = this;

    PageData.call(this, id, start, end, period, selectiontype); 

    self.valuesData = [];
    self.dates = [];
    self.requstStatus = [];
  
    self.addDate = function(date){
        self.dates.push(date);
        self.updateData(true);
    };
    self.removeDate = function(index){
        self.dates.splice(index, 1);
        self.updateData(true);
    };
    self.updateData = function(updateRepresentation){
        self.isUpdated = false;
        self.valuesData = [];
        self.requstStatus = [];
        //post for each data (separately) and push result to vdata[]
        //on end upd repr
        var selectiontype_str = '';
        if(selectiontype === '5'){//device
            selectiontype_str = 'device';
        }else if (selectiontype === '4'){//type
            selectiontype_str = 'type';
        }else if (selectiontype === '3'){//flat
            selectiontype_str = 'flat';
            self.multipleDataFetch(selectiontype_str, updateRepresentation);
            return;
        }else if (selectiontype === '2'){//house
            selectiontype_str = 'house';
            self.multipleDataFetch(selectiontype_str, updateRepresentation);
            return;
        }else if (selectiontype === '1'){//tszh
            selectiontype_str = 'tszh';
            self.multipleDataFetch(selectiontype_str, updateRepresentation);
            return;
        }else if (selectiontype === '0'){//uk
            selectiontype_str = 'uk';
            self.multipleDataFetch(selectiontype_str, updateRepresentation);
            return;
        }
        //single graph multiple data fetch
        $.post('/' + selectiontype_str + '/values',{
            'id' : self.id,
            'start' : self.start+"",
            'end' : self.end+"",
            'period' : self.period
        }, function(data){
            var currentData = JSON.parse(data);
            self.valuesData.push(currentData);
            self.requstStatus.push(true);

            $.post('/' + selectiontype_str + '/profile/values',{
                'id' : self.id,
                'start' : '0',
                'end' : '99999999999999',
                'period' : self.period,
                'count' : self.valuesData[0].values.length
            }, function(data){
                var currentData = JSON.parse(data);
                self.profileData = currentData;
                self.requstStatus.push(true);
                self.dates.forEach(function(entry){
                    $.post('/' + selectiontype_str + '/values',{
                        'id' : self.id,
                        'start' : entry+"",
                        'end' : (entry + (self.end - self.start))+"",
                        'period' : self.period
                    }, function(data){
                        var currentData = JSON.parse(data);
                        self.valuesData.push(currentData);
                        self.requstStatus.push(true);
                    });
                });
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

    self.multipleDataFetch = function(selectiontype_str, updateRepresentation){
        //multiple graph multiple data fetch
        $.post('/' + selectiontype_str + '/values',{
            'types' : [0,1,2,3,4],
            'start' : self.start+"",
            'end' : self.end+"",
            'period' : self.period
        }, function(data){
            var currentData = JSON.parse(data);
            self.valuesData.push(currentData);
            self.requstStatus.push(true);

            $.post('/' + selectiontype_str + '/profile/values',{
                'types' : [0,1,2,3,4],
                'start' : '0',
                'end' : '99999999999999',
                'period' : self.period,
                'count' : self.valuesData[0].values[0].length
            }, function(data){
                var currentData = JSON.parse(data);
                self.profileData = currentData;
                self.requstStatus.push(true);
                self.dates.forEach(function(entry){
                    $.post('/' + selectiontype_str + '/values',{
                        'types' : [0,1,2,3,4],
                        'start' : entry+"",
                        'end' : (entry + (self.end - self.start))+"",
                        'period' : self.period
                    }, function(data){
                        var currentData = JSON.parse(data);
                        self.valuesData.push(currentData);
                        self.requstStatus.push(true);
                    });
                });
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
        self.destroyAllData();
        if(selectiontype === '5' || selectiontype === '4'){//one
            $(typeMap[self.profileData.type].selector).show();
            $('.table,.share').hide();
            self.graphs.push(self.setLinearGraph(self.profileData, self.valuesData, -1));
            self.graphs.push(self.setRublesGraph(self.profileData, self.valuesData, -1));
        }else{//multiple
            $('.data_block').show();
            $('#type_deviation').hide();
            $('#type_share').hide();
            $('.table,.share').hide();
            interfaceInit(getParameterByName('only'));
            for (var i = 0; i < self.profileData.values.length; i++){
                self.graphs.push(self.setLinearGraph(self.profileData, self.valuesData, i));
            }
            
        } 
    };
    self.setLinearGraph = function(profileData, valuesData, type){  
        var data_points = filter_dataset({
            type: type == -1 ? profileData.type : type,
            start: profileData.start,
            period: profileData.period,
            values: type == -1 ? profileData.values : profileData.values[type]
        });
        //daily
        var selector = typeMap[type == -1 ? profileData.type : type].selector + ' .linear';
        var canvas = $(selector);
        ctxDailyUsage = canvas.get(0).getContext("2d");
        ctxDailyUsage.clearRect(0, 0, 1000, 10000);
        ctxDailyUsage.canvas.width = canvas.parent().width();
        canvas.attr("height", "250");
        var dataDailyUsage = {
            datasets: [
                {
                    label: getTimeFormatddmmyyyy(valuesData[0].start),
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
        if (type == -1){
            type = profileData.type;
            for (var i = self.valuesData.length-1; i >= 0; i--){
                data_points = filter_dataset({
                    type: type,
                    start: self.valuesData[0].start,
                    period: profileData.period,
                    values: valuesData[i].values
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
            }
        }else{
            for (var i = 0; i < self.valuesData.length; i++){
                data_points = filter_dataset({
                    type: type,
                    start: self.valuesData[0].start,
                    period: profileData.period,
                    values: valuesData[i].values[type]
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
            }
        }
        
        dataDailyUsage.labels = data_points.labels;
        optionsDailyUsage = {
            // multiTooltipTemplate: "<%if (datasetIndex){%><%=datasetIndex%>: <%}%><%= value %>",
            scaleShowGridLines : false,
            showTooltips: true,
            responsive: true,
//            legendTemplate : "<div class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=-1; i<datasets.length; i++){%><%if(!datasets[i]){%><p onclick=\"focusDataSet(<%=i%>)\"><span>●</span>Показать всё</p><%} else {%><p onclick=\"focusDataSet(<%=i%>)\"><span style=\"color:<%=datasets[i].strokeColor%>\">●</span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></p><%}}%></div>"
            legendTemplate : "<div class=\"legend <%=name.toLowerCase()%>-legend\"><% for (var i=0; i<datasets.length; i++){%><p onclick=\"focusDataSet(<%=i%>)\"><span style=\"color:<%=datasets[i].strokeColor%>\">●</span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></p><%}%></div>"
        };
        var chart = new Chart(ctxDailyUsage).Line(dataDailyUsage, optionsDailyUsage);
        // put legend (temporary on the bottom)
        canvas.after(chart.generateLegend());
        return chart;
    };
    self.setRublesGraph = function(profileData, valuesData, type){
        var data_points = filter_dataset({
            type: type == -1 ? profileData.type : type,
            start: profileData.start,
            period: profileData.period,
            values: type == -1 ? profileData.values : profileData.values[type]
        });
        //daily
        var selector = typeMap[type == -1 ? profileData.type : type].selector + ' .linear';
        var canvas = $(selector);
        ctxDailyUsage = canvas.get(0).getContext("2d");
        ctxDailyUsage.clearRect(0, 0, 1000, 10000);
        ctxDailyUsage.canvas.width = canvas.parent().width();
        canvas.attr("height", "250");
        var dataDailyUsage = {
            datasets: [
                {
                    label: getTimeFormatddmmyyyy(valuesData[0].start),
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
        if (type == -1){
            type = profileData.type;
            for (var i = self.valuesData.length-1; i >= 0; i--){
                data_points = filter_dataset({
                    type: type,
                    start: self.valuesData[0].start,
                    period: profileData.period,
                    values: valuesData[i].values
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
            }
        }else{
            for (var i = 0; i < self.valuesData.length; i++){
                data_points = filter_dataset({
                    type: type,
                    start: self.valuesData[0].start,
                    period: profileData.period,
                    values: valuesData[i].values[type]
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
            }
        }

        dataDailyUsage.labels = data_points.labels;
        optionsDailyUsage = {
            // multiTooltipTemplate: "<%if (datasetIndex){%><%=datasetIndex%>: <%}%><%= value %>",
            scaleShowGridLines : false,
            showTooltips: true,
            responsive: true,
//            legendTemplate : "<div class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=-1; i<datasets.length; i++){%><%if(!datasets[i]){%><p onclick=\"focusDataSet(<%=i%>)\"><span>●</span>Показать всё</p><%} else {%><p onclick=\"focusDataSet(<%=i%>)\"><span style=\"color:<%=datasets[i].strokeColor%>\">●</span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></p><%}}%></div>"
            legendTemplate : "<div class=\"legend <%=name.toLowerCase()%>-legend\"><% for (var i=0; i<datasets.length; i++){%><p onclick=\"focusDataSet(<%=i%>)\"><span style=\"color:<%=datasets[i].strokeColor%>\">●</span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></p><%}%></div>"
        };
        var chart = new Chart(ctxDailyUsage).Line(dataDailyUsage, optionsDailyUsage);
        // put legend (temporary on the bottom)
        canvas.after(chart.generateLegend());
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
function Share(id, start, end, period, selectiontype){
    var self = this;

    PageData.call(this, id, start, end, period, selectiontype);  

    

    self.updateData = function(updateRepresentation){
        self.isUpdated = false;

        
        var selectiontype_str = '';
        if (selectiontype === '3'){//flat
            selectiontype_str = 'flat';
        }else if (selectiontype === '2'){//house
            selectiontype_str = 'house';
        }else if (selectiontype === '1'){//tszh
            selectiontype_str = 'tszh';
        }else if (selectiontype === '0'){//uk
            selectiontype_str = 'uk';
        }

        $.post('/' + selectiontype_str + '/money',{
            'types' : [0,1,2,3,4],
            'start' : self.start+"",
            'end' : self.end+"",
            'period' : self.period
        }, function(data){
            var currentData = JSON.parse(data);
            self.moneyData = currentData;

            
            if (updateRepresentation){
                self.updateRepresentation();
            }
            // $('#graph_tab .measure').html(typeMap[currentData.type].measure);
            self.isUpdated = true;
        });
    };

    self.updateRepresentation = function(){ 
        self.destroyAllData();
        $('.data_block').hide();
        $('#type_deviation').hide();
        $('#type_share').show();
        self.graphs.push(self.setShareGraph());
    };

    self.setShareGraph = function(){
        var canvas = $('#type_share .share');
        var ctxShareUsage = canvas.get(0).getContext("2d");
        ctxShareUsage.canvas.width = canvas.parent().width();
        
        var dataShareUsage = [];
        for(var i = 0; i < self.moneyData.values.length; i++){
            var sum = 0;
            for(var j = 0; j < self.moneyData.values[i].length; j++){
                sum += self.moneyData.values[i][j];
            }
            dataShareUsage.push({
                value: toFixed(sum, 2),
                color: typeMap[self.moneyData.types[i]].colors.fillDarken,
                highlight: typeMap[self.moneyData.types[i]].colors.stroke,
                label: typeMap[self.moneyData.types[i]].label
            });
        }
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
}
function ODN(id, start, end, period, selectiontype){
    var self = this;

    PageData.call(this, id, start, end, period, selectiontype); 

    self.valuesData = [];
    self.dates = [];
    self.requstStatus = [];
  
    self.updateData = function(updateRepresentation){
        self.isUpdated = false;
        self.valuesData = [];
        self.requstStatus = [];
        //post for each data (separately) and push result to vdata[]
        //on end upd repr
        var selectiontype_str = '';
        if(selectiontype === '5'){//device
            selectiontype_str = 'device';
        }else if (selectiontype === '4'){//type
            selectiontype_str = 'type';
        }else if (selectiontype === '3'){//flat
            selectiontype_str = 'flat';
            self.multipleDataFetch(selectiontype_str, updateRepresentation);
            return;
        }else {
            return;
        }
        //single graph multiple data fetch
        $.post('/' + selectiontype_str + '/money',{
            'id' : self.id,
            'start' : self.start+"",
            'end' : self.end+"",
            'period' : self.period
        }, function(data){
            var currentData = JSON.parse(data);
            self.valuesData = currentData;
            self.requstStatus.push(true);

            $.post('/house/money',{
                'types' : [self.id],
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

    self.multipleDataFetch = function(selectiontype_str, updateRepresentation){
        //multiple graph multiple data fetch
        $.post('/' + selectiontype_str + '/money',{
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
        self.destroyAllData();
        if(selectiontype === '5' || selectiontype === '4'){//one
            
            $(typeMap[self.profileData.types[0]].selector).show();

            $('.table,.share').show();

            self.graphs.push(self.setLinearGraph(self.profileData, self.valuesData, -1));
            var selector = typeMap[self.profileData.types[0]].selector + ' table';
            self.setTable(selector, self.profileData.values[0], self.valuesData.values);
            selector = typeMap[self.profileData.types[0]].selector + ' .share';
            self.graphs.push(self.setShareGraph(selector, self.profileData.values[0], self.valuesData.values, self.profileData.types[0]));
        }else{//multiple
            $('.data_block').show();
            $('#type_share').hide();
            $('#type_deviation').hide();
            $('.table,.share').show();
            interfaceInit(getParameterByName('only'));
            for(var i = 0; i < self.profileData.types.length; i++)
                $(typeMap[self.profileData.types[i]].selector).show();

            for (var i = 0; i < self.profileData.values.length; i++){
                self.graphs.push(self.setLinearGraph(self.profileData, self.valuesData, i));
                var selector = typeMap[self.profileData.types[i]].selector + ' table';
                self.setTable(selector, self.profileData.values[i], self.valuesData.values[i]);
                selector = typeMap[self.profileData.types[i]].selector + ' .share';
            self.graphs.push(self.setShareGraph(selector, self.profileData.values[i], self.valuesData.values[i], self.profileData.types[i]));
            }
            
        } 
    };
    self.setLinearGraph = function(profileData, valuesData, type){  
        var data_points = filter_dataset({
            type: type == -1 ? profileData.type : type,
            start: profileData.start,
            period: profileData.period,
            values: type == -1 ? profileData.values[0] : profileData.values[type]
        });
        //daily
        var selector = typeMap[type == -1 ? profileData.types[0] : type].selector + ' .linear';
        var canvas = $(selector);
        ctxDailyUsage = canvas.get(0).getContext("2d");
        ctxDailyUsage.clearRect(0, 0, 1000, 10000);
        ctxDailyUsage.canvas.width = canvas.parent().width();
        canvas.attr("height", "250");
        var dataDailyUsage = {
            datasets: [
                {
                    label: typeMap[type == -1 ? profileData.types[0] : type].label,
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
        if (type == -1){
            type = profileData.types[0];
                data_points = filter_dataset(valuesData);
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
            
        }else{
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
        }
        
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

    self.setTable = function(selector, dataODN, dataMoney){//arrs with values
        var current_tbody = $(selector+' tbody');
        current_tbody.html("");
        var data_size = dataODN.length;
        for(var i = 0; i < data_size; i++){
            var current_date = new Date(i*self.period*60*1000 + self.start*1);
            var date_str = current_date.getDate() + "." + (current_date.getMonth()+1) + "." + current_date.getFullYear();
            var time_str = ("0" + current_date.getHours()).slice(-2) + ":" + ("0" + current_date.getMinutes()).slice(-2);
            current_tbody.append("<tr><td>"+date_str+"</td><td>"+time_str+"</td><td>"+(dataMoney[i]).toFixed(2)+"</td><td>"+(dataODN[i]).toFixed(2)+"</td></tr>")
        }
    };
    self.setShareGraph = function(selector, dataODN, dataMoney, type){
        var canvas = $(selector);
        var ctxShareUsage = canvas.get(0).getContext("2d");
        ctxShareUsage.canvas.width = canvas.parent().width();
        
        var dataShareUsage = [];
        
        var sum = 0;
        for(var j = 0; j < dataODN.length; j++){
            sum += dataODN[j];
        }
        dataShareUsage.push({
            value: toFixed(sum, 2),
            color: typeMap[type].colors.fill,
            highlight: typeMap[type].colors.stroke,
            label: "Общедомовые расходы"
        });
        sum = 0;
        for(var j = 0; j < dataMoney.length; j++){
            sum += dataMoney[j];
        }
        dataShareUsage.push({
            value: toFixed(sum, 2),
            color: typeMap[type].colors.fillDarken,
            highlight: typeMap[type].colors.stroke,
            label: "Ваши расходы"
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

}
function Deviation(id, start, end, period, selectiontype){
    var self = this;

    PageData.call(this, id, start, end, period, selectiontype);  

    self.deviation = $('#deviation').val()/100;
    self.period = 60;

    self.updateData = function(updateRepresentation){
        var selectiontype_str = '';
        if(selectiontype === '5'){//device
            selectiontype_str = 'device';
        }else if (selectiontype === '4'){//type
            selectiontype_str = 'type';
        }
        self.isUpdated = false;
        $.post('/' + selectiontype_str + '/deviation',
            {'id':self.id,
            'start' : self.start+"",
            'end' : self.end+"",
            'value':  self.deviation//'0.90'
        },
            function(data){
                
                var currentData = JSON.parse(data);
                self.data = currentData;

                
                if (updateRepresentation){
                    self.updateRepresentation();
                }
                self.isUpdated = true;
            }
        );

    };

    self.updateRepresentation = function(){ 
        self.destroyAllData();
        $('.percentpicker').show();
        $('.frequencypicker').hide();
        $('.data_block').hide();
        $('#type_deviation').show();
        self.setTable()
    };
    self.setTable = function(){//arrs with values
        var current_tbody = $('#type_deviation tbody');
        current_tbody.html("");
        var data_size = self.data.values.length;
        for(var i = 0; i < data_size; i++){
            var current_date = new Date(i*self.period*60*1000 + self.data.start*1);
            var date_str = current_date.getDate() + "." + (current_date.getMonth()+1) + "." + current_date.getFullYear();
            var time_str = ("0" + current_date.getHours()).slice(-2) + ":" + ("0" + current_date.getMinutes()).slice(-2);
            var date_start = date_str + " " + time_str;
            current_date = new Date((i+1)*self.period*60*1000 + self.data.start*1);
            date_str = current_date.getDate() + "." + (current_date.getMonth()+1) + "." + current_date.getFullYear();
            time_str = ("0" + current_date.getHours()).slice(-2) + ":" + ("0" + current_date.getMinutes()).slice(-2);
            var date_end = date_str + " " + time_str;
            
            var value = self.data.values[i];//.replace(/'/g, "\"")
            var deviation = Math.round(value.value*100);
            deviation = deviation > 0 ? "+"+deviation : ""+deviation;
            var change_field = '<div class="form-inline change_form" style="display: inline-block;"><div class="form-group"><div class="input-group"><input  id="cname_' + value.id + '" type="text" class="form-control" onkeydown="if (event.keyCode == 13) { currentPageData.changeDeviationName(' + value.id + '); return false; }" placeholder="Новое описание"/><div class="input-group-addon glyphicon glyphicon-pencil edit_btn" style="top: 0;" onclick="currentPageData.changeDeviationName(' + value.id + ')"></div></div></div></div>';
            current_tbody.append("<tr><td>"+date_start+"</td><td>"+date_end+"</td><td>"+deviation+"%</td><td><span id='aname_" + value.id + "' style='margin-right: 10px'>"+value.name+"</span>"+change_field+"<div></div></td></tr>")
        }
        // $('form').each(function() {
        //     this.submit(function(e){
        //         if (e.preventDefault) e.preventDefault();

        //         /* do what you want with the form */
        //         console.log("hello");
        //         // You must return false to prevent the default form behavior
        //         return false;
                
        //     });
        //     // $(this).find('.edit_btn').keypress(function(e) {
        //     //     // Enter pressed?
        //     //     if(e.which == 10 || e.which == 13) {
        //     //         this.form.submit();
        //     //     }
        //     // });

        //     // console.log('submited');
        // });
    };

    self.changeDeviationName = function(id){
        var input = $('#cname_'+id);
        var newname = input.val().trim();
        if (newname){
            $.post('/setDeviationName',{'id': id, 'name': newname},function(response){
                //TODO: handle response
                $('#aname_'+id).html(newname);
                input.val('');
            });
        }
        else{
            input.focus();
        }
    };
    self.updDeviation = function(deviation){
        self.deviation = deviation;
        self.updateData(true);
    };
}
function ShareLines(id, start, end, period, selectiontype){
    var self = this;

    PageData.call(this, id, start, end, period, selectiontype);  

    

    self.updateData = function(updateRepresentation){
        self.isUpdated = false;

        
        var selectiontype_str = '';
        if(selectiontype === '5'){//device
            selectiontype_str = 'device';
        }else if (selectiontype === '4'){//type
            selectiontype_str = 'type';
            selectiontype_str = 'flat';
            self.multipleDataFetch(selectiontype_str, updateRepresentation);
        }else if (selectiontype === '3'){//flat
            selectiontype_str = 'flat';
            self.multipleDataFetch(selectiontype_str, updateRepresentation);
            return;
        }else if (selectiontype === '2'){//house
            selectiontype_str = 'house';
            self.multipleDataFetch(selectiontype_str, updateRepresentation);
            return;
        }else if (selectiontype === '1'){//tszh
            selectiontype_str = 'tszh';
            self.multipleDataFetch(selectiontype_str, updateRepresentation);
            return;
        }else if (selectiontype === '0'){//uk
            selectiontype_str = 'uk';
            self.multipleDataFetch(selectiontype_str, updateRepresentation);
            return;
        }
        $.post('/' + selectiontype_str + '/percentage',{
            'types' : [self.id],
            'start' : self.start+"",
            'end' : self.end+"",
            'period' : self.period
        }, function(data){
            var currentData = JSON.parse(data);
            self.data = currentData;
            
            if (updateRepresentation){
                self.updateRepresentation();
            }
            // $('#graph_tab .measure').html(typeMap[currentData.type].measure);
            self.isUpdated = true;
        });
    };

    self.multipleDataFetch = function(selectiontype_str, updateRepresentation){
        $.post('/' + selectiontype_str + '/percentage',{
            'types' : [0,1,2,3,4],
            'start' : self.start+"",
            'end' : self.end+"",
            'period' : self.period
        }, function(data){
            var currentData = JSON.parse(data);
            self.data = currentData;
            
            if (updateRepresentation){
                self.updateRepresentation();
            }
            self.isUpdated = true;
        });
    };
    self.updateRepresentation = function(){        
        self.destroyAllData();

        if(selectiontype === '5' || selectiontype === '4'){//one
            $('.table,.share').hide();
            interfaceInit(self.id.toString());
            self.graphs.push(self.setLinearGraph({
                    type : self.data.types[0],
                    start : self.data.start,
                    period : self.data.period,
                    values : self.data.values[0]
                }));
        }else{//multiple
            $('.data_block').show();
            $('#type_deviation').hide();
            $('.table,.share').hide();
            interfaceInit(getParameterByName('only'));
            for (var i = 0; i < self.data.values.length; i++){
                self.graphs.push(self.setLinearGraph({
                    type : self.data.types[i],
                    start : self.data.start,
                    period : self.data.period,
                    values : self.data.values[i]
                }));
            }            
        } 
        $('#type_share').hide();
    };
    self.setLinearGraph = function(data){       
        var data_points = filter_dataset(data);
        
        //daily
        var selector = typeMap[data.type].selector + ' .linear';
        var canvas = $(selector);
        ctxDailyUsage = canvas.get(0).getContext("2d");
        ctxDailyUsage.clearRect(0, 0, 1000, 10000);
        ctxDailyUsage.canvas.width = canvas.parent().width();
        canvas.attr("height", "250");

        for (var i = 0; i < data_points.values.length; i++){
            data_points.values[i] = Math.round(data_points.values[i] * 100);
        }
        var dataDailyUsage = {
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