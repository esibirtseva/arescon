$("#loginForm").submit(function(a){return window.location="/user.html",a.preventDefault(),!1}),$("#loginSubmitButton").click(function(){$("#loginForm").submit()});var isAdding=!1;$(".device.add .glyphicon").click(function(){isAdding?$(".device.add form").css("display","none"):$(".device.add form").css("display","block"),$(".device.add .glyphicon-plus").toggleClass("glyphicon-minus"),isAdding=!isAdding});var active_house=!1,active_apartment=!1,active_device=!1;$(".houses .item").click(function(){active_apartment&&$(".apartments .item.active").click(),active_house?($(".apartments").hide(),$(".houses .item").show()):($(".apartments").show(),$(".houses .item").hide()),active_house=!active_house,$(this).show().toggleClass("active").removeClass("red")}),$(".apartments .item").click(function(){active_device&&$(".devices .item.active").click(),active_apartment?($(".apartments .item").show(),$(".devices").hide()):($(".apartments .item").hide(),$(".devices").show()),active_apartment=!active_apartment,$(this).show().toggleClass("active").removeClass("red")}),$(".devices .item").click(function(){active_device?$(".devices .item").show():$(".devices .item").hide(),active_device=!active_device,$(this).show().toggleClass("active").removeClass("red")});