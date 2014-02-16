var SELECTOR_TILE = '.tile-content';
var SELECTOR_NAV = '.navitem div';
var _isScrolledDown = false;

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
    /* Es wird die Bildschirmauflösung ermittelt und an den Server geschickt.
     * Der Server gibt dann ein passendes Hintergrundbild zurück.
     * */
    var width = $(window).width(),
        height = $(window).height(),
        bgSrc = "/" + width + "/" + (height - 90) + "/";
    console.log(bgSrc);
    // Hinzufügen des Hintergrundbilds zum DOM
    $('<img>', {
        src:bgSrc + "bg"
    }).hide().appendTo($('#bg')).load(function(){
        $(this).remove(); 
        $('#bg').css('background-image', 'url(' + bgSrc +'bg)').fadeIn(300);
    });
    /* Jetzt werden basierend auf der Bildschirmauflösung die Hintergrundbilder
     * der Kacheln angefordert.
     * Das indexes Array stimmt mit den serverseitig gelagerten Kachel-Festlegungen überein. (Siehe src/Site.hs)
     * */
    // Array wird populiert
    var indexes = new Array();
    for (var i=1; i<=12; i++) indexes[i] = i + "";
    indexes[7] = "bigtile-content";
    indexes[12] = "nav-last";
    // Bilder werden hinzugefügt
    for (var m=1; m<=12; m++){
        $("#"+indexes[m]).css('background-image','url('+bgSrc+m+')');
        // Onclick-Handler werden zu den Kacheln hinzugefügt (->tile.js)
        $("#"+indexes[m]).click(tileOnClickHandler(m));
    }
    /* Der Hover-Effekt wird zu allen Kacheln hinzugefügt
     * */
    Stl = $(SELECTOR_TILE);
    Snv = $(SELECTOR_NAV);
    Snv.not('.hoveroverlay').each(function(index,Obj){
        // Add Hover Effect
        Obj = $(Obj);
        Obj.hover(function(){
            // Maus bewegt sich in eine Navigations Kachel
            Obj.children(".hoveroverlay").animate({opacity:'0.7'}, 100);
            $(Stl[index+1]).children('a').children('.hoveroverlay').animate({opacity:'0.7'},100);
        }, function(){
            // Maus bewegt aus einer Navigations Kachel heraus
            Obj.children(".hoveroverlay").animate({opacity:'0'}, 200);
            $(Stl[index+1]).children('a').children('.hoveroverlay').animate({opacity:'0'},200);
        });
    });
    Stl.each(function(index,Obj){
        Obj = $(Obj);
        Obj.hover(function(){
            // Maus bewegt sich in eine Content Kachel
            Obj.children('a').children('.hoveroverlay').animate({opacity:'0.7'},100);
            $(Snv.not('.hoveroverlay')[index-1]).children(".hoveroverlay").animate({opacity:'0.7'}, 100);
        }, function(){
            // Maus bewegt sich aus einer Content Kachel heraus
            Obj.children('a').children('.hoveroverlay').animate({opacity:'0'},100);
            $(Snv.not('.hoveroverlay')[index-1]).children(".hoveroverlay").animate({opacity:'0'}, 100);
        });
    });
    /* Es gibt einige Sachen, die beim scrollen erledigt werden müssen
     * */
    $(window).scroll(function(){
        // Zum einen der Scoll-Handler von jQuery's pullupScroll für die Bilder
        // ([TODO]Outsource ->bilder.js?)
        scrollFn();
        // Zum anderen die nachfolgenden selbst definierten Events
        if ($(this).scrollTop() == 0 && $('.ctitle').html() != "St.-Martins-Chorknaben Biberach"){
            // Wenn nach dem Besuch einer Seite wieder nach oben gescrollt wird,
            // wird nach einiger Zeit der Titel wieder zu "St.-Martins-Chorknaben Biberach"
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
      
        // Die nachfolgende Bedingung evaluiert zu true, wenn die angeforderte Seite
        // vollständig geladen ist
        // ([TODO] auf überholtheit aufgrund callback in tile.js überprüfen)
        if ($(this).scrollTop() > $(window).height() - 40 && !isScrolledDown){
            // Navigation einblenden
            // ([TODO] trotz unsichtbar: klickbar -> fix)
            $(".header-nav").fadeTo(200,1);
            if (CURRENTLY_LOADED_URL != "null"){
                window.location.hash = CURRENTLY_LOADED_URL;
            }
            isScrolledDown = true;
            // ([TODO] titel soll nach mehrmaligen partiellen hochscrollen nicht neu eingefaded werden)
            if (CURRENTLY_LOADED != "null"){
                $(".ctitle").fadeTo(200,0);
                setTimeout(function(){
                    $(".ctitle").html("Chorknaben // " + CURRENTLY_LOADED);
                    $(".ctitle").fadeTo(200,1);
                },200);
            }
        }

        // Umkehrfunktion obiger if-anweisung
        if ($(this).scrollTop() < $(window).height() - 40 && isScrolledDown){
           $(".header-nav").fadeTo(200,0);
           isScrolledDown = false;
       }
    });
});
