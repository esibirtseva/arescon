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

var active_tszh = false, active_house = false, active_apartment = false, active_device = false;
$('.tszhs .item>p').click(function(){
	$(this).siblings(".nested").toggleClass("dblock");//.toggleClass("active").removeClass("red");
});
// $('.tszhs .item').click(function(){
// 	if (active_house) $('.houses .item.active').click();
// 	if (!active_tszh) {
// 		$('.houses').show();
// 		$('.tszhs .item').hide();
// 	}
// 	else{
// 		$('.houses').hide();
// 		$('.tszhs .item').show();
// 	}
// 	active_tszh = !active_tszh;
// 	$(this).show().toggleClass("active").removeClass("red");
// });
// $('.houses .item').click(function(){
// 	if (active_apartment) $('.apartments .item.active').click();
// 	if (!active_house) {
// 		$('.apartments').show();
// 		$('.houses .item').hide();
// 	}
// 	else{
// 		$('.apartments').hide();
// 		$('.houses .item').show();
// 	}
// 	active_house = !active_house;
// 	$(this).show().toggleClass("active").removeClass("red");
// });
// $('.apartments .item').click(function(){	
// 	if (active_device) $('.devices .item.active').click();
// 	if (!active_apartment) {
// 		$('.apartments .item').hide();
// 		$('.devices').show();
// 	}
// 	else{
// 		$('.apartments .item').show();
// 		$('.devices').hide();
// 	}
// 	active_apartment = !active_apartment;
// 	$(this).show().toggleClass("active").removeClass("red");
// });
// $('.devices .item').click(function(){
// 	if (!active_device) {
// 		$('.devices .item').hide();
// 	}
// 	else{
// 		$('.devices .item').show();
// 	}
// 	active_device = !active_device;
// 	$(this).show().toggleClass("active").removeClass("red");
// });

$('.history_reports h4').click(function(){
	$('.history_reports h4 .glyphicon').toggleClass('glyphicon-chevron-down').toggleClass('glyphicon-chevron-up');
});

// to control change of 'Интервал' control
$('#date_filter').on('apply.daterangepicker', function(ev, picker) {
    var start = new Date(picker.startDate),
        end = new Date(picker.endDate);

    var timeDiff = Math.abs(end.getTime() - start.getTime());
    var diffMinutes = Math.ceil(timeDiff / (1000 * 60));
    var period = $("#period");

    // set first option if cur value higher
    if(period.val() >= diffMinutes) {
        period.val($("#period option:first").val());
    }

    // hide options that a higher than current date_filter
    $("#period option").each(function()
    {
        if ($(this).val() >= diffMinutes) {
            $(this).hide();
        } else {
            $(this).show();
        }
    });
});