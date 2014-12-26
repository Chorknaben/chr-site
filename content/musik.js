// Generated by CoffeeScript 1.7.1
var Musik,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Musik = (function(_super) {
  __extends(Musik, _super);

  function Musik() {
    Musik.__super__.constructor.call(this);
    this.core = window.core;
    this.core.requestFunction("ContentViewer.requestInstance", (function(_this) {
      return function(cView) {
        return _this.contentViewer = cView();
      };
    })(this));
    console.log(this.contentViewer);
  }

  Musik.prototype.onLoad = function() {
    var attr;
    if (window.ie) {
      attr = $(".cd img").attr("src");
      return $(".cd img").attr("src", attr + ".png");
    }
  };

  Musik.prototype.onDOMVisible = function() {
    var audi, audio;
    audio = document.getElementsByTagName('audio');
    if (audio[0] === null) {
      setTimeout(this.onDOMVisible, 200);
      return;
    }
    audi = audiojs.create(audio[0]);
    return $.ajax({
      url: "/data/json/musik.json"
    }).done((function(_this) {
      return function(json) {
        var file, _i, _len, _ref;
        _ref = json.musik;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          file = _ref[_i];
          _this.addMusicFile(file.displayname, file.pathname);
        }
        _this.clickEvents(audi);
        return _this.selectFirst(audi);
      };
    })(this));
  };

  Musik.prototype.addMusicFile = function(display, path) {
    var parent;
    parent = $(".playlist");
    return parent.append($("<li>").attr("data-src", path).append(display));
  };

  Musik.prototype.selectFirst = function(audiojs) {
    var first;
    first = $(".playlist li").first();
    first.addClass("playing");
    console.log(first);
    return audiojs.load("/data/musik/" + first.attr("data-src"));
  };

  Musik.prototype.clickEvents = function(audiojs) {
    return $(".playlist li").click(function(e) {
      e.preventDefault();
      $(this).addClass('playing').siblings().removeClass('playing');
      audiojs.load("/data/musik/" + $(this).attr("data-src"));
      return audiojs.play();
    });
  };

  return Musik;

})(ChildPage);

window.core.insertChildPage(new Musik());
