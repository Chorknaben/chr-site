var headerVisible = false;
var navVisible = false;
var isScrolledDown = false;
var SELECTOR_TILE = '.tile-content';
var SELECTOR_NAV = '.navitem div';
var animating = false;

/*document.ready = function(){
    $(SELECTOR_TILE + ", " + SELECTOR_NAV).blurjs({
        radius:'25',
        source:'body'
    });
}*/

(function ( $ ) {
    $.fn.pullupScroll = function(e) {
    	$(e).addClass('pullup-element');
    	$(e).each(function(i, el) {
  			var el = $(el);
  			if (el.visible(true)) {
    		el.addClass("already-visible"); 
  		} 
		});
		$("head").append('<style>.come-in{-ie-transform:translateY(150px);-webkit-transform:translateY(150px);transform:translateY(150px);-webkit-animation:come-in .8s ease forwards;animation:come-in .8s ease forwards}.come-in:nth-child(odd){-webkit-animation-duration:.6s;animation-duration:.6s}.already-visible{-ie-transform:translateY(0);-webkit-transform:translateY(0);transform:translateY(0);-webkit-animation:none;animation:none}@-webkit-keyframes come-in{to{-ie-transform:translateY(0);-webkit-transform:translateY(0);transform:translateY(0)}}@keyframes come-in{to{-ie-transform:translateY(0);-webkit-transform:translateY(0);transform:translateY(0)}}</style>');
        return this;
    };
	$.fn.visible = function(partial) {
		      var $t        = $(this),
	          $w            = $(window),
	          viewTop       = $w.scrollTop(),
	          viewBottom    = viewTop + $w.height(),
	          _top          = $t.offset().top,
	          _bottom       = _top + $t.height(),
	          compareTop    = partial === true ? _bottom : _top,
	          compareBottom = partial === true ? _top : _bottom;
	    
	    return ((compareBottom <= viewBottom) && (compareTop >= viewTop));
  };
}( jQuery ));

function scrollFn() { 
  $(".pullup-element").each(function(i, el) {
    var el = $(el);
    if (el.visible(true)) {
      el.addClass("come-in"); 
    }  
});
}

$(document).ready(function(){
    var width = $(window).width();
    var height = $(window).height();
    var bgSrc = "/" + width + "/" + (height - 90) + "/";
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
        $("#"+indexes[m]).click(tileOnClickHandler(m));
    }
    $(SELECTOR_NAV).not('.hoveroverlay').each(function(index,Obj){
        // Add Hover Effect
        $(Obj).hover(function(){
            $(Obj).children(".hoveroverlay").animate({opacity:'0.7'}, 100);
            $($(SELECTOR_TILE)[index+1]).children('a').children('.hoveroverlay').animate({opacity:'0.7'},100);
        }, function(){
            $(Obj).children(".hoveroverlay").animate({opacity:'0'}, 200);
            $($(SELECTOR_TILE)[index+1]).children('a').children('.hoveroverlay').animate({opacity:'0'},200);
        });
    });
    $(SELECTOR_TILE).each(function(index,Obj){
            $(Obj).hover(function(){
                $(Obj).children('a').children('.hoveroverlay').animate({opacity:'0.7'},100);
                $($(SELECTOR_NAV).not('.hoveroverlay')[index-1]).children(".hoveroverlay").animate({opacity:'0.7'}, 100);
            }, function(){
                $(Obj).children('a').children('.hoveroverlay').animate({opacity:'0'},100);
                $($(SELECTOR_NAV).not('.hoveroverlay')[index-1]).children(".hoveroverlay").animate({opacity:'0'}, 100);
            });
        $(Obj).hover(function(){
            $(Obj).children('a').children('.hoveroverlay').animate({opacity:'0.7'},100);
            $($(SELECTOR_NAV).not('.hoveroverlay')[index-1]).children(".hoveroverlay").animate({opacity:'0.7'}, 100);
        }, function(){
            $(Obj).children('a').children('.hoveroverlay').animate({opacity:'0'},100);
            $($(SELECTOR_NAV).not('.hoveroverlay')[index-1]).children(".hoveroverlay").animate({opacity:'0'}, 100);
        });
    });
    $(window).scroll(function(){
        scrollFn();
        if ($(this).scrollTop() == 0 && $('.ctitle').html() != "St.-Martins-Chorknaben Biberach"){
            setTimeout(function(){
                if ($(window).scrollTop() == 0){
                    window.location.hash = "#";
                    $(".ctitle").fadeTo(500,0);
                    setTimeout(function(){
                        $(".ctitle").html("St.-Martins-Chorknaben Biberach");
                        $(".ctitle").fadeTo(200,1);
                    },500);
                } 
            }, 1000);
        }
        if ($(this).scrollTop() > 140 && !navVisible){
            navVisible = true;
        } 
        
        if ($(this).scrollTop() < 140 && navVisible){
            navVisible = false;
        }
      
        if ($(this).scrollTop() > $(window).height() - 40 && !isScrolledDown){
           $(".header-nav").fadeTo(200,1);
           if (CURRENTLY_LOADED_URL != "null"){
               window.location.hash = CURRENTLY_SCROLLED_URL;
           }
           isScrolledDown = true;
           if (CURRENTLY_LOADED != "null"){
               $(".ctitle").fadeTo(200,0);
               setTimeout(function(){
                   $(".ctitle").html("Chorknaben // " + CURRENTLY_LOADED);
                   $(".ctitle").fadeTo(200,1);
               },200);
            }
      }
      
        if ($(this).scrollTop() < $(window).height() - 40 && isScrolledDown){
           $(".header-nav").fadeTo(200,0);
           isScrolledDown = false;
      }
    });
});

var fadeTo = function(obj, toBG, toText){
    $(obj).animate({backgroundColor : toBG}, 240);
}
