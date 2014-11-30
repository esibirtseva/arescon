$('#loginForm').submit(function(e) {  // this handles the submit event
    
    window.location = "/user.html";

    e.preventDefault();
    return false;
});

$("#loginSubmitButton").click(function(){
    $('#loginForm').submit(); // this triggers the submit event
}); 
var isAdding = false;
$(".device.add .glyphicon").click(function(){
	if (!isAdding){
		$(".device.add form").css('display', 'block');		
	}
	else{
		$(".device.add form").css('display', 'none');
	}
	$(".device.add .glyphicon-plus").toggleClass("glyphicon-minus");
	isAdding = !isAdding;
});

var active_house = false, active_apartment = false, active_device = false;
$('.houses .item').click(function(){
	if (active_apartment) $('.apartments .item.active').click();
	if (!active_house) {
		$('.apartments').show();
		$('.houses .item').hide();
	}
	else{
		$('.apartments').hide();
		$('.houses .item').show();
	}
	active_house = !active_house;
	$(this).show().toggleClass("active").removeClass("red");
});
$('.apartments .item').click(function(){	
	if (active_device) $('.devices .item.active').click();
	if (!active_apartment) {
		$('.apartments .item').hide();
		$('.devices').show();
	}
	else{
		$('.apartments .item').show();
		$('.devices').hide();
	}
	active_apartment = !active_apartment;
	$(this).show().toggleClass("active").removeClass("red");
});
$('.devices .item').click(function(){
	if (!active_device) {
		$('.devices .item').hide();
	}
	else{
		$('.devices .item').show();
	}
	active_device = !active_device;
	$(this).show().toggleClass("active").removeClass("red");
});
// active_house.click(function(){
// 	console.log("123");
// 	// $('.houses .item').show();
// 	// $(this).show().removeClass("active");
// });
// $(".get-started-btn").click(function(e){
// 	show($('#loginform'));
// 	e.preventDefault();
//     return false;
// });
// $(".download-btn").click(function(e){
// 	show($('#regform'));
// 	e.preventDefault();
//     return false;
// });
// var show = function(block){
// 	block.css('display', 'block');	
// }
// var hide = function(block){
// 	block.css('display', 'none');	
// }
//daily
var ctxDailyUsage = $("#dailyUsageChart").get(0).getContext("2d");
ctxDailyUsage.canvas.width = $("#dailyUsageChart").parent().width();
var dataDailyUsage = {
    labels: ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль"],
    datasets: [
        {
            label: "My Second dataset",
            fillColor: "rgba(151,187,205,0.2)",
            strokeColor: "rgba(151,187,205,1)",
            pointColor: "rgba(151,187,205,1)",
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: "rgba(151,187,205,1)",
            data: [28, 48, 40, 19, 86, 27, 90]
        }
    ]
};
var optionsDailyUsage = {
    scaleShowGridLines : false,
};
var dailyUsageChart = new Chart(ctxDailyUsage).Line(dataDailyUsage, optionsDailyUsage);

//share
var ctxShareUsage = $("#shareUsageChart").get(0).getContext("2d");
ctxShareUsage.canvas.width = $("#shareUsageChart").parent().width();
var dataShareUsage = [
    {
        value: 350,
        color:"rgba(66, 139, 202, 0.1)",
        highlight: "#FF5A5E",
        label: "Red"
    },
    {
        value: 100,
        color: "rgb(66, 139, 202)",
        highlight: "#FFC870",
        label: "Yellow"
    }
];
var optionsShareUsage = {
    //Boolean - Whether we should show a stroke on each segment
    segmentShowStroke : true,

    //String - The colour of each segment stroke
    segmentStrokeColor : "#fff",

    //Number - The width of each segment stroke
    segmentStrokeWidth : 2,

    //Number - The percentage of the chart that we cut out of the middle
    percentageInnerCutout : 50, // This is 0 for Pie charts

    //Number - Amount of animation steps
    animationSteps : 100,

    //String - Animation easing effect
    animationEasing : "easeOutBounce",

    //Boolean - Whether we animate the rotation of the Doughnut
    animateRotate : true,

    //Boolean - Whether we animate scaling the Doughnut from the centre
    animateScale : false,

    //String - A legend template
    legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<segments.length; i++){%><li><span style=\"background-color:<%=segments[i].fillColor%>\"></span><%if(segments[i].label){%><%=segments[i].label%><%}%></li><%}%></ul>"
};
var shareUsageChart = new Chart(ctxShareUsage).Doughnut(dataShareUsage, optionsShareUsage);

$(window).resize(function(){
	ctxDailyUsage.canvas.width = $('.data').width();
	dailyUsageChart = new Chart(ctxDailyUsage).Line(dataDailyUsage, optionsDailyUsage);
});
window.onload = function(){
	var map_container = $('#map');
	map_container.height(map_container.width());
}
$(window).resize(function(){
	var map_container = $('#map');
	map_container.height(map_container.width());
});
var myMap;
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