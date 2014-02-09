// TODO various performance improvements
var TileDispatcher = (function(){
    var _tileid;
    var _tileobj;
    var interval;
    var IMAGE_HANDLER = 0x00001;
    
    function withResponseObject(url, callback){
        $.ajax({
            url:url,
        })
          .done(function(data){
            callback(JSON.parse(data));   
        });
    }
    
    function TileDispatcher(tileObj, tileID){
        _tileid = tileID;
        _tileobj = tileObj;
    }
    
    TileDispatcher.prototype.getOnClickHandler = function(){
        return function(){
            load();
        };
    };
    
    function load(){
        interval = setInterval(sclSmaller, 10);
        setTimeout(activateLoadingAnimation, 30);
        $("#result").load("content/bilder.html", function(){
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
                                   $("<a>").attr("href", "#")
                               )
                           )
                       );
                   }
                }
           });
        $(".ctitle").fadeTo(200,0);
        $.getScript("content/bilder.js", function(){
           $.scrollTo("#scrolled", 800, {onAfter: function(){
               $(".ctitle").html("Chorknaben // Bilder");
               $(".ctitle").fadeTo(200,1);
               // Revert loading Animation
               $("#loading-img").css({visibility:"hidden"});
               $("#header-img").width(90);
               ScaleCount = 0;
           }});
      });
      });
    }
    
    function activateLoadingAnimation(){
        $("#loading-img").css({visibility:"visible"});
    }
    
    var ScaleCount = 0;
    function sclSmaller(){
        console.log("ohai");
        if (ScaleCount >= 20){
            window.clearInterval(interval);
            return;
        }    
        ScaleCount++;
        var HeaderImg = $("#header-img");
        HeaderImg.width(90 - ScaleCount);
    }
    
    return TileDispatcher;
})();
