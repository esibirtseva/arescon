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
getBaloonStr = function(keys, labels, values){
    var res=[];
    res.push("<table>");
    for (var i=0; i < labels.length; ++i) {
        res.push("<tr class='"+keys[i]+"'><td class='b_label' style='display: inline-block;'>"+labels[i]+": </td>");
        res.push("<td class='b_value' style='display: inline-block;'>"+values[i]+"</td><tr>");
    }
    res.push("</table>");
    return res.join("");
};
window.onload = function(){
    var map_container = $('#map');
    map_container.height(map_container.width());

    var myMap;
    if (typeof ymaps == 'undefined') return;
    ymaps.ready(function(){
        myMap = new ymaps.Map('map', {
            // центр и коэффициент масштабирования однозначно
            // определяют область картографирования
            center: [55.76, 37.64],
            zoom: 10
        });
        myMap.controls.remove('geolocationControl');
        myMap.controls.remove('searchControl');
        myMap.controls.remove('routeEditor');
        myMap.controls.remove('trafficControl');
        myMap.controls.remove('fullscreenControl');
        myMap.controls.remove('typeSelector');

        addAllHouses();
//        addAlert([55.77404807445789, 37.680125122070306]);
//        addAlert([55.66404807445789, 37.720125122070306]);
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
            color = 'islands#greenDotIcon';
        } else if(balance < 0) {
            color = 'islands#redDotIcon';
        } else if(balance == 0) {
            color = 'islands#yellowDotIcon';
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
        var preset = 'islands#redCircleDotIcon';
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
        for (var i = 0; i < indexes_of_removed.length; i++){
            myMap.geoObjects.add(points[indexes_of_removed[i]].placemark);
        }
    });
    $('.tszhs>.item>p').click(function(){
        for (var i = 0; i < indexes_of_removed.length; i++){
            myMap.geoObjects.add(points[indexes_of_removed[i]].placemark);
        }
        points_to_default();
        var id = $(this).parent().attr('id');
        for (var i = 0; i < tszhs_data.length; i++){
            if (id === tszhs_data[i].id){
                // highlight_points(tszhs_data[i].houses);
                remove_but(tszhs_data[i].houses);
            }
        }
    });
    $('.houses>.item>p').click(function(){
        for (var i = 0; i < indexes_of_removed.length; i++){
            myMap.geoObjects.add(points[indexes_of_removed[i]].placemark);
        }
        points_to_default();
        var id = $(this).parent().attr('id');
        for (var i = 0; i < houses_data.length; i++){
            if (id === houses_data[i].id){
                // highlight_points([houses_data[i].point]);
                remove_but([houses_data[i].point]);
            }
        }
    });
    var highlight_points = function(arr_of_ids){
        for(var i = 0; i < points.length; i++){
            if(arr_of_ids.indexOf(points[i].id) > -1){
                points[i].placemark.options.set('preset', 'islands#redCircleDotIcon');
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
            points[i].placemark.options.set('preset', 'islands#blueCircleDotIcon');

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
