var headerVisible = false;
$(document).ready(function(){
    $("nav ul li").each(function(index,Obj){
        $(Obj).hover(function(){
            fadeTo(Obj, "red", "blue");
            fadeTo($(".tile-inner ul li")[index], "white", "black");
        }, function(){
            fadeTo(Obj, "#A9417A", "blue");
            fadeTo($(".tile-inner ul li")[index], "black", "white" );
        });
    });
    $(".tile-inner ul li").each(function(index,Obj){
        $(Obj).hover(function(){
            fadeTo($("nav ul li")[index], "red", "blue");
            fadeTo(Obj, "white" , "black");
        }, function(){
            fadeTo($("nav ul li")[index], "#A9417A", "blue");
            fadeTo(Obj, "black", "white");
        });
    });
    $("nav ul li a").each(function(index,Obj){
        $(this).click(function(){
            // Todo Slide Down
        });    
    });
    
    $(window).scroll(function(){
        if ($(this).scrollTop() > 111){
            $("nav").css({"position":"fixed", top:"-10px"});
        } else {
            $("nav").css({"position":"absolute", "top":"auto"});
        }
        
        if ($(this).scrollTop() > 520 && !headerVisible){
            $("#header").fadeTo(400, 1);
            headerVisible = true;
        }
        
        if ($(this).scrollTop() < 520 && headerVisible){
            $("#header").fadeTo(400, 0);
            headerVisible = false;
        }
    });
});


var attachAnimation = function(obj, animtype, bgcolIn, colIn, bgcolOut, colOut){
    if(animtype){
        //In
        $(obj).animate({backgroundColor:bgcolIn, color : colIn}, "normal");
    } else {
        //Out
        $(obj).animate({backgroundColor:bgcolOut, color : colOut}, "normal");
    }
};

var fadeTo = function(obj, toBG, toText){
    $(obj).animate({backgroundColor : toBG, color : toText}, 240);
}

var hAbtOut = function(){
    
};