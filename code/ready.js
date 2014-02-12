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
        $("#"+indexes[m]).click(tileOnClickHandler(m));
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
        //$(Obj).click(new TileDispatcher(Obj,index+1).getOnClickHandler());
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
        //$($(Obj).children("a")[0]).click(new TileDispatcher(Obj,index).getOnClickHandler());
        }
    });
    $(window).scroll(function(){
        scrollFn();
        //todo with settimeout
        /*if ($(this).scrollTop() < 300 && $('.ctitle').html() != "St.-Martins-Chorknaben Biberach"){
            animating = true;
            $(".ctitle").fadeTo(500,0);
            $(".ctitle").html("St.-Martins-Chorknaben Biberach");
            $(".ctitle").fadeTo(200,1);
            animating = false;
        }*/
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

