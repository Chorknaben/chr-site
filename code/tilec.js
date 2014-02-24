// Generated by CoffeeScript 1.7.1
var Tile,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Tile = (function() {
  function Tile(tileid, _const) {
    this.tileid = tileid;
    this["const"] = _const != null ? _const : Constants;
    this.sclSmaller = __bind(this.sclSmaller, this);
    this.onClick = __bind(this.onClick, this);
    this.core = window.core;
    this.interval = null;
    this.scaleCount = 0;
    this.headerImg = $("#header-img");
  }

  Tile.prototype.onClick = function() {
    console.log("Tile Click: id=" + this.tileid);
    if (this.tileid > 7) {
      this.tileid -= 7;
    }
    console.log(this["const"].tileResolver);
    return this.load(this["const"].tileResolver[this.tileid - 1][0], this["const"].tileResolver[this.tileid - 1][1]);
  };

  Tile.prototype.load = function(prettyWhat, urlWhat) {
    this.interval = setInterval(this.sclSmaller, 10);
    setTimeout(this.activateLoadingAnimation, 30);
    $("#result").load("content/" + urlWhat + ".html", (function(_this) {
      return function() {
        window["load_" + urlWhat]();
        window.location.hash = urlWhat;
        $(".scrolled").attr("id", urlWhat);
        return $.getScript("content/" + urlWhat + ".js").done(function() {
          return $.scrollTo(".scrolled", 800, {
            onAfter: function() {
              _this.core.state["currentPage"] = prettyWhat;
              _this.core.state["currentURL"] = urlWhat;
              _this.core.state["scrolloff"] = $(window).scrollTop();
              $(".ctitle").html("Chorknaben // " + prettyWhat);
              $(".ctitle").fadeTo(200, 1);
              $("#loading-img").css({
                visibility: "hidden"
              });
              return $("#header-img").width(90);
            }
          });
        }).fail(function() {
          return alert("fail");
        });
      };
    })(this));
    return $(".ctitle").fadeTo(200, 0);
  };

  Tile.prototype.sclSmaller = function() {
    if (this.scaleCount >= 20) {
      window.clearInterval(this.interval);
      return;
    }
    this.scaleCount++;
    return this.headerImg.width(90 - this.scaleCount);
  };

  Tile.prototype.activateLoadingAnimation = function() {
    return $("#loading-img").css({
      visibility: "visible"
    });
  };

  return Tile;

})();


function withResponseObject(url, callback){
    $.ajax({
        url:url,
    })
      .done(function(data){
        callback(JSON.parse(data));   
    });
}
window["load_bilder"] = function(){
    
    console.log("entered bilder");
    withResponseObject("/images/num", function(retobj){
         var tcolcount = 0;    
         for(var i = 0; i <= Math.ceil(retobj.numtiles / 5); i++){
            $("#scrolledcontentoff").append(
                "<div class=\"tile-column\" id=\"imgcol-"+ i +"\"></div>"
            );
            for (var x = 0; x <= 4; x++){
                $("#imgcol-"+i).append(
                    $("<div>").addClass("stdtile m10 x-"+x).append(
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
window["load_uberuns"] = function(){
    
}
;
