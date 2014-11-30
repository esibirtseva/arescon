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