// func to get params from hash
function getURLParameter(name, givenstring) {
    return decodeURI(
        (RegExp(name + '=' + '(.+?)(&|$)').exec(givenstring)||[,null])[1]
    );
}

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
var periodItemsFilter = function(picker) {
    var start = new Date(picker.startDate),
        end = new Date(picker.endDate);

    var timeDiff = Math.abs(end.getTime() - start.getTime());
    var diffMinutes = Math.ceil(timeDiff / (1000 * 60));
    var period = $("#period"),
        isReportsPage = (window.location.pathname == "/ureports");

    // hide options that a higher than current date_filter
    $("#period option").each(function()
    {
        if ($(this).val() >= diffMinutes) {
            $(this).hide();
        } else {
            $(this).show();
        }
    });

    if(diffMinutes >= 527040) { // year - minimum is day
        $('#period option[value="180"]').hide();
    }
    if(diffMinutes >= 40320) { // month - minimum is hour
        $('#period option[value="60"]').hide();
        $('#period option[value="5"]').hide();
    }

    if (isReportsPage && currentReporttype == 1) {
        $('#period .other_profile').hide();
    } else if (isReportsPage && currentReporttype != 1) {
        $('#period .report_profile').hide();
    }

    // set first option if cur value higher
    $("#period").find('option:selected').removeAttr("selected");
//    $('#period option[value="1440"]').attr('selected','selected');

    // only if 'day' frequency not hidden
    if ($('#period option[value="1440"]').css('display') !== 'none') {
        $('#period').val("1440");
    }
};

$('#date_filter').on('apply.daterangepicker', function(ev, picker) {
    periodItemsFilter(picker);
});