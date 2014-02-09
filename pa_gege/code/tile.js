// TODO various performance improvements
var TileDispatcher = (function(){
    var _tileid;
    function withResponseObject(url, callback){
        $.ajax({
            url:url,
        })
          .done(function(data){
            callback(JSON.parse(data));   
        });
    }
    
    function TileDispatcher(tileID){
        this._tileid = tileID;
        this._ScaleCount = 0;
        this._interval = null;
        this._resolv = [["Über uns", "uberuns"], ["Stiftung", "stiftung"],["Presse", "presse"],["Unterstützen","unterstutzen"],["Shop", "shop"],["Kalender", "cal"],["Bilder","bilder"]]

    }
    
    TileDispatcher.prototype.getOnClickHandler = function(){
        return function(){
            console.log("Tile Click: id="+ this._tileid);
            if (this._tileid > 7){
                this._tileid = this._tileid - 7;
            }
            _tileid--;
            load(this._resolv[this._tileid][0], this._resolv[this._tileid][1]);
        };
    };
    
    function load(prettyWhat, URLWhat){
        this._interval = setInterval(sclSmaller, 10);
        setTimeout(activateLoadingAnimation, 30);
        $("#result").load("content/"+ URLWhat +".html", function(){
            setTimeout("load_" + URLWhat, 0);
        });
        $(".ctitle").fadeTo(200,0);
        $.scrollTo("#scrolled", 800, {onAfter: function(){
            $(".ctitle").html("Chorknaben // " + prettyWhat);
            $(".ctitle").fadeTo(200,1);
            // Revert loading Animation
            $("#loading-img").css({visibility:"hidden"});
            $("#header-img").width(90);
            this._ScaleCount = 0;
        }});
    }

    function load_bilder(){
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
                $("#scrolledcontentoff").pullupScroll("#scrolledcontentoff .tile-column");
             }
        });
    }
    
    function activateLoadingAnimation(){
        $("#loading-img").css({visibility:"visible"});
    }
    
    function sclSmaller(){
        console.log("ohai");
        if (this._ScaleCount >= 20){
            window.clearInterval(this._interval);
            return;
        }    
        this._ScaleCount++;
        var HeaderImg = $("#header-img");
        HeaderImg.width(90 - this._ScaleCount);
    }
    
    return TileDispatcher;
})();
