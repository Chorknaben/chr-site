// Generated by CoffeeScript 1.7.1
var Bilder,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Bilder = (function(_super) {
  __extends(Bilder, _super);

  function Bilder() {
    Bilder.__super__.constructor.call(this);
  }

  Bilder.prototype.onGenerateMarkup = function() {
    return this.c.withAPICall("/images/num", function(retobj) {
      var i, tcolcount, x, _i, _j, _ref, _results;
      tcolcount = 0;
      _results = [];
      for (i = _i = 0, _ref = Math.ceil(retobj.numtiles / 5); 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        $("#scrolledcontentoff").append("<div class=\"tile-column\" id=\"imgcol-" + i + "\"></div>");
        for (x = _j = 0; _j <= 4; x = ++_j) {
          $("#imgcol-" + i).append($("<div>").addClass("stdtile m10 x-" + x).append($("<div>").addClass("tile-scaling"), $("<div>").addClass("tile-content test-b").append($("<a>").attr("href", "#").append($("<div>").addClass("image-thumb")))));
        }
        _results.push($("#scrolledcontentoff").pullupScroll("#scrolledcontentoff .tile-column"));
      }
      return _results;
    });
  };

  Bilder.prototype.onLoad = function() {
    return window.dirtyhack = setInterval(function() {
      if ($('.image-thumb').length !== 0) {
        window.clearInterval(window.dirtyhack);
        return $('.image-thumb').each(function(i, obj) {
          return $(obj).css({
            "background-image": "url(/images/thumbs/" + (i + 1) + ")"
          });
        });
      }
    }, 100);
  };

  Bilder.prototype.onScrollFinished = function() {
    return this.c.registerScrollHandler("pullup", function() {
      return $(".pullup-element").each(function(i, el) {
        el = $(el);
        if (el.visible(true)) {
          return el.addClass("come-in");
        }
      });
    });
  };

  Bilder.prototype.onUnloadChild = function() {
    return this.c.deleteScrollHandler("pullup");
  };

  return Bilder;

})(ChildPage);

window.core.insertChildPage(new Bilder());
