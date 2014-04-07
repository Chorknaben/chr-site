// Generated by CoffeeScript 1.7.1
var ChildPage, Constants, Context, Core, IndexPage, Navigation,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Constants = (function() {
  function Constants() {}

  Constants.SELECTOR_TILE = ".tile-content";

  Constants.SELECTOR_NAV = ".navitem nav";

  Constants.tileResolver = [["Über uns", "uberuns"], ["Stiftung", "stiftung"], ["Presse", "presse"], ["Musik", "musik"], ["Shop", "shop"], ["Kalender", "kalender"], ["Bilder", "bilder"], ["Impressum", "impressum"]];

  return Constants;

})();

Core = (function() {
  var debug;

  function Core() {
    this.getScrollHandler = __bind(this.getScrollHandler, this);
    this.handleHash = __bind(this.handleHash, this);
  }

  Core.prototype.scrollHandlers = {};

  Core.prototype.state = {
    scrolledDown: false,
    currentURL: "null",
    currentPage: "null"
  };

  debug = function(msg) {
    return console.log("Core: " + msg);
  };

  Core.prototype.construct = function() {};

  Core.prototype.withAPICall = function(url, callback) {
    return $.ajax({
      url: url
    }).done(function(data) {
      return callback(JSON.parse(data));
    });
  };

  Core.prototype.initializeHashNavigation = function() {
    if (window.location.hash === "") {
      return window.location.hash = "#!/";
    }
  };

  Core.prototype.handleHash = function() {
    var i, onlySoft, _i;
    if (window.location.hash !== "#!/") {
      onlySoft = this.requestTaker("softReload");
      if (onlySoft) {
        this.state["childPage"].onSoftReload();
        return;
      }
      debug("Hash detected");
      for (i = _i = 0; _i <= 7; i = ++_i) {
        if ("#!/" + Constants.tileResolver[i][1] === window.location.hash) {
          i++;
          new Tile(i, Constants).onClick();
          break;
        }
      }
    }
    if (window.location.hash === "#!/" && this.requestTaker("pageChanged")) {
      debug("Back to Index page");
      $(".tilecontainer").css({
        display: "initial"
      });
      $(".scrolled").css({
        display: "none"
      });
      this.state["childPage"].onUnloadChild();
      return this.sanitize();
    }
  };

  Core.prototype.getScrollHandler = function(event) {
    var key, val, _ref, _results;
    _ref = this.scrollHandlers;
    _results = [];
    for (key in _ref) {
      val = _ref[key];
      _results.push(val(event));
    }
    return _results;
  };

  Core.prototype.registerScrollHandler = function(name, callback) {
    return this.scrollHandlers[name] = callback;
  };

  Core.prototype.deleteScrollHandler = function(name) {
    var key, _i, _len, _ref, _results;
    _ref = this.scrollHandlers;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      key = _ref[_i];
      if (key === name) {
        _results.push(delete this.scrollHandlers[key]);
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  Core.prototype.executeOnce = function(name, func) {
    if (this.state["tmp" + name] === true) {

    } else {
      this.state["tmp" + name] = true;
      return func();
    }
  };

  Core.prototype.rearm = function(name) {
    return delete this.state["tmp" + name];
  };

  Core.prototype.registerTaker = function(name, obj) {
    return this.state["taker" + name] = obj;
  };

  Core.prototype.requestTaker = function(name) {
    var s;
    s = this.state["taker" + name];
    delete this.state["taker" + name];
    return s;
  };

  Core.prototype.insertChildPage = function(pageObj) {
    if (this.state["childPage"]) {
      this.state["childPage"].onUnloadChild();
    }
    this.state["childPage"] = pageObj;
    return pageObj.onInsertion();
  };

  Core.prototype.exportFunction = function(name, func) {
    return this.state[name] = func;
  };

  Core.prototype.requestFunction = function(name, success, failure) {
    var func;
    func = this.state[name];
    if (func) {
      return success(func);
    } else {
      return failure();
    }
  };

  Core.prototype.revokeFunction = function(name) {
    return delete this.state[name];
  };

  Core.prototype.sanitize = function() {
    if (window.location.hash === "#!/") {
      return $(".header-nav").children().each(function(i, obj) {
        var $obj;
        $obj = $(obj);
        console.log($obj.css("font-weight"));
        if ($obj.css("font-weight") === "bold") {
          return $obj.css({
            "font-weight": "initial"
          });
        }
      });
    }
  };

  return Core;

})();

ChildPage = (function() {
  var notImplemented;

  function ChildPage() {
    this.c = window.core;
  }

  notImplemented = function(name) {
    return console.log("" + name + ": not implemented");
  };

  ChildPage.prototype.onGenerateMarkup = function() {
    return notImplemented("onGenerateMarkup");
  };

  ChildPage.prototype.onLoad = function() {
    return notImplemented("onLoad");
  };

  ChildPage.prototype.onScrollFinished = function() {
    return notImplemented("onScrollFinished");
  };

  ChildPage.prototype.onSoftReload = function() {
    return notImplemented("onSoftReload");
  };

  ChildPage.prototype.onScrollUpwards = function() {
    return notImplemented("onScrollUpwards");
  };

  ChildPage.prototype.onUnloadChild = function() {
    return notImplemented("onUnloadChild");
  };

  ChildPage.prototype.onInsertion = function() {
    return notImplemented("onInsertion");
  };

  return ChildPage;

})();

Context = (function() {
  Context.internalState = {};

  function Context(pageName) {
    this.pageName = pageName;
    this.runDetection(this.pageName);
  }

  Context.prototype.getCorrelations = function() {
    return this.internalState;
  };

  Context.prototype.runDetection = function(pageName) {};

  return Context;

})();

IndexPage = (function(_super) {
  __extends(IndexPage, _super);

  function IndexPage() {
    var w;
    IndexPage.__super__.constructor.call(this);
    w = $(window).width();
    if (w > 1177) {
      this.bgSrc = "/" + ($(window).width()) + "/" + ($(window).height() - 90) + "/";
    } else {
      this.bgSrc = "/1610/" + ($(window).height() - 90) + "/";
    }
  }

  IndexPage.prototype.onInsertion = function() {
    this.injectBackground();
    this.injectTileBackgrounds();
    this.loadEffects();
    this.preloadImage();
    return this.footerLeftClick();
  };

  IndexPage.prototype.injectBackground = function() {
    return $("<img>", {
      src: this.bgSrc + "bg"
    }).appendTo($("#bg")).load(function() {
      return $(this).fadeIn(300);
    });
  };

  IndexPage.prototype.preloadImage = function() {
    var h, img, src, w;
    img = new Image();
    w = $(window).width();
    h = $(window).height();
    src = "" + w + "/" + h + "/bg/blurred";
    img.src = src;
    return this.c.state["blurredbg"] = img;
  };

  IndexPage.prototype.footerLeftClick = function() {
    return $(".footer-left").click((function(_this) {
      return function(event) {
        event.preventDefault();
        event.stopPropagation();
        return _this.toggleInfo();
      };
    })(this));
  };

  IndexPage.prototype.toggleInfo = function() {
    if ($("#footer").css("bottom") === "0px") {
      $("#footer").animate({
        bottom: "300px"
      }, 100);
      return this.rotateImg(".footer-left img", 180);
    } else {
      $("#footer").animate({
        bottom: "0px"
      }, 100);
      return this.rotateImg(".footer-left img", 0);
    }
  };

  IndexPage.prototype.rotateImg = function(image, degree) {
    var $elem;
    $elem = $(image);
    return $elem.css({
      '-webkit-transform': 'rotate(' + degree + 'deg)',
      '-moz-transform': 'rotate(' + degree + 'deg)',
      '-ms-transform': 'rotate(' + degree + 'deg)',
      '-o-transform': 'rotate(' + degree + 'deg)',
      'transform': 'rotate(' + degree + 'deg)',
      'zoom': 1
    });
  };

  IndexPage.prototype.injectTileBackgrounds = function() {
    var i, tile, _i, _results;
    _results = [];
    for (i = _i = 12; _i >= 0; i = --_i) {
      $("#" + i).css({
        "background-image": "url(" + (this.bgSrc + i) + ")"
      });
      tile = new Tile(i);
      _results.push($("#" + i).click(tile.onClick));
    }
    return _results;
  };

  IndexPage.prototype.loadEffects = function() {
    var stl;
    stl = $(Constants.SELECTOR_TILE);
    return stl.each(function(index, obj) {
      obj = $(obj);
      return obj.hover(function() {
        obj.children("a").children(".hoveroverlay").animate({
          opacity: "0.7"
        }, 100);
        return $(stl.not(".hoveroverlay")[index - 1]).children(".hoveroverlay").animate({
          opacity: "0"
        }, 100);
      }, function() {
        obj.children("a").children(".hoveroverlay").animate({
          opacity: "0"
        }, 100);
        return $(stl[index - 1]).children("a").children(".hoveroverlay").animate({
          opacity: "0"
        }, 100);
      });
    });
  };

  return IndexPage;

})(ChildPage);

Navigation = (function() {
  Navigation.preState = null;

  function Navigation() {}

  return Navigation;

})();

window.core = new Core;

window.constants = Constants;

$(function() {
  var c;
  c = window.core;
  c.initializeHashNavigation();
  c.handleHash();
  c.insertChildPage(new IndexPage());
  $(window).scroll(c.getScrollHandler);
  return window.onhashchange = c.handleHash;
});
