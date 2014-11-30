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

		for (var i = 0; i < points.length - 1; i++){
			addHouse(points[i][0], points[i][1], false);
		}
		addHouse(points[3][0], points[3][1], true);

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
	}
	var points = [
		[55.71855041425817, 37.66815246582029],
		[55.78283647321973, 37.55691589355467],
		[55.706921098504964, 37.470398559570306],
		[55.87404807445789, 37.690125122070306],
	];
}
$(window).resize(function(){
	var map_container = $('#map');
	map_container.height(map_container.width());
});
