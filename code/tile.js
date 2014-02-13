function withResponseObject(url, callback){
    $.ajax({
        url:url,
    })
      .done(function(data){
        callback(JSON.parse(data));   
    });
}
    
function tileOnClickHandler(tileID){ 
    return function(){
    var _resolv = [["Über uns", "uberuns"], ["Stiftung", "stiftung"],["Presse", "presse"],["Unterstützen","unterstutzen"],["Shop", "shop"],["Kalender", "cal"],["Bilder","bilder"]]

    console.log("Tile Click: id="+ tileID);
    if (tileID > 7){
        tileID = tileID - 7;
    }
    load(_resolv[tileID-1][0], _resolv[tileID-1][1]);
    }
};
var _interval = null; 
var _ScaleCount = 0;
function load(prettyWhat, URLWhat){
    _interval = setInterval(sclSmaller, 10);
    setTimeout(activateLoadingAnimation, 30);
    $("#result").load("content/"+ URLWhat +".html", function(){
        //setTimeout("load_" + URLWhat, 0);
        window["load_" + URLWhat]();
        $.getScript("content/" + URLWhat + ".js", function(){
        $.scrollTo("#scrolled", 800, {onAfter: function(){
            $(".ctitle").html("Chorknaben // " + prettyWhat);
            $(".ctitle").fadeTo(200,1);
            // Revert loading Animation
            $("#loading-img").css({visibility:"hidden"});
            $("#header-img").width(90);
            _ScaleCount = 0;
    }});
        });
    });
    $(".ctitle").fadeTo(200,0);
}

function load_bilder(){
    console.log("entered bilder");
    withResponseObject("http://0.0.0.0/handler/images/num", function(retobj){
         var tcolcount = 0;    
         for(var i = 0; i <= Math.ceil(retobj.numtiles / 5); i++){
            $("#scrolledcontentoff").append(
                "<div class=\"tile-column\" id=\"imgcol-"+ i +"\"></div>"
            );
            for (var x = 0; x <= 4; x++){
                $("#imgcol-"+i).append(
                    $("<div>").addClass("stdtile x-"+x).append(
                        $("<div>").addClass("tile-scaling"),
                        $("<div>").addClass("tile-content test-b").append(
                            $("<a>").attr("href", "#").append(
                                $("<div>").addClass("image-thumb")
                            )
                        )
                    )
                );
            }
            $("#scrolledcontentoff").pullupScroll("#scrolledcontentoff .tile-column");
         }
    });
}

function activateLoadingAnimation(){
    $("#loading-img").css({visibility:"visible"});
}

function sclSmaller(){
    if (_ScaleCount >= 20){
        window.clearInterval(_interval);
        return;
    }    
    _ScaleCount++;
    var HeaderImg = $("#header-img");
    HeaderImg.width(90 - _ScaleCount);
}

