var getBaloonStr = function(keys, labels, values, href, alertText){
    var res=[];
    res.push("<p><strong>"+alertText+"</strong></p>");
    res.push("<table>");
    res.push("<tbody>");
    for (var i=0; i < labels.length; ++i) {
        res.push("<tr class='"+keys[i]+" baloon_item'><td class='b_label'>"+labels[i]+": </td>");
        res.push("<td class='b_value'>"+values[i]+"</td></tr>");
    }
    res.push("</tbody>");
    res.push("</table>");
    res.push("<a href="+href+" style='margin: 5px 10px;'>Получить отчет</a>");//TODO: change link
    return res.join("");
};
function Dataset(){
    var self = this;

    self.data = [];
    self.allCoordinatesInSet = [];

    self.parseData = function(){
        $('.tszhs>div').each(function(){
            var id = $(this).data('id'),
                name = $(this).children('p').html(),
                income = $(this).children('div').eq(0).data('income'),
                outcome = $(this).children('div').eq(1).data('outcome'),
                balance = $(this).children('div').eq(2).data('balance');
            
            
            var tszh = new Tszh(id, name, income, outcome, balance);
            self.data.push(tszh);

            $(this).find('.houses>div').each(function(){
                var id = $(this).data('id'),
                    name = $(this).children('p').html(),
                    income = $(this).children('div').eq(0).data('income'),
                    outcome = $(this).children('div').eq(1).data('outcome'),
                    balance = $(this).children('div').eq(2).data('balance'),
                    coords = [$(this).data('x'), $(this).data('y')],
                    alert = $(this).data('alert');

                // to remember all coords for set center in the future
                self.allCoordinatesInSet.push(coords);

                var house = new House(id, income, outcome, balance, coords, name);
                if (alert){
                    house.alert = true;
                    house.alertText = alert;
                }
                tszh.children.push(house);
            });
        });
    };

    self.getCoordinatesForCenter = function() {
        var minX = self.allCoordinatesInSet[0][0],
            minY = self.allCoordinatesInSet[0][1],
            maxX = self.allCoordinatesInSet[0][0],
            maxY = self.allCoordinatesInSet[0][1];

        function calculateAvgPoint(element) {
            if (element[0] < minX && element[1] < minY) {
                minX = element[0];
                minY = element[1];
            }
            if (element[0] > maxX && element[1] > maxY) {
                maxX = element[0];
                maxY = element[1];
            }
        }

        self.allCoordinatesInSet.forEach(calculateAvgPoint);

        return [[minX, minY], [maxX, maxY]];
    };

    self.removeHighlight = function(){
        self.data.forEach(function(entry){
            entry.removeHighlight();
        });
    };
    self.init = function(){
        self.data.forEach(function(entry){
            entry.addToMap();
        });
    };

    self.find = function(type, id){
        if(type === 1){
            for (var i = 0; i < self.data.length; i ++){
                var entry = self.data[i];
                if(entry.id == id) return entry;
            }
        }
        if (type === 2){
            for (var i = 0; i < self.data.length; i ++){
                var entry = self.data[i];
                for (var j = 0; j < entry.children.length; j++){
                    if (entry.children[j].id === id) return entry.children[j];
                }
            }
        }
        return null;
    };

    self.toggleAlertsTo = function(areOn){
        self.data.forEach(function(entry){
            entry.toggleAlertsTo(areOn);
        });
    };
};
function DataNode(id, income, outcome, balance){//parent class
    var self = this;

    self.id = id;
    self.income = income;
    self.outcome = outcome;
    self.balance = balance;
    self.children = [];

    self.addChild = function(item) {
        self.children.push(item);
    };
    self.highlight = function(){
    };
};
function Tszh(id, name, income, outcome, balance){
    var self = this;

    DataNode.call(this, id, income, outcome, balance); 

    self.name = name;
    
    self.highlight = function(){
        self.children.forEach(function(entry){
            entry.highlight();
        });
    };
    self.removeHighlight = function(){
        
        self.children.forEach(function(entry){
            entry.removeHighlight();
        });
    };
    self.addToMap = function(){
        self.children.forEach(function(entry){
            
            entry.setPlacemark();
        });
    };

    self.toggleAlertsTo = function(areOn){
        self.children.forEach(function(entry){
            entry.toggleAlertsTo(areOn);
        });
    };
};
function House(id, income, outcome, balance, coords, name){
    var self = this;

    DataNode.call(this, id, income, outcome, balance, coords, name); 

    self.coords = coords;
    self.name = name;
    self.placemark = null;
    self.defaultColor;
    self.alert = false;
    self.alertIsOn = $(this).is(':checked');
    self.alertText = "Текст алерта";
    

    self.highlight = function(){
       
        self.placemark.options.set('preset', 'islands#blueDotIcon');
    };
    self.removeHighlight = function(){
       
        self.placemark.options.set('preset', self.defaultColor);  
    };

    self.setPlacemark = function(){

        var color;

        if(self.balance > 0) {
            color = 'islands#greenIcon';
        } else if(self.balance < 0) {
            color = 'islands#redIcon';
        } else if(self.balance == 0) {
            color = 'islands#yellowIcon';
        }        
        self.defaultColor = color;

        var myPlacemark = new ymaps.Placemark(self.coords,{
            balloonContentHeader: self.name,
            balloonContentBody: ""
        },{
            preset: color
        });

        myPlacemark.events.add('mouseenter', function(e) {
            var filter = $("input[name='type_select']:checked").val();
            var link = '';
            switch(filter) {
                case 'coldwater':
                    link = "/dreports?selectiontype=2&id="+self.id+"&only="+0;
                    break;
                case 'hotwater':
                    link = "/dreports?selectiontype=2&id="+self.id+"&only="+1;
                    break;
                case 'gas':
                    link = "/dreports?selectiontype=2&id="+self.id+"&only="+2;
                    break;
                case 'electricity':
                    link = "/dreports?selectiontype=2&id="+self.id+"&only="+3;
                    break;
                case 'heat':                    
                    link = "/dreports?selectiontype=2&id="+self.id+"&only="+4;
                    break;
            }
            myPlacemark.properties.set('balloonContentBody', 
                        getBaloonStr(["coldwater", "hotwater", "gas","electricity", "heat"],
                                    ["Холодная вода", "Горячая вода", "Газ","Электричество", "Отопление"],
                                    [11237,2565,3487,-432, 132], 
                                    link, 
                                    self.alertIsOn?self.alertText:""));
            myPlacemark.balloon.open();
            myPlacemark.balloon.events.add('mouseleave', function() {
                if(myPlacemark.balloon.isOpen()) myPlacemark.balloon.close();
            });
        });

        myPlacemark.balloon.events.add('open', function (e) {
            $('.baloon_item').hide();
            var filter = $("input[name='type_select']:checked").val();
            switch(filter) {
                case 'coldwater':
                    $('.coldwater').show();
                    break;
                case 'hotwater':
                    $('.hotwater').show();
                    break;
                case 'gas':
                    $('.gas').show();
                    break;
                case 'electricity':
                    $('.electricity').show();
                    break;
                case 'heat':
                    $('.heat').show();
                    break;
            }
        });
        
        myMap.geoObjects.add(myPlacemark);
        self.placemark =  myPlacemark;
    };

    self.removeAllGeo = function(){
        myMap.geoObjects.remove(self.placemark);
    };

    self.toggleAlertsTo = function(isOn){
        self.alertIsOn = isOn; 
        var color = "";
        if (isOn && self.alert){
            self.placemark.options.set({
                'iconLayout': "default#image",
                'iconImageHref': '../images/warning-icon.png',
                'iconImageSize': [42, 42],
                'iconImageOffset': [-21, -43]
            }); 
        } else{
            if(self.balance > 0) {
                color = 'islands#greenIcon';
            } else if(self.balance < 0) {
                color = 'islands#redIcon';
            } else{
                color = 'islands#yellowIcon';
            }  
            self.defaultColor = color;
            self.placemark.options.unset(['iconLayout',
            'iconImageHref',
            'iconImageSize',
            'iconImageOffset']); 
            self.placemark.options.set({'preset': self.defaultColor});
        }
    };
};
var myMap;
var dataset;
var devices = {
    coldwater: {
        type: 0,
        label: 'Холодная вода',
        measure: "л",
        colors: {
            fill: "rgba(151,187,205,0.2)",
            stroke: "rgba(151,187,205,1)"
        },
        odnSelector: "#odnWater"
    },
    hotwater: {
        type: 1,
        label: 'Горячая вода',
        measure: "л",
        colors: {
            fill: "rgba(231, 75, 59, 0.2)",
            stroke: "rgba(231, 75, 59, 1)"
        } ,
        odnSelector: "#odnWater"
    },
    electricity: {
        type: 3,
        measure: "кВт.ч",
        colors: {
            fill: "rgba(243, 156, 18, 0.2)",
            stroke: "rgba(243, 156, 18, 1)"
        }  ,
        odnSelector: "#odnElectricity"
    },
    gas: {
        type: 2,
        measure: "куб. м.",
        colors: {
            fill: "rgba(75, 231, 59, 0.2)",
            stroke: "rgba(75, 231, 59, 1)"
        },
        odnSelector: "#odnGas"
    },
    heat: {
        type: 4,
        measure: "отопл",
        colors: {
            fill: "rgba(231, 75, 59, 0.2)",
            stroke: "rgba(231, 75, 59, 1)"
        } ,
        odnSelector: "#odnHeat"
    }
};


// on radio button change
$('input[name=type_select]:radio').change(
    function(){
        var curVal = $("input[name=type_select]:radio:checked").val();

        $('.measure').html(devices[curVal].measure);
    }
);

// helper function for services
var addItem = function(el, depth, parentId) {
    var itemType,
        labelText,
        url,
        parentItemName = $(el).parent().children('span').text();

//    console.log("Глубина:" + depth);
//    console.log("ИД папы:" + parentId);

    var modal = $("#exampleModal");

    switch (depth) {
        case 0:
            $('.another-form-group').hide();
            itemType = "ТСЖ";
            labelText = 'Имя';
            url = '/tszh/create';
            break;
        case 1:
            $('.another-form-group').hide();
            itemType = "дом";
            labelText = 'Адрес';
            url = '/house/create';
            break;
        case 2:
            $('.another-form-group').hide();
            itemType = "квартиру";
            labelText = 'Номер квартиры';
            url = '/flat/create';
            break;
        case 3:
            $('.another-form-group').show();
            fillImpulseCombo();
            itemType = "услугу";
            labelText = 'Номер счетчика';
            url = '/device/create';
            break;
    }

    modal.find('.modal-title').text('Добавить ' + itemType + ' для ' + parentItemName);
    modal.find('.control-label').text(labelText + ':');
    modal.modal('show');

    $(".modal-footer .btn-primary").on("click", function (event) {
        var obj = {"parentID": parentId},
            types = {
                'coldwater': 0,
                'hotwater': 1,
                'gas': 2,
                'electricity': 3,
                'heat': 4
            };

        switch (depth) {
            case 0:
                obj.name = $('#element-name').val();
                break;
            case 1:
                obj.address = $('#element-name').val();
                obj.x = 'x_coord'; // don't know how to set it
                obj.y = 'y_coord'; // don't know how to set it
                break;
            case 2:
                obj.number = $('#element-name').val();
                break;
            case 3:
                obj.number = $('#element-name').val(); // optional for server now


                obj.name = $('#device_name').val();
                obj.serial = $('#device_serial').val();
                obj.type = types[$("input[name='type_select']:checked").val()];
                obj.impulseID = $('#device_impulse').val();
                //device_on_datetime
                //device_off_datetime
                obj.nextCheck = parseRusDate($('#next_checking_date').val()).getTime();
                //manual_mode_datetime
                //manual_mode_value
                obj.odnFlag = $('#home_common_counter_flag').val();
                obj.rateFlag = $('#tariff').val();
                obj.resolution = $('#device_capacity').val();
                obj.transform = $('#transformation_coefficient').val();
                obj.periodic = $('#values_registration_way').val();

                break;
        }

        $.post(url, obj, function (data) {
            //alert("Элемент " + $('#element-name').val() + " добавлен");
        });

        modal.modal('hide');

        $(this).off(event);
    });
};

// helper function for services
var findPurpose = function(object, name, value) {
    for (var key in object) {
        if (object[key][name] == value)
            return object[key]; // Return as soon as the object is found
    }
    return null; // The object was not found
};

// services
var appendTreeInfoLevel4 = function(obj, selector) {
    $.each(obj, function (index, item) {
        $(selector + " .devices").append('<div id="device' + item.id + '" class="item row" data-id="10">' +
            '<p class="col-xs-3"><span class="device_green">&#9679;</span> ' + findPurpose(devices, 'type', item.type).measure + ' </p>' +
            '<div class="balance col-xs-2" data-income="692">692</div>' +
            '<div class="balance negative col-xs-2" data-outcome="560">-560</div>' +
            '<div class="balance negative col-xs-2" data-balance="-132">-132</div>' +
            '<div class="balance negative col-xs-2" data-odn="666">666</div>' +
            '<a class="col-xs-1" href="/dreports?selectiontype=4&id=' + item.id + '&type=' + item.type + '">получить отчет</a>' +
            '</div>');
    });
};

// flats
var appendTreeInfoLevel3 = function(obj, selector) {
    $.each(obj, function (index, item) {
        $(selector + " .apartments").append('<div id="apartment' + item.id + '" class="item row" data-id="2">' +
            '<p class="col-xs-3">' +
            '<span>' + 'Квартира: ' + item.number + '</span>' +
            '<img src="../images/plus-circle-outline.png" onclick="addItem(this, 3, ' + item.id + ')"/>' +
            '</p>' +
            '<div class="balance col-xs-2" data-income="692">692</div>' +
            '<div class="balance negative col-xs-2" data-outcome="560">-560</div>' +
            '<div class="balance negative col-xs-2" data-balance="-132">-132</div>' +
            '<div class="balance negative col-xs-2" data-odn="666">666</div>' +
            '<a class="col-xs-1" href="/dreports?selectiontype=3&id=' + item.id + '">получить отчет</a>' +
            '<div style="clear: both;"></div>' +
            '<div class="devices nested" style="display:none;">' +
            '</div>' +
            '</div>');

        appendTreeInfoLevel4(item.services, '#apartment' + item.id);

    });
};

// houses
var appendTreeInfoLevel2 = function(obj, selector) {
    $.each(obj, function (index, item) {
        $(selector + " .houses").append('<div id="house' + item.id + '" class="item row" data-id="4" data-x="' + item.x + '" data-y="' + item.y + '">' +
            '<p class="col-xs-3">' +
            '<span>' + item.address + '</span>' +
            '<img src="../images/plus-circle-outline.png" onclick="addItem(this, 2, ' + item.id + ')"/>' +
            '</p>' +
            '<div class="balance col-xs-2" data-income="692">692</div>' +
            '<div class="balance negative col-xs-2" data-outcome="560">-560</div>' +
            '<div class="balance negative col-xs-2" data-balance="-132">-132</div>' +
            '<div class="balance negative col-xs-2" data-odn="666">666</div>' +
            '<a class="col-xs-1" href="/dreports?selectiontype=2&id=4">получить отчет</a>' +
            '<div style="clear: both;"></div>' +
            '<div class="apartments nested" style="display:none;">' +
            '</div>' +
            '</div>');

        appendTreeInfoLevel3(item.flats, '#house' + item.id);

    });
};

// ТСЖ
var appendTreeInfoLevel1 = function(obj) {
    $.each(obj, function (index, item) {
        $(".tszhs").append('<div id="tszh' + item.id + '" class="item row" data-id="2">' +
            '<p class="col-xs-3">' +
            '<span>' + item.name + '</span>' +
            '<img src="../images/plus-circle-outline.png" onclick="addItem(this, 1, ' + item.id + ')"/>' +
            '</p>' +
            '<div class="balance col-xs-2" data-income="692">692</div>' +
            '<div class="balance negative col-xs-2" data-outcome="560">-560</div>' +
            '<div class="balance negative col-xs-2" data-balance="-132">-132</div>' +
            '<div class="balance negative col-xs-2" data-odn="666">666</div>' +
            '<a class="col-xs-1" href="/dreports?selectiontype=1&id=' + item.id + '">получить отчет</a>' +
            '<div style="clear: both;"></div>' +
            '<div class="houses nested" style="display:none;">' +
            '</div>' +
            '</div>');

        appendTreeInfoLevel2(item.houses, '#tszh' + item.id);

    });
};

var appendTreeInfoLevel0 = function(obj) {
    $(".company").append('<div class="item active row">' +
        '<p class="col-xs-3">' +
        '<span>Управляющая компания</span>' +
        '<img src="../images/plus-circle-outline.png" onclick="addItem(this, 0, ' + obj.id + ')"/>' +
        '</p>' +
        '<div class="balance col-xs-2" data-income="692">692</div>' +
        '<div class="balance negative col-xs-2" data-outcome="560">-560</div>' +
        '<div class="balance negative col-xs-2" data-balance="-132">-132</div>' +
        '<div class="balance negative col-xs-2" data-odn="666">666</div>' +
        '<a class="col-xs-1" href="/dreports?selectiontype=0&id=' + obj.id + '">получить отчет</a>' +
        '</div>');

    // ТСЖ
    appendTreeInfoLevel1(obj.HAs);
};

window.onload = function(){
    var map_container = $('#map');
    map_container.height(map_container.width());

    $('#device_on_datetime').datetimepicker({ lang:'ru', step:5 });
    $('#device_off_datetime').datetimepicker({ lang:'ru', step:5 });
    $('#next_checking_date').datetimepicker({ lang:'ru', timepicker: false, format: 'd.m.Y' });
    $('#manual_mode_datetime').datetimepicker({ lang:'ru', step:5 });

    $.post('/dispatcher_tree', {start: '0', end: '99999999999999'}, function (data) {
        var obj = JSON.parse(data);

        appendTreeInfoLevel0(obj);

        $('.tszhs .item>p').click(function(){
            $(this).siblings(".nested").toggleClass("dblock");//.toggleClass("active").removeClass("red");
        });

        if (typeof ymaps == 'undefined') return;
        ymaps.ready(function(){
            myMap = new ymaps.Map('map', {
                center: [55.76, 37.64],
                zoom: 10
            });
            myMap.controls.remove('geolocationControl');
            myMap.controls.remove('searchControl');
            myMap.controls.remove('routeEditor');
            myMap.controls.remove('trafficControl');
            myMap.controls.remove('fullscreenControl');
            myMap.controls.remove('typeSelector');

            //do all staff
            dataset = new Dataset();
            dataset.parseData();
            var res = ymaps.util.bounds.getCenterAndZoom(
                dataset.getCoordinatesForCenter(),
                [$('.map').width(), $('.map').height()]
            );
            myMap.setCenter(res.center, res.zoom);
            dataset.init();
        });



        $('.company>.item>p').click(function(){
            dataset.removeHighlight();
        });
        $('.tszhs>.item>p').click(function(){
            dataset.removeHighlight();
            var id = $(this).parent().data('id');
            var tszh = dataset.find(1, id);
            if (tszh !== null) tszh.highlight();
        });
        $('.houses>.item>p').click(function(){
            dataset.removeHighlight();
            var id = $(this).parent().data('id');
            var house = dataset.find(2, id);
            if (house !== null) house.highlight();
        });

        // fire radio button event change
        $('input[name=type_select]:radio').change();
    });
};

$(window).resize(function(){
    var map_container = $('#map');
    map_container.height(map_container.width());
});

$('#toggle_alert').change(function(){
    dataset.toggleAlertsTo($(this).is(':checked'));
});