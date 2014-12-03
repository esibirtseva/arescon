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

		for (var i = 0; i < points.length; i++){
			var placemark = addHouse(points[i].coords[0], points[i].coords[1], false);
			points[i].placemark = placemark;
		}
		// var placemark = addHouse(points[3].coords[0], points[3].coords[1], true);
		// points[3].placemark = placemark;

		//events
		// myMap.events.add('click', function (e) {
		//     // Получение координат щелчка
		//     var coords = e.get('coords');
		//     alert(coords.join(', '));
		//     console.log(coords);
		// });
	});
	var addHouse = function(x, y, isProblem){
		var blue = 'islands#blueCircleDotIcon';
		var red = 'islands#redCircleDotIcon'
		var myPlacemark = new ymaps.Placemark([x, y],{},{
			preset: isProblem?red:blue
		});
		myMap.geoObjects.add(myPlacemark);
		return myPlacemark;
	}


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
			point: 1
		},
		{
			id: 'house2',
			point: 2
		},
		{
			id: 'house3',
			point: 3
		},
		{
			id: 'house4',
			point: 4
		}
	];
	$('.tszhs .item p').click(function(){
		points_to_default();
		var id = $(this).parent().attr('id');
		for (var i = 0; i < tszhs_data.length; i++){
			if (id === tszhs_data[i].id){
				highlight_points(tszhs_data[i].houses);
			}
		}
	});
	$('.houses .item p').click(function(){
		points_to_default();
		var id = $(this).parent().attr('id');
		for (var i = 0; i < houses_data.length; i++){
			if (id === houses_data[i].id){
				highlight_points([houses_data[i].point]);
				console.log("highlight " + houses_data[i].point);
			}
		}
	});
	var highlight_points = function(arr_of_ids){
		for(var i = 0; i < points.length; i++){
			if(arr_of_ids.indexOf(points[i].id) > -1){
				points[i].placemark.options.set('preset', 'islands#redCircleDotIcon');
			}
		}
	};
	var points_to_default = function(){
		for(var i = 0; i < points.length; i++){
			points[i].placemark.options.set('preset', 'islands#blueCircleDotIcon');
			
		}
	}
}
$(window).resize(function(){
	var map_container = $('#map');
	map_container.height(map_container.width());
});
