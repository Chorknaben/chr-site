var headerVisible = false;
var navVisible = false;
var isScrolledDown = false;
var SELECTOR_TILE = '.tile-content';
var SELECTOR_NAV = '.navitem div';

/*document.ready = function(){
    $(SELECTOR_TILE + ", " + SELECTOR_NAV).blurjs({
        radius:'25',
        source:'body'
    });
}*/

$(document).ready(function(){
    var width = $(window).width();
    var height = $(window).height();
    var bgSrc = "http://0.0.0.0/" + width + "/" + (height - 90) + "/";
    console.log(bgSrc);
    var img = $('<img>', {
        src:bgSrc + "bg"
    }).hide().appendTo($('#bg')).load(function(){
        $(this).remove(); 
        $('#bg').css('background-image', 'url(' + bgSrc +'bg)').fadeIn(300);
    });
    var indexes = new Array();
    for (var i=1; i<=12; i++) {indexes[i] = i + "";}
    indexes[7] = "bigtile-content";
    indexes[12] = "nav-last";
    for (var m=1; m<=12; m++){
        $("#"+indexes[m]).css('background-image','url('+bgSrc+m+')');
    }
    $(SELECTOR_NAV).each(function(index,Obj){
        // Add Hover Effect
        $(Obj).hover(function(){
            $($(SELECTOR_TILE)[index+1]).stop();
            //fadeTo(Obj, "red", "blue");
            //fadeTo($(SELECTOR_TILE)[index+1], "white", "black");
        }, function(){
            $($(SELECTOR_TILE)[index+1]).stop();
            //fadeTo(Obj, "black", "blue");
            //fadeTo($(SELECTOR_TILE)[index+1], "black", "white" );
        });
        // Add OnClick Handler
        $(Obj).click(new TileDispatcher(Obj,index+1).getOnClickHandler());
    });
    $(SELECTOR_TILE).each(function(index,Obj){
        /*$(Obj).blurjs({
            radius:32,
            source:'body'
        });*/
        if (index !== 0){
            $(Obj).hover(function(){
                $($(SELECTOR_NAV)[index-1]).stop();
                
                //fadeTo($(SELECTOR_NAV)[index-1], "red", "blue");
                //fadeTo(Obj, "white" , "black");
            }, function(){
                $($(SELECTOR_NAV)[index+1]).stop();
                /*$(Obj).animate({
                    backgroundColor:'black',
                    opacity:'0.5'
                });*/
                //fadeTo($(SELECTOR_NAV)[index-1], "black", "blue");
                //fadeTo(Obj, "black", "white");
            });
        $($(Obj).children("a")[0]).click(new TileDispatcher(Obj,index).getOnClickHandler());
        }
    });
    $(window).scroll(function(){
        if ($(this).scrollTop() > 140 && !navVisible){
            navVisible = true;
        } 
        
        if ($(this).scrollTop() < 140 && navVisible){
            navVisible = false;
        }
      
        if ($(this).scrollTop() > $(window).height() - 40 && !isScrolledDown){
           $(".header-nav").fadeTo(200,1);
           isScrolledDown = true;
      }
      
        if ($(this).scrollTop() < $(window).height() - 40 && isScrolledDown){
           $(".header-nav").fadeTo(200,0);
           isScrolledDown = false;
      }
    });
});

/*document.addEventListener('backbutton', function(){
    console.log("test");
    $.scrollTo('0', 800);
});*/

var fadeTo = function(obj, toBG, toText){
    $(obj).animate({backgroundColor : toBG}, 240);
}

