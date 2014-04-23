// Generated by CoffeeScript 1.7.1
var ChildPage, Constants, Context, Core, IndexPage, Navigation,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Constants = (function() {
  function Constants() {}

  Constants.SELECTOR_TILE = ".tile-content";

  Constants.SELECTOR_NAV = ".navitem nav";

  Constants.METHODS = {
    "NAME": 0x00001,
    "NAME_USER": 0x00010,
    "ID": 0x00100
  };

  Constants.tileResolver = [["Über uns", "uberuns"], ["Stiftung", "stiftung"], ["Presse", "presse"], ["Musik", "musik"], ["Shop", "shop"], ["Kalender", "kalender"], ["Bilder", "bilder"], ["Impressum", "impressum"]];

  return Constants;

})();

Core = (function() {
  var debug;

  function Core() {
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
    var currentPage, dontHandle, i, subHash, _i, _j;
    if (window.location.hash !== "#!/") {
      dontHandle = this.requestTaker("dontHandle");
      if (dontHandle) {
        return;
      }
      debug("Hash detected");
      currentPage = $(".scrolled").attr("id");
      if (currentPage) {
        if (window.location.hash.length !== 3 + currentPage.length) {
          if (window.location.hash.substr(3, currentPage.length) === currentPage) {
            subHash = window.location.hash.substr(3 + currentPage.length, window.location.hash.length);
            this.state["childPage"].notifyHashChange(subHash);
            return;
          }
        }
      } else {
        if (window.location.hash.indexOf("/", 2) !== -1) {
          console.log("this condition is true");
          this.registerTaker("backupHash", window.location.hash);
          for (i = _i = 0; _i <= 7; i = ++_i) {
            if (window.location.hash.indexOf(Constants.tileResolver[i][1]) !== -1) {
              i++;
              new Tile(i, Constants).onClick();
              break;
            }
          }
          return;
        }
      }
      for (i = _j = 0; _j <= 7; i = ++_j) {
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
      return window.nav.reset();
    }
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
    return this.state["__taker" + name] = obj;
  };

  Core.prototype.requestTaker = function(name) {
    var s;
    s = this.state["__taker" + name];
    delete this.state["__taker" + name];
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
    if (failure == null) {
      failure = $.noop;
    }
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

  Core.prototype.release = function() {
    return this.requestFunction("Tile.finalizeLoading", function(func) {
      return func();
    });
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

  ChildPage.prototype.onDOMVisible = function() {
    return notImplemented("onDOMVisible");
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

  ChildPage.prototype.acquireLoadingLock = function() {
    return false;
  };

  ChildPage.prototype.notifyHashChange = function(newHash) {};

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
    this.currentRotatorImgID = 0;
    this.maxRotatorImgID = 100;
    this.imgObj = null;
  }

  IndexPage.prototype.onInsertion = function() {
    this.injectBackground();
    this.injectTileBackgrounds();
    this.loadEffects();
    this.preloadImage();
    this.footerLeftClick();
    return this.imgRotator(10000);
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

  IndexPage.prototype.imgRotator = function(waitFor) {
    if (this.currentRotatorImgID === 0) {
      console.log("imgRotator: init");
      this.makeImage(function() {
        return $("#link-bilder").append(this.imgObj);
      });
      return this.imgRotator(15000);
    } else {
      console.log("imgRotator: now:wait");
      return setTimeout((function(_this) {
        return function() {
          $("#link-bilder img").addClass("luminanz");
          return setTimeout(function() {
            console.log("after fade");
            $("#link-bilder img").remove();
            if (_this.currentRotatorImgID > _this.maxRotatorImgID) {
              _this.currentRotatorImgID = 1;
            }
            return _this.makeImage(function(image) {
              return setTimeout(function() {
                console.log(image);
                $("#link-bilder").append(image);
                $(image).removeClass("luminanz");
                return setTimeout(function() {
                  return _this.imgRotator(15000);
                }, 2000);
              }, 3000);
            }, true);
          }, 2000);
        };
      })(this), waitFor);
    }
  };

  IndexPage.prototype.makeImage = function(onload, lum) {
    this.imgObj = new Image();
    this.imgObj.onload = onload(this.imgObj);
    this.imgObj.src = "/images/real/" + this.currentRotatorImgID;
    if (lum) {
      this.imgObj.classList.add("luminanz");
    }
    return this.currentRotatorImgID++;
  };

  IndexPage.prototype.luminanz = function(image, saturate, opacity) {
    var $elem;
    $elem = $(image);
    return $elem.css({
      '-webkit-filter': "saturate(" + saturate + ") opacity(" + opacity + ")",
      '-moz-filter': "saturate(" + saturate + ") opacity(" + opacity + ")",
      '-ms-filter': "saturate(" + saturate + ") opacity(" + opacity + ")",
      '-o-filter': "saturate(" + saturate + ") opacity(" + opacity + ")",
      'filter': "saturate(" + saturate + ") opacity(" + opacity + ")"
    });
  };

  IndexPage.prototype.injectTileBackgrounds = function() {
    var i, _i, _results;
    _results = [];
    for (i = _i = 12; _i >= 0; i = --_i) {
      _results.push($("#" + i).css({
        "background-image": "url(" + (this.bgSrc + i) + ")"
      }));
    }
    return _results;
  };

  IndexPage.prototype.loadEffects = function() {
    var stl;
    return stl = $(Constants.SELECTOR_TILE);
  };

  return IndexPage;

})(ChildPage);

Navigation = (function() {
  Navigation.preState = null;

  function Navigation(element) {
    this.navigator = $(element);
    console.log(this.navigator);
    this.navigationChilds = this.navigator.children();
  }

  Navigation.prototype.by = function(method, name) {
    var result;
    if (method === Constants.METHODS.NAME) {
      result = null;
      this.navigationChilds.each(function(i, obj) {
        var href;
        href = obj.attributes["href"].firstChild;
        if (href.data.substring(3, href.length) === name) {
          result = $(obj);
          return false;
        }
      });
      if (result === null) {
        throw new Error("No such name under method");
      }
      return this.internalToggle(result);
    } else if (method === Constants.METHODS.ID) {
      if ((0 > name && name > this.navigationChilds.length)) {
        throw new Error("No object with this ID");
      }
      result = $(this.navigationChilds[name]);
      return this.internalToggle(result);
    }
  };

  Navigation.prototype.reset = function() {
    if (this.preState !== void 0) {
      return this.preState.css({
        "font-weight": "initial"
      });
    }
  };

  Navigation.prototype.internalToggle = function(toggleThis) {
    console.log(this.preState);
    if (this.preState !== void 0) {
      this.preState.css({
        "font-weight": "initial"
      });
    }
    toggleThis.css({
      "font-weight": "bold"
    });
    return this.preState = toggleThis;
  };

  return Navigation;

})();

window.core = new Core;

window.constants = Constants;

$(function() {
  var c;
  window.nav = new Navigation(".header-nav");
  c = window.core;
  c.initializeHashNavigation();
  c.handleHash();
  c.insertChildPage(new IndexPage());
  $(window).scroll(c.getScrollHandler);
  return window.onhashchange = c.handleHash;
});
