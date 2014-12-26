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
        // console.log("find " + type + " " + id);
        if(type === 1){
            for (var i = 0; i < self.data.length; i ++){
                var entry = self.data[i];
                // console.log(entry.name + " " + entry.id);
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

    self.changePlacemarkLinks = function(type){
        self.data.forEach(function(entry){
            entry.changePlacemarkLink(type);
        });
    }
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
    // console.log(id + " " + name + " " + income + " " + outcome + " " + balance);
    self.highlight = function(){
        // console.log("tszh highlight");
        self.children.forEach(function(entry){
            entry.highlight();
        });
    };
    self.removeHighlight = function(){
        // console.log("tszh highlight");
        self.children.forEach(function(entry){
            entry.removeHighlight();
        });
    };
    self.addToMap = function(){
        self.children.forEach(function(entry){
            // console.log(entry);
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
    // console.log(id + " " + coords + " " + name + " " + income + " " + outcome + " " + balance);   

    self.highlight = function(){
        console.log("house highlight " + self.id + " " + 'islands#blueDotIcon');
        self.placemark.options.set('preset', 'islands#blueDotIcon');
    };
    self.removeHighlight = function(){
        console.log("house removehighlight " + self.id + " " + self.defaultColor);
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
            balloonContentBody: ""
        },{
            preset: color
        });

        myPlacemark.events.add('mouseenter', function(e) {
            var filter = $("input[name='type_select']:checked").val();
            console.log(filter);
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
                case 'all':
                    link = "/dreports?selectiontype=2&id="+self.id;
                    break;
            }
            myPlacemark.properties.set('balloonContentBody', 
                        getBaloonStr(["coldwater", "hotwater", "gas","electricity", "heat"],
                                    ["Холодная вода", "Горячая вода", "Газ","Электричество", "Отопление"],
                                    [11237,2565,3487,-432, 132], 
                                    link, 
                                    self.alert?self.alertText:""));
            myPlacemark.balloon.open();
            myPlacemark.balloon.events.add('mouseleave', function() {
                if(myPlacemark.balloon.isOpen()) myPlacemark.balloon.close();
            });
        });

        myPlacemark.balloon.events.add('open', function (e) {
            $('.baloon_item').hide();
            var filter = $("input[name='type_select']:checked").val();
            console.log(filter);
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
                    console.log(filter + "stays");
                    $('.heat').show();
                    break;
                case 'all':
                    $('.baloon_item').show();
                    break;
            }
        });

        // myPlacemark.balloon.events.add('click', function (e) {
        //     location.href = "/dreports";
        // });
        
        myMap.geoObjects.add(myPlacemark);
        self.placemark =  myPlacemark;
    };

    self.removeAllGeo = function(){
        myMap.geoObjects.remove(self.placemark);
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

        //do all staff
        dataset = new Dataset();
        dataset.parseData();
        dataset.init();
    });



    $('.company>.item>p').click(function(){
        dataset.removeHighlight();
    });
    $('.tszhs>.item>p').click(function(){
        console.log('tszh clicked');
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
}
$(window).resize(function(){
    var map_container = $('#map');
    map_container.height(map_container.width());
});