var points = [
    {
        id: 1,
        coords: [55.71855041425817, 37.66815246582029]
    },
    {
        id: 2,
        coords: [55.78283647321973, 37.55691589355467]
    },
    {
        id: 3,
        coords: [55.706921098504964, 37.470398559570306]
    },
    {
        id: 4,
        coords: [55.87404807445789, 37.690125122070306]
    }
];
var tszhs_data = [
    {
        id: 'tszh1',
        houses: [1, 2]
    },
    {
        id: 'tszh2',
        houses: [3, 4]
    }
];
var houses_data = [
    {
        id: 'house1',
        point: 1,
        name: 'Иловайская улица, д. 3',
        income: 15235,
        waste: 13784
    },
    {
        id: 'house2',
        point: 2,
        name: 'Башиловская улица, д. 15',
        income: 15235,
        waste: 15235
    },
    {
        id: 'house3',
        point: 3,
        name: 'Нежинская улица, д. 13',
        income: 15235,
        waste: 15236
    },
    {
        id: 'house4',
        point: 4,
        name: 'Минусинская улица, д. 37',
        income: 15235,
        waste: 13784
    }
];
getBaloonStr = function(keys, labels, values, href, alertText){
    var res=[];
    res.push("<p><strong>"+alertText+"</strong></p>");
    res.push("<table>");
    res.push("<tbody>");
    for (var i=0; i < labels.length; ++i) {
        res.push("<tr class='"+keys[i]+"'><td class='b_label'>"+labels[i]+": </td>");
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

    self.parseData = function(){
        $('.tszhs>div').each(function(){
            var id = $(this).data('id'),
                name = $(this).children('p').html(),
                income = $(this).children('div').eq(0).data('income'),
                outcome = $(this).children('div').eq(1).data('outcome'),
                balance = $(this).children('div').eq(2).data('balance');
            // console.log(id + " " + name + " " + income + " " + outcome + " " + balance);
            
            var tszh = new Tszh(id, name, income, outcome, balance);
            self.data.push(tszh);

            $(this).find('.houses>div').each(function(){
                var id = $(this).data('id'),
                    name = $(this).children('p').html(),
                    income = $(this).children('div').eq(0).data('income'),
                    outcome = $(this).children('div').eq(1).data('outcome'),
                    balance = $(this).children('div').eq(2).data('balance');
                    coords = [$(this).data('x'), $(this).data('y')],
                    alert = $(this).data('alert');
                // console.log(id + " " + name + " " + income + " " + outcome + " " + balance);    
                var house = new House(id, income, outcome, balance, coords, name);
                if (alert){
                    house.alert = true;
                    house.alertText = alert;
                }
                tszh.children.push(house);
            });
        });
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
        console.log("find " + type + " " + id);
        if(type === 1){
            for (var i = 0; i < self.data.length; i ++){
                var entry = self.data[i];
                console.log(entry.name + " " + entry.id);
                if(entry.id == id) return entry;
            }
        }
        if (type === 2){
            for (var i = 0; i < self.data.length; i ++){
                var entry = self.data[i];
                // console.log(entry.name + " " + entry.id);
                // if(entry.id == id) return entry;
                for (var j = 0; j < entry.children.length; j++){
                    if (entry.children[j].id === id) return entry.children[j];
                }
            }
        }
        return null;
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
    console.log(id + " " + name + " " + income + " " + outcome + " " + balance);
    self.highlight = function(){
        console.log("tszh highlight");
        self.children.forEach(function(entry){
            entry.highlight();
        });
    };
    self.removeHighlight = function(){
        console.log("tszh highlight");
        self.children.forEach(function(entry){
            entry.removeHighlight();
        });
    };
    self.addToMap = function(){
        self.children.forEach(function(entry){
            console.log(entry);
            entry.setPlacemark();
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
    self.alertText = "Текст алерта";
    console.log(id + " " + coords + " " + name + " " + income + " " + outcome + " " + balance);   

    self.highlight = function(){
        console.log("house highlight");
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
        
        if(self.alert) color = 'islands#orangeDotIcon';
        self.defaultColor = color;

        var myPlacemark = new ymaps.Placemark(self.coords,{
            balloonContentHeader: self.name,
            balloonContentBody: getBaloonStr(["water","gas","electricity", "heat"],["Вода","Газ","Электричество", "Отопление"],[11237,2565,3487,-432], "/dreports?selectiontype=2&id="+self.id, self.alert?self.alertText:"")//TODO: change implementation
        },{
            preset: color
        });
        myMap.geoObjects.add(myPlacemark);

        myPlacemark.events.add('mouseenter', function(e) {
            myPlacemark.balloon.open();
            myPlacemark.balloon.events.add('mouseleave', function() {
                if(myPlacemark.balloon.isOpen()) myPlacemark.balloon.close();
            });
        });

        myPlacemark.balloon.events.add('open', function (e) {
            var filter = $("input[name='type_select']:checked").val();
            switch(filter) {
                case 'water':
                    $('.gas').hide();
                    $('.electricity').hide();
                    $('.heat').hide();
                    break;
                case 'gas':
                    $('.water').hide();
                    $('.electricity').hide();
                    $('.heat').hide();
                    break;
                case 'electricity':
                    $('.water').hide();
                    $('.gas').hide();
                    $('.heat').hide();
                    break;
                case 'heat':
                    $('.water').hide();
                    $('.gas').hide();
                    $('.electricity').hide();
                    break;
            }
        });

        // myPlacemark.balloon.events.add('click', function (e) {
        //     location.href = "/dreports";
        // });

        self.placemark =  myPlacemark;
    };

    self.setAlert = function(){
        myGeoObject = new ymaps.GeoObject(
            {
                geometry: {
                    type: "Point",
                    coordinates: self.coords
                },
                properties: {
                    iconContent: self.alertContent
                }
            }, {
                preset: 'islands#yellowStretchyIcon'
            });
        self.alert = myGeoObject;
        myMap.geoObjects.add(self.alert);
    };
    self.removeAllGeo = function(){
        myMap.geoObjects.remove(self.placemark);
        myMap.geoObjects.remove(self.alert);
    };
};
var myMap;
var dataset;
window.onload = function(){
    var map_container = $('#map');
    map_container.height(map_container.width());

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

        // addAllHouses();

        //do all staff
        dataset = new Dataset();
        dataset.parseData();
        dataset.init();

    });












    var addAllHouses = function(){
        for (var i = 0; i < houses_data.length; i++){
            var placemark = addHouse(houses_data[i]);
            var point = searchPointById(houses_data[i].point);
            point.placemark = placemark;
        }
    }
    var addHouse = function(house){
        var balance = house.income - house.waste,
            color;

        if(balance > 0) {
            color = 'islands#greenIcon';
        } else if(balance < 0) {
            color = 'islands#redIcon';
        } else if(balance == 0) {
            color = 'islands#yellowIcon';
        }

        var myPlacemark = new ymaps.Placemark(searchPointById(house.point).coords,{
            balloonContentHeader: house.name,
            balloonContentBody: getBaloonStr(["water","gas","electricity", "heat"],["Вода","Газ","Электричество", "Отопление"],[11237,2565,3487,-432])
        },{
            preset: color
        });
        myMap.geoObjects.add(myPlacemark);

        myPlacemark.events.add('mouseenter', function(e) {
            // open balloon on hover
            myPlacemark.balloon.open();
            myPlacemark.balloon.events.add('mouseleave', function() {
	            if(myPlacemark.balloon.isOpen()) myPlacemark.balloon.close();
	        });
        });

        myPlacemark.balloon.events.add('open', function (e) {
            var filter = $("input[name='type_select']:checked").val();
            switch(filter) {
                case 'water':
                    $('.gas').hide();
                    $('.electricity').hide();
                    $('.heat').hide();
                    break;
                case 'gas':
                    $('.water').hide();
                    $('.electricity').hide();
                    $('.heat').hide();
                    break;
                case 'electricity':
                    $('.water').hide();
                    $('.gas').hide();
                    $('.heat').hide();
                    break;
                case 'heat':
                    $('.water').hide();
                    $('.gas').hide();
                    $('.electricity').hide();
                    break;
            }
        });

        myPlacemark.balloon.events.add('click', function (e) {
            // TODO: open report
//            console.log("We will open report soon");
//            console.log(house);
            location.href = "/dreports";
        });
        /*myPlacemark.events.add('click', function(e) {
         // TODO: open report
         console.log("We will open report soon");
         });*/

        return myPlacemark;
    }
    /*var addAlert = function(coords){
        var preset = 'islands#redCircleIcon';
        var myPlacemark = new ymaps.Placemark(coords,{
            // balloonContentHeader: house.name,
            // balloonContentBody: getBaloonStr(["Вода","Газ","Электричество", "Отопление"],[11237,2565,3487,-432])
        },{
            preset: preset
        });
        myMap.geoObjects.add(myPlacemark);
        return myPlacemark
    }*/
    var searchPointById = function(id){
        var res = {};
        for (var i = 0; i < points.length; i++){
            if (points[i].id === id){
                res = points[i];
                break;
            }
        }
        return res;
    }


    $('.company>.item>p').click(function(){
        dataset.removeHighlight();
    });
    $('.tszhs>.item>p').click(function(){
        console.log('tszh click');
        dataset.removeHighlight();
        var id = $(this).parent().data('id');
        var tszh = dataset.find(1, id);
        console.log(tszh);
        if (tszh !== null) tszh.highlight();
    });
    $('.houses>.item>p').click(function(){
        console.log('tszh click');
        dataset.removeHighlight();
        var id = $(this).parent().data('id');
        var house = dataset.find(2, id);
        if (house !== null) house.highlight();
    });
    var highlight_points = function(arr_of_ids){
        for(var i = 0; i < points.length; i++){
            if(arr_of_ids.indexOf(points[i].id) > -1){
                points[i].placemark.options.set('preset', 'islands#redCircleIcon');
                console.log(points[i].placemark.options.set('zIndex', -1));
            }
        }
    };
    var indexes_of_removed =[];
    var remove_but = function(arr_of_ids){
        for(var i = 0; i < points.length; i++){
            if(arr_of_ids.indexOf(points[i].id) == -1){
                myMap.geoObjects.remove(points[i].placemark);
                indexes_of_removed.push(i);
            }
        }
    }
    var points_to_default = function(){
        for(var i = 0; i < points.length; i++){
            points[i].placemark.options.set('preset', 'islands#blueCircleIcon');

        }
    }
    $("input[name='type_select']").change(function(e){
        var selected_value = $(this).val();
        switch(selected_value) {
            case 'water':
                $('.water').show();
                $('.gas').hide();
                $('.electricity').hide();
                $('.heat').hide();
                break;
            case 'gas':
                $('.gas').show();
                $('.water').hide();
                $('.electricity').hide();
                $('.heat').hide();
                break;
            case 'electricity':
                $('.electricity').show();
                $('.water').hide();
                $('.gas').hide();
                $('.heat').hide();
                break;
            case 'heat':
                $('.heat').show();
                $('.water').hide();
                $('.gas').hide();
                $('.electricity').hide();
                break;
        }

    });
}
$(window).resize(function(){
    var map_container = $('#map');
    map_container.height(map_container.width());
});
